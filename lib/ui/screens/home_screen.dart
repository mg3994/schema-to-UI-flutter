import 'package:flutter/material.dart';
import 'package:signals_flutter/signals_flutter.dart';
import '../../providers/schema_signal_controller.dart';
import '../../services/json_ld_parser.dart';
import '../widgets/sample_schemas.dart';
import '../widgets/schema_renderer_router.dart';
import '../widgets/schema_explorer_dialog.dart';

class HomeScreen extends StatefulWidget {
  final SchemaSignalController controller;
  final VoidCallback onToggleTheme;
  final bool isDarkMode;

  const HomeScreen({
    super.key,
    required this.controller,
    required this.onToggleTheme,
    required this.isDarkMode,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _jsonInputController = TextEditingController();
  String _selectedPresetName = "Product (E-Commerce)";

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Default initial schema
    _jsonInputController.text = SampleSchemas.productJson;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.controller.updateJsonLdInput(_jsonInputController.text);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _jsonInputController.dispose();
    super.dispose();
  }

  void _loadPreset(String name, String json) {
    setState(() {
      _selectedPresetName = name;
      _jsonInputController.text = json;
    });
    widget.controller.updateJsonLdInput(json);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.layers, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            const Text(
              "Schema.org Engine (BLoC Signals & Responsive)",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(widget.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            tooltip: "Toggle Light/Dark Theme",
            onPressed: widget.onToggleTheme,
          ),
          IconButton(
            icon: const Icon(Icons.search_outlined),
            tooltip: "Explore All Schema.org Classes",
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => SchemaExplorerDialog(
                  controller: widget.controller,
                  onSelectSample: (jsonCode) {
                    setState(() {
                      _selectedPresetName = "Custom Generated";
                      _jsonInputController.text = jsonCode;
                    });
                    widget.controller.updateJsonLdInput(jsonCode);
                  },
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.preview_outlined), text: "Rich UI Render"),
            Tab(icon: Icon(Icons.code_outlined), text: "JSON-LD & Raw Inspector"),
          ],
        ),
      ),
      body: Watch((context) {
        final isLoading = widget.controller.isLoading.value;
        final error = widget.controller.error.value;
        final currentSchema = widget.controller.currentSchemaNode.value;

        if (isLoading) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text("Loading official Schema.org Ontology graph..."),
              ],
            ),
          );
        }

        return Column(
          children: [
            // Quick Presets Bar
            Container(
              color: theme.colorScheme.surfaceContainerHigh.withOpacity(0.5),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Text(
                    "Presets:",
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: SampleSchemas.presets.entries.map((entry) {
                          final isSelected = _selectedPresetName == entry.key;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: FilterChip(
                              selected: isSelected,
                              label: Text(entry.key),
                              onSelected: (val) {
                                if (val) {
                                  _loadPreset(entry.key, entry.value);
                                }
                              },
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.account_tree, size: 18),
                    label: const Text("All Classes"),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => SchemaExplorerDialog(
                          controller: widget.controller,
                          onSelectSample: (jsonCode) {
                            setState(() {
                              _selectedPresetName = "Custom Generated";
                              _jsonInputController.text = jsonCode;
                            });
                            widget.controller.updateJsonLdInput(jsonCode);
                          },
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            // Error Banner
            if (error != null)
              MaterialBanner(
                backgroundColor: theme.colorScheme.errorContainer,
                content: Text(
                  error,
                  style: TextStyle(color: theme.colorScheme.onErrorContainer),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      _loadPreset("Product (E-Commerce)", SampleSchemas.productJson);
                    },
                    child: const Text("Restore Sample"),
                  ),
                ],
              ),

            // Main Views Tab
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // TAB 1: Rich UI View
                  currentSchema == null
                      ? const Center(child: Text("Enter valid JSON-LD to render schema UI"))
                      : SchemaRendererRouter(node: currentSchema),

                  // TAB 2: JSON-LD Editor & Tree Inspector View
                  LayoutBuilder(
                    builder: (context, constraint) {
                      final isDesktop = constraint.maxWidth > 800;

                      final editorCard = Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.edit_note),
                                  const SizedBox(width: 8),
                                  Text(
                                    "JSON-LD Code Input",
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const Spacer(),
                                  IconButton(
                                    icon: const Icon(Icons.cleaning_services_outlined),
                                    tooltip: "Clear Editor",
                                    onPressed: () {
                                      _jsonInputController.clear();
                                      widget.controller.updateJsonLdInput('');
                                    },
                                  ),
                                ],
                              ),
                              const Divider(),
                              Expanded(
                                child: TextField(
                                  controller: _jsonInputController,
                                  maxLines: null,
                                  expands: true,
                                  keyboardType: TextInputType.multiline,
                                  style: const TextStyle(
                                    fontFamily: 'monospace',
                                    fontSize: 13,
                                  ),
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    hintText: "Paste your @context and JSON-LD schema here...",
                                  ),
                                  onChanged: (val) {
                                    widget.controller.updateJsonLdInput(val);
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      );

                      final inspectorCard = Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.account_tree),
                                  const SizedBox(width: 8),
                                  Text(
                                    "Parsed Schema Hierarchy",
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(),
                              Expanded(
                                child: currentSchema == null
                                    ? const Center(
                                        child: Text("No Schema object parsed."),
                                      )
                                    : SingleChildScrollView(
                                        child: _buildRawNodeInspector(
                                          context,
                                          currentSchema,
                                        ),
                                      ),
                              ),
                            ],
                          ),
                        ),
                      );

                      if (isDesktop) {
                        return Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              Expanded(child: editorCard),
                              const SizedBox(width: 16),
                              Expanded(child: inspectorCard),
                            ],
                          ),
                        );
                      } else {
                        return Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Expanded(child: editorCard),
                              const SizedBox(height: 16),
                              Expanded(child: inspectorCard),
                            ],
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildRawNodeInspector(BuildContext context, dynamic node, [int depth = 0]) {
    final theme = Theme.of(context);
    if (node is JsonLdNode) {
      return Padding(
        padding: EdgeInsets.only(left: depth * 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: theme.colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                "@type: ${node.primaryType}",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSecondaryContainer,
                ),
              ),
            ),
            const SizedBox(height: 4),
            ...node.fields.entries.map((e) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${e.key}: ",
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Expanded(
                      child: _buildRawNodeInspector(context, e.value.value, depth + 1),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      );
    } else if (node is List) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: node
            .map((item) => _buildRawNodeInspector(context, item, depth + 1))
            .toList(),
      );
    } else {
      return Text(
        node.toString(),
        style: TextStyle(color: theme.colorScheme.primary),
      );
    }
  }
}

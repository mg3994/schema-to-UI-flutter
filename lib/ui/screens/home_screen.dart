import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:signals_flutter/signals_flutter.dart';
import '../../providers/schema_signal_controller.dart';
import '../../services/json_ld_parser.dart';
import '../widgets/sample_schemas.dart';
import '../widgets/schema_renderer_router.dart';
import '../widgets/schema_explorer_dialog.dart';
import '../widgets/schema_graph_visualizer_dialog.dart';

class HomeScreen extends StatefulWidget {
  final SchemaSignalController controller;
  final VoidCallback onToggleTheme;
  final bool isDarkMode;
  final Color currentColorSeed;
  final List<Color> availableColorSeeds;
  final ValueChanged<Color> onChangeColorSeed;

  const HomeScreen({
    super.key,
    required this.controller,
    required this.onToggleTheme,
    required this.isDarkMode,
    required this.currentColorSeed,
    required this.availableColorSeeds,
    required this.onChangeColorSeed,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _jsonInputController = TextEditingController();
  final TextEditingController _inspectorSearchController = TextEditingController();
  String _selectedPresetName = "Product Group (Nesting, 3D, AddOns)";
  String _inspectorSearchQuery = '';

  // Active Locale and Currency Controls for Live Testing
  Locale _activeAppLocale = const Locale('en', 'US');
  final List<Locale> _availableLocales = const [
    Locale('en', 'US'),
    Locale('es', 'ES'),
    Locale('fr', 'FR'),
    Locale('hi', 'IN'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Default initial schema
    _jsonInputController.text = SampleSchemas.auraGlowProductGroupJson;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.controller.updateJsonLdInput(_jsonInputController.text);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _jsonInputController.dispose();
    _inspectorSearchController.dispose();
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

    return Localizations.override(
      context: context,
      locale: _activeAppLocale,
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              Icon(Icons.hub, color: theme.colorScheme.primary, size: 28),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Schema.org Studio Engine",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  Text(
                    "Universal Socket-BLoC Architecture",
                    style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.secondary),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            // Color Seed Picker Popup Menu
            PopupMenuButton<Color>(
              icon: Icon(Icons.palette_outlined, color: theme.colorScheme.primary),
              tooltip: "Change Accent Theme Seed",
              onSelected: widget.onChangeColorSeed,
              itemBuilder: (context) {
                return widget.availableColorSeeds.map((color) {
                  return PopupMenuItem<Color>(
                    value: color,
                    child: Row(
                      children: [
                        CircleAvatar(radius: 10, backgroundColor: color),
                        const SizedBox(width: 8),
                        Text(color == widget.currentColorSeed ? "Active Seed" : "Theme Accent"),
                      ],
                    ),
                  );
                }).toList();
              },
            ),

            // Graph Visualizer Trigger
            IconButton(
              icon: const Icon(Icons.hub_outlined),
              tooltip: "Graph Network Visualizer",
              onPressed: () {
                final current = widget.controller.currentSchemaNode.value;
                if (current != null) {
                  showDialog(
                    context: context,
                    builder: (context) => SchemaGraphVisualizerDialog(rootNode: current),
                  );
                }
              },
            ),

            // Active Locale Control Dropdown
            Container(
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.language, size: 18),
                  const SizedBox(width: 6),
                  DropdownButton<Locale>(
                    value: _activeAppLocale,
                    underline: const SizedBox.shrink(),
                    isDense: true,
                    items: _availableLocales.map((loc) {
                      return DropdownMenuItem<Locale>(
                        value: loc,
                        child: Text(loc.toLanguageTag(), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                      );
                    }).toList(),
                    onChanged: (newLoc) {
                      if (newLoc != null) {
                        setState(() {
                          _activeAppLocale = newLoc;
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.copy),
              tooltip: "Copy JSON-LD Payload",
              onPressed: () {
                Clipboard.setData(ClipboardData(text: _jsonInputController.text));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("JSON-LD payload copied to clipboard!")),
                );
              },
            ),
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
              Tab(icon: Icon(Icons.code_outlined), text: "JSON-LD Studio Editor"),
              Tab(icon: Icon(Icons.electrical_services_outlined), text: "Socket Component Inspector"),
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
                        _loadPreset("Product Group (Nesting, 3D, AddOns)", SampleSchemas.auraGlowProductGroupJson);
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
                    // TAB 1: Rich UI Render Canvas
                    currentSchema == null
                        ? const Center(child: Text("Enter valid JSON-LD to render schema UI"))
                        : SchemaRendererRouter(node: currentSchema),

                    // TAB 2: JSON-LD Editor & Inspector
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
                                const SizedBox(height: 8),

                                // Search Inspector Bar
                                TextField(
                                  controller: _inspectorSearchController,
                                  decoration: InputDecoration(
                                    hintText: "Filter node keys or values...",
                                    prefixIcon: const Icon(Icons.search, size: 18),
                                    isDense: true,
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                    suffixIcon: _inspectorSearchQuery.isNotEmpty
                                        ? IconButton(
                                            icon: const Icon(Icons.clear, size: 16),
                                            onPressed: () {
                                              _inspectorSearchController.clear();
                                              setState(() => _inspectorSearchQuery = '');
                                            },
                                          )
                                        : null,
                                  ),
                                  onChanged: (val) {
                                    setState(() {
                                      _inspectorSearchQuery = val;
                                    });
                                  },
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

                    // TAB 3: Socket Component Inspector
                    _buildSocketComponentInspector(context, currentSchema),
                  ],
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildSocketComponentInspector(BuildContext context, JsonLdNode? currentSchema) {
    final theme = Theme.of(context);

    if (currentSchema == null) {
      return const Center(child: Text("No active schema loaded in Socket Inspector."));
    }

    final activeSockets = _findActiveSockets(currentSchema);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            color: theme.colorScheme.primaryContainer.withOpacity(0.3),
            elevation: 0,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Icon(Icons.electrical_services, size: 36, color: theme.colorScheme.primary),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Active Female-Male Socket Architecture", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                        Text("Detected ${activeSockets.length} pluggable female sockets in active schema payload.", style: theme.textTheme.bodySmall),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          ...activeSockets.map((soc) {
            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: theme.colorScheme.secondaryContainer,
                  child: Icon(Icons.extension, color: theme.colorScheme.onSecondaryContainer, size: 20),
                ),
                title: Text("Female Socket Slot: [ ${soc['slot']} ]", style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text("Plugged Male Component: ${soc['type']} (${soc['name']})"),
                trailing: Chip(
                  label: Text(soc['type'] ?? ''),
                  visualDensity: VisualDensity.compact,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  List<Map<String, String>> _findActiveSockets(JsonLdNode node) {
    List<Map<String, String>> res = [];

    void checkNode(String slotKey, dynamic val) {
      if (val is JsonLdNode) {
        res.add({
          'slot': slotKey,
          'type': val.primaryType,
          'name': val.fields['name']?.value?.toString() ?? val.primaryType,
        });
        val.fields.forEach((k, v) => checkNode(k, v.value));
      } else if (val is List) {
        for (var item in val) {
          checkNode(slotKey, item);
        }
      }
    }

    node.fields.forEach((k, v) => checkNode(k, v.value));
    return res;
  }

  Widget _buildRawNodeInspector(BuildContext context, dynamic node, [int depth = 0]) {
    final theme = Theme.of(context);
    final query = _inspectorSearchQuery.toLowerCase();

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
            ...node.fields.entries.where((e) {
              if (query.isEmpty) return true;
              final keyMatch = e.key.toLowerCase().contains(query);
              final valMatch = e.value.value.toString().toLowerCase().contains(query);
              return keyMatch || valMatch;
            }).map((e) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${e.key}: ",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        backgroundColor: query.isNotEmpty && e.key.toLowerCase().contains(query)
                            ? Colors.yellow.withOpacity(0.4)
                            : null,
                      ),
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
      final str = node.toString();
      final isMatch = query.isNotEmpty && str.toLowerCase().contains(query);

      return Text(
        str,
        style: TextStyle(
          color: theme.colorScheme.primary,
          backgroundColor: isMatch ? Colors.yellow.withOpacity(0.4) : null,
        ),
      );
    }
  }
}

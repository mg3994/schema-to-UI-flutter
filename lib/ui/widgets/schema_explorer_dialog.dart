import 'package:flutter/material.dart';
import '../../providers/schema_signal_controller.dart';
import '../../models/schema_ontology.dart';

class SchemaExplorerDialog extends StatefulWidget {
  final SchemaSignalController controller;
  final Function(String jsonCode) onSelectSample;

  const SchemaExplorerDialog({
    super.key,
    required this.controller,
    required this.onSelectSample,
  });

  @override
  State<SchemaExplorerDialog> createState() => _SchemaExplorerDialogState();
}

class _SchemaExplorerDialogState extends State<SchemaExplorerDialog> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'All';

  final List<String> _categories = [
    'All',
    'CreativeWork',
    'Event',
    'Intangible',
    'MedicalEntity',
    'Organization',
    'Person',
    'Place',
    'Product',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final allClasses = widget.controller.ontologyService.classes.values.toList();

    final filteredClasses = allClasses.where((sc) {
      // Category filter
      if (_selectedCategory != 'All') {
        if (!widget.controller.ontologyService.isSubclassOf(sc.id, _selectedCategory)) {
          return false;
        }
      }

      // Search query filter
      if (_searchQuery.isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      return sc.id.toLowerCase().contains(q) ||
          sc.label.toLowerCase().contains(q) ||
          sc.comment.toLowerCase().contains(q);
    }).toList();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: 700,
        height: 750,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.account_tree_outlined, color: theme.colorScheme.primary, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Schema.org Classes Explorer",
                        style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "Browse ${allClasses.length} Schema.org types & generate JSON-LD templates",
                        style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Search Bar
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Search Schema class (e.g. Vehicle, MedicalEntity, Movie)...",
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onChanged: (val) {
                setState(() {
                  _searchQuery = val;
                });
              },
            ),
            const SizedBox(height: 12),

            // Category Filter Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _categories.map((cat) {
                  final isSelected = _selectedCategory == cat;
                  return Padding(
                    padding: const EdgeInsets.only(right: 6.0),
                    child: ChoiceChip(
                      label: Text(cat),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() => _selectedCategory = cat);
                        }
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 12),

            // Class List
            Expanded(
              child: filteredClasses.isEmpty
                  ? Center(
                      child: Text(
                        "No matching Schema.org class found for '$_searchQuery'",
                        style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.outline),
                      ),
                    )
                  : ListView.builder(
                      itemCount: filteredClasses.length,
                      itemBuilder: (context, index) {
                        final sc = filteredClasses[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            title: Row(
                              children: [
                                Text(
                                  sc.id,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                                if (sc.subClassOf.isNotEmpty) ...[
                                  const SizedBox(width: 8),
                                  Chip(
                                    label: Text("Subclass of ${sc.subClassOf.join(', ')}"),
                                    visualDensity: VisualDensity.compact,
                                    labelStyle: theme.textTheme.labelSmall,
                                  ),
                                ],
                              ],
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (sc.comment.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    sc.comment,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.textTheme.bodySmall,
                                  ),
                                ],
                                if (sc.properties.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    "Properties (${sc.properties.length}): ${sc.properties.take(5).join(', ')}${sc.properties.length > 5 ? '...' : ''}",
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: theme.colorScheme.secondary,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            trailing: ElevatedButton.icon(
                              icon: const Icon(Icons.code, size: 16),
                              label: const Text("Use Template"),
                              onPressed: () {
                                final sampleCode = widget.controller.generateSampleJsonLdForClass(sc.id);
                                widget.onSelectSample(sampleCode);
                                Navigator.of(context).pop();
                              },
                              style: ElevatedButton.styleFrom(
                                visualDensity: VisualDensity.compact,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

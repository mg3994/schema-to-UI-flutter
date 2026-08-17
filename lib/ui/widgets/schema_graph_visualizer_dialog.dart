import 'package:flutter/material.dart';
import '../../services/json_ld_parser.dart';

class SchemaGraphVisualizerDialog extends StatelessWidget {
  final JsonLdNode rootNode;

  const SchemaGraphVisualizerDialog({super.key, required this.rootNode});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final nodesList = _collectNodes(rootNode);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: 700,
        height: 600,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.hub, color: theme.colorScheme.primary, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Linked Data Network Graph Visualizer",
                        style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "Connected Schema.org nodes (${nodesList.length} entities)",
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
            Expanded(
              child: ListView.builder(
                itemCount: nodesList.length,
                itemBuilder: (context, index) {
                  final item = nodesList[index];
                  final node = item['node'] as JsonLdNode;
                  final role = item['role'] as String;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: theme.colorScheme.primaryContainer,
                        child: Icon(Icons.extension, color: theme.colorScheme.onPrimaryContainer, size: 20),
                      ),
                      title: Row(
                        children: [
                          Text(node.primaryType, style: const TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(width: 8),
                          Chip(
                            label: Text("Role: $role"),
                            visualDensity: VisualDensity.compact,
                          ),
                        ],
                      ),
                      subtitle: Text(
                        "ID: ${node.id ?? 'Inline Entity'} • Fields: ${node.fields.keys.take(4).join(', ')}",
                        style: theme.textTheme.bodySmall,
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

  List<Map<String, dynamic>> _collectNodes(JsonLdNode root) {
    final List<Map<String, dynamic>> list = [];

    void traverse(JsonLdNode n, String role) {
      list.add({'role': role, 'node': n});
      n.fields.forEach((k, v) {
        if (v.value is JsonLdNode) {
          traverse(v.value as JsonLdNode, k);
        } else if (v.value is List) {
          for (var item in v.value as List) {
            if (item is JsonLdNode) {
              traverse(item, k);
            }
          }
        }
      });
    }

    traverse(root, 'Root');
    return list;
  }
}

import 'package:flutter/material.dart';
import '../../services/json_ld_parser.dart';

class UniversalSchemaWidget extends StatelessWidget {
  final JsonLdNode node;
  final int depth;

  const UniversalSchemaWidget({
    super.key,
    required this.node,
    this.depth = 0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final String typeName = node.primaryType;

    // Filter fields to extract title, image, and description if available
    String? title = _extractTitle();
    String? description = _extractDescription();
    List<String> imageUrls = _extractImageUrls();

    final remainingFields = Map<String, JsonLdField>.from(node.fields)
      ..removeWhere((key, val) =>
          key.toLowerCase() == 'name' ||
          key.toLowerCase() == 'headline' ||
          key.toLowerCase() == 'title' ||
          key.toLowerCase() == 'description' ||
          key.toLowerCase() == 'image');

    return Card(
      margin: EdgeInsets.symmetric(
        vertical: depth == 0 ? 8.0 : 4.0,
        horizontal: depth == 0 ? 0.0 : 4.0,
      ),
      elevation: depth == 0 ? 3 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withOpacity(0.5),
          width: 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Badge / Type
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: theme.colorScheme.primaryContainer.withOpacity(0.4),
            child: Row(
              children: [
                Icon(
                  _getIconForType(typeName),
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  typeName,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const Spacer(),
                if (node.id != null)
                  Tooltip(
                    message: node.id!,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        "ID",
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Header Image Gallery / Hero
          if (imageUrls.isNotEmpty)
            SizedBox(
              height: 200,
              child: PageView.builder(
                itemCount: imageUrls.length,
                itemBuilder: (context, index) {
                  return Image.network(
                    imageUrls[index],
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: theme.colorScheme.surfaceContainerHighest,
                      child: const Center(
                        child: Icon(Icons.broken_image, size: 48, color: Colors.grey),
                      ),
                    ),
                  );
                },
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                if (title != null) ...[
                  Text(
                    title,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                ],

                // Description
                if (description != null) ...[
                  Text(
                    description,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Dynamic Remaining Fields
                if (remainingFields.isNotEmpty) ...[
                  const Divider(),
                  const SizedBox(height: 8),
                  ...remainingFields.entries.map((entry) {
                    return _buildFieldWidget(context, entry.key, entry.value, depth);
                  }),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldWidget(
      BuildContext context, String key, JsonLdField field, int currentDepth) {
    final theme = Theme.of(context);
    final String formattedKey = _formatKeyLabel(key);

    switch (field.valueType) {
      case JsonLdValueType.object:
        final childNode = field.value as JsonLdNode;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6.0),
          child: ExpansionTile(
            key: PageStorageKey("$key-$currentDepth"),
            tilePadding: EdgeInsets.zero,
            title: Text(
              formattedKey,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.secondary,
              ),
            ),
            subtitle: Text(
              "Type: ${childNode.primaryType}",
              style: theme.textTheme.bodySmall,
            ),
            children: [
              UniversalSchemaWidget(
                node: childNode,
                depth: currentDepth + 1,
              ),
            ],
          ),
        );

      case JsonLdValueType.array:
        final list = field.value as List;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6.0),
          child: ExpansionTile(
            tilePadding: EdgeInsets.zero,
            title: Text(
              "$formattedKey (${list.length} items)",
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.secondary,
              ),
            ),
            children: list.map((item) {
              if (item is JsonLdNode) {
                return UniversalSchemaWidget(
                  node: item,
                  depth: currentDepth + 1,
                );
              }
              return Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(vertical: 2),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(item.toString(), style: theme.textTheme.bodyMedium),
              );
            }).toList(),
          ),
        );

      case JsonLdValueType.image:
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                formattedKey,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.secondary,
                ),
              ),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  field.value.toString(),
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 100,
                    color: theme.colorScheme.surfaceContainerHighest,
                    child: const Center(child: Icon(Icons.broken_image)),
                  ),
                ),
              ),
            ],
          ),
        );

      case JsonLdValueType.url:
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 120,
                child: Text(
                  formattedKey,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.outline,
                  ),
                ),
              ),
              Expanded(
                child: SelectableText(
                  field.value.toString(),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        );

      case JsonLdValueType.boolean:
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            children: [
              SizedBox(
                width: 120,
                child: Text(
                  formattedKey,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.outline,
                  ),
                ),
              ),
              Chip(
                avatar: Icon(
                  field.value == true ? Icons.check_circle : Icons.cancel,
                  size: 16,
                  color: field.value == true ? Colors.green : Colors.red,
                ),
                label: Text(field.value == true ? "True" : "False"),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
        );

      default:
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 130,
                child: Text(
                  formattedKey,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.outline,
                  ),
                ),
              ),
              Expanded(
                child: SelectableText(
                  field.value.toString(),
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            ],
          ),
        );
    }
  }

  String? _extractTitle() {
    if (node.fields.containsKey('name')) return node.fields['name']!.value?.toString();
    if (node.fields.containsKey('headline')) return node.fields['headline']!.value?.toString();
    if (node.fields.containsKey('title')) return node.fields['title']!.value?.toString();
    return null;
  }

  String? _extractDescription() {
    if (node.fields.containsKey('description')) {
      return node.fields['description']!.value?.toString();
    }
    return null;
  }

  List<String> _extractImageUrls() {
    List<String> urls = [];
    if (!node.fields.containsKey('image')) return urls;

    final imgField = node.fields['image']!;
    if (imgField.value is String) {
      urls.add(imgField.value.toString());
    } else if (imgField.value is JsonLdNode) {
      final imgNode = imgField.value as JsonLdNode;
      if (imgNode.fields.containsKey('url')) {
        urls.add(imgNode.fields['url']!.value.toString());
      } else if (imgNode.fields.containsKey('contentUrl')) {
        urls.add(imgNode.fields['contentUrl']!.value.toString());
      }
    } else if (imgField.value is List) {
      for (var item in imgField.value as List) {
        if (item is String) {
          urls.add(item);
        } else if (item is JsonLdNode) {
          if (item.fields.containsKey('url')) {
            urls.add(item.fields['url']!.value.toString());
          }
        }
      }
    }
    return urls;
  }

  String _formatKeyLabel(String key) {
    if (key.isEmpty) return key;
    final result = key.replaceAllMapped(
      RegExp(r'([A-Z])'),
      (Match match) => ' ${match.group(0)}',
    );
    return result[0].toUpperCase() + result.substring(1).trim();
  }

  IconData _getIconForType(String typeName) {
    switch (typeName.toLowerCase()) {
      case 'product':
        return Icons.shopping_bag;
      case 'recipe':
        return Icons.restaurant_menu;
      case 'article':
      case 'blogposting':
      case 'newsarticle':
        return Icons.article;
      case 'event':
        return Icons.event;
      case 'person':
        return Icons.person;
      case 'organization':
      case 'corporation':
        return Icons.business;
      case 'howto':
        return Icons.build;
      case 'review':
        return Icons.star;
      case 'offer':
        return Icons.local_offer;
      case 'place':
      case 'postaladdress':
        return Icons.location_on;
      default:
        return Icons.extension;
    }
  }
}

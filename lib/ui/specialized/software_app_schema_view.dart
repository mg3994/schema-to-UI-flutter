import 'package:flutter/material.dart';
import '../../services/json_ld_parser.dart';
import '../widgets/schema_socket_widget.dart';

class SoftwareAppSchemaView extends StatelessWidget {
  final JsonLdNode node;

  const SoftwareAppSchemaView({super.key, required this.node});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final String title = node.fields['name']?.value?.toString() ?? 'Software Application';
    final String? description = node.fields['description']?.value?.toString();
    final String? operatingSystem = node.fields['operatingSystem']?.value?.toString();
    final String? applicationCategory = node.fields['applicationCategory']?.value?.toString();
    final String? downloadUrl = node.fields['downloadUrl']?.value?.toString() ?? node.fields['installUrl']?.value?.toString();
    final String? softwareVersion = node.fields['softwareVersion']?.value?.toString();
    final String? fileSize = node.fields['fileSize']?.value?.toString();
    final List<String> imageUrls = _extractImages();
    final JsonLdNode? offerNode = _extractOffer();
    final JsonLdNode? ratingNode = _extractRating();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (imageUrls.isNotEmpty)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.network(
                            imageUrls.first,
                            width: 72,
                            height: 72,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              width: 72,
                              height: 72,
                              color: theme.colorScheme.primaryContainer,
                              child: Icon(Icons.apps, size: 36, color: theme.colorScheme.onPrimaryContainer),
                            ),
                          ),
                        )
                      else
                        CircleAvatar(
                          radius: 36,
                          child: Icon(Icons.apps, size: 36, color: theme.colorScheme.onPrimaryContainer),
                        ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            if (applicationCategory != null) ...[
                              const SizedBox(height: 4),
                              Text(applicationCategory, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.outline)),
                            ],
                            if (softwareVersion != null)
                              Text("Version $softwareVersion", style: theme.textTheme.labelSmall),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  if (ratingNode != null) ...[
                    SchemaWidgetSocket(value: ratingNode, slotName: 'aggregateRating'),
                    const SizedBox(height: 12),
                  ],

                  if (description != null) ...[
                    Text(description, style: theme.textTheme.bodyMedium),
                    const SizedBox(height: 16),
                  ],

                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (operatingSystem != null)
                        Chip(
                          avatar: const Icon(Icons.devices, size: 16),
                          label: Text("OS: $operatingSystem"),
                          visualDensity: VisualDensity.compact,
                        ),
                      if (fileSize != null)
                        Chip(
                          avatar: const Icon(Icons.folder_zip, size: 16),
                          label: Text("Size: $fileSize"),
                          visualDensity: VisualDensity.compact,
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  if (offerNode != null) ...[
                    SchemaWidgetSocket(value: offerNode, slotName: 'offers'),
                    const SizedBox(height: 16),
                  ],

                  ElevatedButton.icon(
                    icon: const Icon(Icons.download),
                    label: Text(downloadUrl != null ? "Download App" : "Install Application"),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Initiating download for $title")),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<String> _extractImages() {
    List<String> res = [];
    final img = node.fields['image']?.value ?? node.fields['logo']?.value;
    if (img is String) res.add(img);
    if (img is JsonLdNode && img.fields.containsKey('url')) {
      res.add(img.fields['url']!.value.toString());
    }
    if (img is List) {
      for (var i in img) {
        if (i is String) res.add(i);
        if (i is JsonLdNode && i.fields.containsKey('url')) {
          res.add(i.fields['url']!.value.toString());
        }
      }
    }
    return res;
  }

  JsonLdNode? _extractOffer() {
    final off = node.fields['offers']?.value;
    if (off is JsonLdNode) return off;
    return null;
  }

  JsonLdNode? _extractRating() {
    final agg = node.fields['aggregateRating']?.value;
    if (agg is JsonLdNode) return agg;
    return null;
  }
}

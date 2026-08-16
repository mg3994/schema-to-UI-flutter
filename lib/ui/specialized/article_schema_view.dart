import 'package:flutter/material.dart';
import '../../services/json_ld_parser.dart';

class ArticleSchemaView extends StatelessWidget {
  final JsonLdNode node;

  const ArticleSchemaView({super.key, required this.node});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final String title = node.fields['headline']?.value?.toString() ??
        node.fields['name']?.value?.toString() ??
        'Article';
    final String? description = node.fields['description']?.value?.toString();
    final String? body = node.fields['articleBody']?.value?.toString();
    final String? datePublished = node.fields['datePublished']?.value?.toString();
    final String? author = _extractAuthorName();
    final List<String> imageUrls = _extractImages();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (imageUrls.isNotEmpty)
            Image.network(
              imageUrls.first,
              height: 240,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 180,
                color: theme.colorScheme.surfaceContainerHighest,
                child: const Icon(Icons.article, size: 64, color: Colors.grey),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    if (author != null) ...[
                      CircleAvatar(
                        radius: 16,
                        child: Text(author[0].toUpperCase()),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        author,
                        style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ],
                    const Spacer(),
                    if (datePublished != null)
                      Text(
                        datePublished.split('T').first,
                        style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
                      ),
                  ],
                ),
                const Divider(height: 32),
                if (description != null) ...[
                  Text(
                    description,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontStyle: FontStyle.italic,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                if (body != null)
                  Text(
                    body,
                    style: theme.textTheme.bodyLarge?.copyWith(height: 1.6),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String? _extractAuthorName() {
    final a = node.fields['author']?.value;
    if (a is JsonLdNode) return a.fields['name']?.value?.toString();
    if (a is String) return a;
    return null;
  }

  List<String> _extractImages() {
    List<String> res = [];
    final img = node.fields['image']?.value;
    if (img is String) res.add(img);
    if (img is JsonLdNode && img.fields.containsKey('url')) {
      res.add(img.fields['url']!.value.toString());
    }
    return res;
  }
}

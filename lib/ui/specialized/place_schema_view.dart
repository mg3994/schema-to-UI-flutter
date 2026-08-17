import 'package:flutter/material.dart';
import '../../services/json_ld_parser.dart';

class PlaceSchemaView extends StatelessWidget {
  final JsonLdNode node;

  const PlaceSchemaView({super.key, required this.node});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final String title = node.fields['name']?.value?.toString() ?? 'Place';
    final String? description = node.fields['description']?.value?.toString();
    final String? telephone = node.fields['telephone']?.value?.toString();
    final String? url = node.fields['url']?.value?.toString();
    final Map<String, String>? address = _extractAddress();
    final Map<String, String>? geo = _extractGeo();
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
                child: const Icon(Icons.location_city, size: 64, color: Colors.grey),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        node.primaryType.toUpperCase(),
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Spacer(),
                    if (telephone != null)
                      IconButton.filledTonal(
                        icon: const Icon(Icons.phone, size: 18),
                        onPressed: () {},
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                if (url != null) ...[
                  const SizedBox(height: 4),
                  SelectableText(
                    url,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ],
                if (description != null) ...[
                  const SizedBox(height: 8),
                  Text(description, style: theme.textTheme.bodyMedium),
                ],
                const SizedBox(height: 16),

                // Location Details Card
                Card(
                  elevation: 0,
                  color: theme.colorScheme.surfaceContainerLow,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        if (address != null) ...[
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.place, color: theme.colorScheme.primary),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (address['street'] != null)
                                      Text(address['street']!,
                                          style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
                                    Text(
                                      "${address['city'] ?? ''}${address['region'] != null ? ', ${address['region']}' : ''} ${address['postalCode'] ?? ''}",
                                      style: theme.textTheme.bodyMedium,
                                    ),
                                    if (address['country'] != null)
                                      Text(address['country']!, style: theme.textTheme.bodySmall),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                        if (address != null && geo != null) const Divider(height: 24),
                        if (geo != null) ...[
                          Row(
                            children: [
                              Icon(Icons.my_location, color: theme.colorScheme.secondary),
                              const SizedBox(width: 12),
                              Text(
                                "Geo Coordinates: ${geo['latitude']}, ${geo['longitude']}",
                                style: theme.textTheme.bodyMedium?.copyWith(fontFamily: 'monospace'),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Map<String, String>? _extractAddress() {
    final addr = node.fields['address']?.value;
    if (addr is JsonLdNode) {
      return {
        if (addr.fields['streetAddress']?.value != null) 'street': addr.fields['streetAddress']!.value.toString(),
        if (addr.fields['addressLocality']?.value != null) 'city': addr.fields['addressLocality']!.value.toString(),
        if (addr.fields['addressRegion']?.value != null) 'region': addr.fields['addressRegion']!.value.toString(),
        if (addr.fields['postalCode']?.value != null) 'postalCode': addr.fields['postalCode']!.value.toString(),
        if (addr.fields['addressCountry']?.value != null) 'country': addr.fields['addressCountry']!.value.toString(),
      };
    }
    return null;
  }

  Map<String, String>? _extractGeo() {
    final g = node.fields['geo']?.value;
    if (g is JsonLdNode) {
      return {
        if (g.fields['latitude']?.value != null) 'latitude': g.fields['latitude']!.value.toString(),
        if (g.fields['longitude']?.value != null) 'longitude': g.fields['longitude']!.value.toString(),
      };
    }
    return null;
  }

  List<String> _extractImages() {
    List<String> res = [];
    final img = node.fields['image']?.value;
    if (img is String) res.add(img);
    if (img is List) res.addAll(img.whereType<String>());
    return res;
  }
}

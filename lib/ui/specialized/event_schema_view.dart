import 'package:flutter/material.dart';
import '../../services/json_ld_parser.dart';

class EventSchemaView extends StatelessWidget {
  final JsonLdNode node;

  const EventSchemaView({super.key, required this.node});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final String title = node.fields['name']?.value?.toString() ?? 'Event';
    final String? description = node.fields['description']?.value?.toString();
    final String? startDate = node.fields['startDate']?.value?.toString();
    final String? endDate = node.fields['endDate']?.value?.toString();
    final String? locationName = _extractLocation();
    final String? organizer = _extractOrganizer();
    final Map<String, dynamic>? offer = _extractOffer();
    final List<String> imageUrls = _extractImages();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (imageUrls.isNotEmpty)
            Image.network(
              imageUrls.first,
              height: 260,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 200,
                color: theme.colorScheme.surfaceContainerHighest,
                child: const Icon(Icons.event, size: 64, color: Colors.grey),
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
                        "EVENT",
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Spacer(),
                    if (startDate != null)
                      Chip(
                        avatar: const Icon(Icons.calendar_today, size: 16),
                        label: Text(startDate.split('T').first),
                        visualDensity: VisualDensity.compact,
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                // Location & Dates Card
                Card(
                  elevation: 0,
                  color: theme.colorScheme.surfaceContainerLow,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        if (locationName != null)
                          Row(
                            children: [
                              Icon(Icons.location_on, color: theme.colorScheme.primary),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  locationName,
                                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                          ),
                        if (locationName != null && (startDate != null || endDate != null))
                          const Divider(height: 20),
                        if (startDate != null)
                          Row(
                            children: [
                              Icon(Icons.access_time, color: theme.colorScheme.secondary),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  "Starts: ${_formatTime(startDate)}${endDate != null ? ' | Ends: ${_formatTime(endDate)}' : ''}",
                                  style: theme.textTheme.bodyMedium,
                                ),
                              ),
                            ],
                          ),
                        if (organizer != null) ...[
                          const Divider(height: 20),
                          Row(
                            children: [
                              Icon(Icons.business, color: theme.colorScheme.tertiary),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  "Organized by $organizer",
                                  style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                if (description != null) ...[
                  Text(
                    "About This Event",
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
                  ),
                  const SizedBox(height: 20),
                ],

                if (offer != null)
                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.confirmation_number),
                    label: Text(
                      "Get Tickets (${offer['priceCurrency'] ?? '\$'}${offer['price'] ?? 'Free'})",
                    ),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(String str) {
    if (str.contains('T')) {
      final parts = str.split('T');
      return "${parts[0]} at ${parts[1].substring(0, 5)}";
    }
    return str;
  }

  String? _extractLocation() {
    final loc = node.fields['location']?.value;
    if (loc is JsonLdNode) {
      final name = loc.fields['name']?.value?.toString();
      final addr = loc.fields['address']?.value;
      if (addr is JsonLdNode) {
        final street = addr.fields['streetAddress']?.value?.toString();
        final city = addr.fields['addressLocality']?.value?.toString();
        return "${name != null ? '$name, ' : ''}${street != null ? '$street, ' : ''}${city ?? ''}";
      }
      return name;
    }
    if (loc is String) return loc;
    return null;
  }

  String? _extractOrganizer() {
    final org = node.fields['organizer']?.value;
    if (org is JsonLdNode) return org.fields['name']?.value?.toString();
    if (org is String) return org;
    return null;
  }

  Map<String, dynamic>? _extractOffer() {
    final off = node.fields['offers']?.value;
    if (off is JsonLdNode) {
      return {
        'price': off.fields['price']?.value,
        'priceCurrency': off.fields['priceCurrency']?.value,
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

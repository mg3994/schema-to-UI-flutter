import 'package:flutter/material.dart';
import '../../services/json_ld_parser.dart';
import '../../services/schema_ontology_service.dart';

/// A plug-and-play Schema Socket Widget ("female socket") that accepts any nested Schema.org node ("male plug")
/// and dynamically slots it into the best registered socket component based on ontology inheritance.
class SchemaWidgetSocket extends StatelessWidget {
  final JsonLdNode? node;
  final String slotName; // e.g. 'seller', 'brand', 'author', 'offers', 'location'
  final Widget Function(BuildContext context, JsonLdNode node)? fallbackBuilder;

  const SchemaWidgetSocket({
    super.key,
    required this.node,
    required this.slotName,
    this.fallbackBuilder,
  });

  @override
  Widget build(BuildContext context) {
    if (node == null) return const SizedBox.shrink();

    final ontology = SchemaOntologyService();
    final typeName = node!.primaryType;

    // Female socket matching registered male plugins
    if (ontology.isSubclassOf(typeName, 'Organization') || ontology.isSubclassOf(typeName, 'Person')) {
      return SellerSocketPlugin(node: node!, slotName: slotName);
    }

    if (ontology.isSubclassOf(typeName, 'Offer')) {
      return OfferSocketPlugin(node: node!);
    }

    if (ontology.isSubclassOf(typeName, 'AggregateRating') || ontology.isSubclassOf(typeName, 'Rating')) {
      return RatingSocketPlugin(node: node!);
    }

    if (ontology.isSubclassOf(typeName, 'Place') || ontology.isSubclassOf(typeName, 'PostalAddress')) {
      return PlaceSocketPlugin(node: node!);
    }

    if (fallbackBuilder != null) {
      return fallbackBuilder!(context, node!);
    }

    return GenericSocketPlugin(node: node!, slotName: slotName);
  }
}

/// Seller Socket Plugin: Plugs Person, Business, Organization, or Corporation into a rich badge card
class SellerSocketPlugin extends StatelessWidget {
  final JsonLdNode node;
  final String slotName;

  const SellerSocketPlugin({super.key, required this.node, required this.slotName});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final String name = node.fields['name']?.value?.toString() ?? 'Official Entity';
    final String? logo = _extractLogo();
    final String? email = node.fields['email']?.value?.toString();
    final String? telephone = node.fields['telephone']?.value?.toString();
    final isPerson = SchemaOntologyService().isSubclassOf(node.primaryType, 'Person');

    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.outlineVariant.withOpacity(0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            if (logo != null)
              CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage(logo),
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
              )
            else
              CircleAvatar(
                radius: 20,
                backgroundColor: isPerson ? theme.colorScheme.tertiaryContainer : theme.colorScheme.primaryContainer,
                child: Icon(
                  isPerson ? Icons.person : Icons.store,
                  color: isPerson ? theme.colorScheme.onTertiaryContainer : theme.colorScheme.onPrimaryContainer,
                  size: 20,
                ),
              ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        slotName.toUpperCase(),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.outline,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          node.primaryType,
                          style: theme.textTheme.labelSmall?.copyWith(fontSize: 10),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    name,
                    style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  if (email != null || telephone != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      "${email ?? ''}${email != null && telephone != null ? ' • ' : ''}${telephone ?? ''}",
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String? _extractLogo() {
    final l = node.fields['logo']?.value ?? node.fields['image']?.value;
    if (l is String) return l;
    if (l is JsonLdNode) return l.fields['url']?.value?.toString();
    return null;
  }
}

/// Offer Socket Plugin: Plugs Offer or AggregateOffer into a price tag badge
class OfferSocketPlugin extends StatelessWidget {
  final JsonLdNode node;

  const OfferSocketPlugin({super.key, required this.node});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final price = node.fields['price']?.value?.toString() ?? 'N/A';
    final currency = node.fields['priceCurrency']?.value?.toString() ?? '\$';
    final avail = node.fields['availability']?.value?.toString() ?? '';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: theme.colorScheme.primary.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.local_offer, size: 18, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            "$currency$price",
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          if (avail.contains('InStock')) ...[
            const SizedBox(width: 8),
            const Icon(Icons.check_circle, size: 14, color: Colors.green),
          ],
        ],
      ),
    );
  }
}

/// Rating Socket Plugin: Plugs Rating or AggregateRating into star indicators
class RatingSocketPlugin extends StatelessWidget {
  final JsonLdNode node;

  const RatingSocketPlugin({super.key, required this.node});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ratingVal = double.tryParse(node.fields['ratingValue']?.value?.toString() ?? '5') ?? 5.0;
    final count = node.fields['reviewCount']?.value?.toString() ?? node.fields['ratingCount']?.value?.toString();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...List.generate(5, (index) {
          return Icon(
            index < ratingVal.floor()
                ? Icons.star
                : (index < ratingVal ? Icons.star_half : Icons.star_border),
            color: Colors.amber,
            size: 18,
          );
        }),
        const SizedBox(width: 6),
        Text(
          ratingVal.toStringAsFixed(1),
          style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        if (count != null) ...[
          const SizedBox(width: 4),
          Text("($count)", style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline)),
        ],
      ],
    );
  }
}

/// Place Socket Plugin: Plugs Place or PostalAddress into a location chip
class PlaceSocketPlugin extends StatelessWidget {
  final JsonLdNode node;

  const PlaceSocketPlugin({super.key, required this.node});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final name = node.fields['name']?.value?.toString();
    final street = node.fields['streetAddress']?.value?.toString();
    final city = node.fields['addressLocality']?.value?.toString();

    final label = "${name != null ? '$name, ' : ''}${street != null ? '$street, ' : ''}${city ?? ''}";

    return Chip(
      avatar: Icon(Icons.place, size: 16, color: theme.colorScheme.primary),
      label: Text(label.isNotEmpty ? label : "Location"),
      visualDensity: VisualDensity.compact,
    );
  }
}

/// Generic Socket Plugin for fallback node types
class GenericSocketPlugin extends StatelessWidget {
  final JsonLdNode node;
  final String slotName;

  const GenericSocketPlugin({super.key, required this.node, required this.slotName});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final name = node.fields['name']?.value?.toString() ?? node.primaryType;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        "$slotName: $name (${node.primaryType})",
        style: theme.textTheme.bodySmall,
      ),
    );
  }
}

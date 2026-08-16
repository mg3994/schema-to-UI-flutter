import 'package:flutter/material.dart';
import '../../services/json_ld_parser.dart';
import '../../services/schema_ontology_service.dart';
import '../../services/schema_enum_resolver.dart';

/// Universal Plug-and-Play Socket Manager that accepts any nested Schema.org node or value
/// and dynamically slots it into the best fitting component socket.
class SchemaWidgetSocket extends StatelessWidget {
  final dynamic value; // JsonLdNode, List, String (Enum URL), or Primitive
  final String slotName; // e.g., 'seller', 'availability', 'location', 'addOn', 'subjectOf'

  const SchemaWidgetSocket({
    super.key,
    required this.value,
    required this.slotName,
  });

  @override
  Widget build(BuildContext context) {
    if (value == null) return const SizedBox.shrink();

    // Handle String / Enum URLs
    if (value is String) {
      final str = value.toString();
      if (str.startsWith('https://schema.org/') || str.startsWith('http://schema.org/') || str.startsWith('schema:')) {
        final enumDetails = SchemaEnumResolver.resolve(str);
        return EnumSocketPlugin(details: enumDetails);
      }
      return SelectableText(str);
    }

    // Handle Lists
    if (value is List) {
      final list = value as List;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: list.map((item) => SchemaWidgetSocket(value: item, slotName: slotName)).toList(),
      );
    }

    // Handle JsonLdNode
    if (value is JsonLdNode) {
      final node = value as JsonLdNode;
      final ontology = SchemaOntologyService();
      final typeName = node.primaryType;

      if (ontology.isSubclassOf(typeName, 'Organization') || ontology.isSubclassOf(typeName, 'Person')) {
        return SellerSocketPlugin(node: node, slotName: slotName);
      }

      if (ontology.isSubclassOf(typeName, 'Offer')) {
        return OfferSocketPlugin(node: node);
      }

      if (ontology.isSubclassOf(typeName, 'AggregateRating') || ontology.isSubclassOf(typeName, 'Rating')) {
        return RatingSocketPlugin(node: node);
      }

      if (ontology.isSubclassOf(typeName, 'Place') || ontology.isSubclassOf(typeName, 'PostalAddress') || ontology.isSubclassOf(typeName, 'AdministrativeArea')) {
        return PlaceSocketPlugin(node: node);
      }

      if (ontology.isSubclassOf(typeName, 'QuantitativeValue')) {
        return QuantitativeValueSocketPlugin(node: node, slotName: slotName);
      }

      if (ontology.isSubclassOf(typeName, '3DModel') || typeName == '3DModel') {
        return Model3DSocketPlugin(node: node);
      }

      if (ontology.isSubclassOf(typeName, 'Certification')) {
        return CertificationSocketPlugin(node: node);
      }

      return GenericNodeSocketPlugin(node: node, slotName: slotName);
    }

    return SelectableText(value.toString());
  }
}

/// Enum Socket Plugin
class EnumSocketPlugin extends StatelessWidget {
  final SchemaEnumDetails details;

  const EnumSocketPlugin({super.key, required this.details});

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(details.icon, size: 16, color: details.color),
      label: Text(details.formattedLabel),
      side: BorderSide(color: details.color.withOpacity(0.4)),
      backgroundColor: details.color.withOpacity(0.1),
      visualDensity: VisualDensity.compact,
    );
  }
}

/// Seller Socket Plugin: Plugs Person, Business, Organization, or Store into a rich badge card
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

/// Offer Socket Plugin: Plugs Offer or AggregateOffer
class OfferSocketPlugin extends StatelessWidget {
  final JsonLdNode node;

  const OfferSocketPlugin({super.key, required this.node});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final price = node.fields['price']?.value?.toString() ?? 'N/A';
    final currency = node.fields['priceCurrency']?.value?.toString() ?? 'INR';
    final avail = node.fields['availability']?.value;
    final itemOffered = node.fields['itemOffered']?.value;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: theme.colorScheme.primary.withOpacity(0.2)),
      ),
      child: Wrap(
        cross: WrapCrossAlignment.center,
        spacing: 8,
        children: [
          Icon(Icons.local_offer, size: 18, color: theme.colorScheme.primary),
          Text(
            "$currency $price",
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          if (itemOffered is JsonLdNode) ...[
            Text(
              "for ${itemOffered.fields['name']?.value?.toString() ?? ''}",
              style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
          if (avail != null) SchemaWidgetSocket(value: avail, slotName: 'availability'),
        ],
      ),
    );
  }
}

/// Rating Socket Plugin
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

/// Place Socket Plugin
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

/// Quantitative Value Socket Plugin
class QuantitativeValueSocketPlugin extends StatelessWidget {
  final JsonLdNode node;
  final String slotName;

  const QuantitativeValueSocketPlugin({super.key, required this.node, required this.slotName});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final val = node.fields['value']?.value?.toString() ??
        "${node.fields['minValue']?.value?.toString() ?? ''}-${node.fields['maxValue']?.value?.toString() ?? ''}";
    final unit = node.fields['unitCode']?.value?.toString() ?? '';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        "$slotName: $val $unit",
        style: theme.textTheme.labelSmall?.copyWith(fontFamily: 'monospace'),
      ),
    );
  }
}

/// 3D Model Socket Plugin (AR Camera View Ready)
class Model3DSocketPlugin extends StatelessWidget {
  final JsonLdNode node;

  const Model3DSocketPlugin({super.key, required this.node});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final encoding = node.fields['encoding']?.value;
    String? contentUrl;
    if (encoding is JsonLdNode) {
      contentUrl = encoding.fields['contentUrl']?.value?.toString();
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.tertiaryContainer.withOpacity(0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.tertiary.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          Icon(Icons.view_in_ar, size: 28, color: theme.colorScheme.tertiary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("3D Model / AR Interactive Preview",
                    style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                if (contentUrl != null)
                  Text(contentUrl,
                      maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.textTheme.bodySmall),
              ],
            ),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.view_in_ar, size: 16),
            label: const Text("Launch AR"),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Launching 3D AR View for $contentUrl")),
              );
            },
            style: ElevatedButton.styleFrom(visualDensity: VisualDensity.compact),
          ),
        ],
      ),
    );
  }
}

/// Certification Socket Plugin
class CertificationSocketPlugin extends StatelessWidget {
  final JsonLdNode node;

  const CertificationSocketPlugin({super.key, required this.node});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final certName = node.fields['name']?.value?.toString() ?? 'Certified';
    final certId = node.fields['certificationIdentification']?.value?.toString();

    return Chip(
      avatar: const Icon(Icons.verified, size: 16, color: Colors.blue),
      label: Text("$certName ${certId != null ? '(#$certId)' : ''}"),
      visualDensity: VisualDensity.compact,
    );
  }
}

/// Generic Node Socket Plugin for fallback node types
class GenericNodeSocketPlugin extends StatelessWidget {
  final JsonLdNode node;
  final String slotName;

  const GenericNodeSocketPlugin({super.key, required this.node, required this.slotName});

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

import 'package:flutter/material.dart';
import '../../services/json_ld_parser.dart';
import '../widgets/schema_socket_widget.dart';

class ProductGroupSchemaView extends StatefulWidget {
  final JsonLdNode node;

  const ProductGroupSchemaView({super.key, required this.node});

  @override
  State<ProductGroupSchemaView> createState() => _ProductGroupSchemaViewState();
}

class _ProductGroupSchemaViewState extends State<ProductGroupSchemaView> {
  int _selectedVariantIndex = 0;
  final Set<String> _selectedAddonNames = {};

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final String title = widget.node.fields['name']?.value?.toString() ?? 'Product Group';
    final String? description = widget.node.fields['description']?.value?.toString();
    final String? pattern = widget.node.fields['pattern']?.value?.toString();
    final String? brand = _extractBrandName(widget.node);
    final List<String> variesBy = _extractVariesBy();
    final List<JsonLdNode> variants = _extractVariants();
    final JsonLdNode? audienceNode = _extractAudienceNode();

    JsonLdNode? activeVariant = variants.isNotEmpty && _selectedVariantIndex < variants.length
        ? variants[_selectedVariantIndex]
        : null;

    final basePrice = _extractVariantPrice(activeVariant ?? widget.node);
    final currency = _extractVariantCurrency(activeVariant ?? widget.node);
    final imageUrls = _extractImages(activeVariant ?? widget.node);
    final List<JsonLdNode> variantAddons = _extractVariantAddons(activeVariant);
    final JsonLdNode? model3dNode = _extract3DModelNode(activeVariant);
    final JsonLdNode? certNode = _extractCertNode(activeVariant);
    final JsonLdNode? sellerNode = _extractSellerNode(activeVariant);

    double addonTotal = 0.0;
    for (var addonOffer in variantAddons) {
      final itemOffered = addonOffer.fields['itemOffered']?.value;
      String name = 'Addon';
      if (itemOffered is JsonLdNode) {
        name = itemOffered.fields['name']?.value?.toString() ?? 'Addon';
      }
      if (_selectedAddonNames.contains(name)) {
        addonTotal += _extractOfferPrice(addonOffer);
      }
    }

    final double totalPrice = basePrice + addonTotal;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Hero / Variant Image Gallery
          if (imageUrls.isNotEmpty)
            SizedBox(
              height: 300,
              child: Stack(
                children: [
                  PageView.builder(
                    itemCount: imageUrls.length,
                    itemBuilder: (context, index) {
                      return Image.network(
                        imageUrls[index],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: theme.colorScheme.surfaceContainerHighest,
                          child: const Icon(Icons.broken_image, size: 64, color: Colors.grey),
                        ),
                      );
                    },
                  ),
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        "PRODUCT GROUP & VARIANTS",
                        style: TextStyle(
                          color: theme.colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Brand, Pattern, & Audience Badges
                Row(
                  children: [
                    if (brand != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.secondaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          brand.toUpperCase(),
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: theme.colorScheme.onSecondaryContainer,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    if (pattern != null) ...[
                      const SizedBox(width: 8),
                      Chip(
                        label: Text("Pattern: $pattern"),
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                    const Spacer(),
                    if (audienceNode != null)
                      SchemaWidgetSocket(value: audienceNode, slotName: 'audience'),
                  ],
                ),
                const SizedBox(height: 8),

                // Main Variant Title
                Text(
                  activeVariant?.fields['name']?.value?.toString() ?? title,
                  style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),

                // Price & Availability Card
                Card(
                  elevation: 0,
                  color: theme.colorScheme.surfaceContainerHigh,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Calculated Total Price",
                                    style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.outline)),
                                const SizedBox(height: 4),
                                Text(
                                  "$currency ${totalPrice.toStringAsFixed(2)}",
                                  style: theme.textTheme.headlineMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            if (activeVariant != null && activeVariant.fields.containsKey('offers'))
                              SchemaWidgetSocket(
                                value: activeVariant.fields['offers']?.value,
                                slotName: 'offers',
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // 3D Model Socket Plugin (AR Preview)
                if (model3dNode != null) ...[
                  SchemaWidgetSocket(value: model3dNode, slotName: 'subjectOf'),
                  const SizedBox(height: 12),
                ],

                // Certification Socket
                if (certNode != null) ...[
                  SchemaWidgetSocket(value: certNode, slotName: 'hasCertification'),
                  const SizedBox(height: 12),
                ],

                // Variant Selectors (variesBy Color, Size, Material)
                if (variants.isNotEmpty) ...[
                  Row(
                    children: [
                      Text("Select Variant", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      if (variesBy.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Text("(${variesBy.join(', ')})",
                            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline)),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: variants.asMap().entries.map((entry) {
                      final idx = entry.key;
                      final v = entry.value;
                      final isSelected = _selectedVariantIndex == idx;
                      final color = v.fields['color']?.value?.toString();
                      final size = v.fields['size']?.value?.toString();
                      final material = v.fields['material']?.value?.toString();
                      final vName = color ?? size ?? material ?? v.fields['name']?.value?.toString() ?? "Variant ${idx + 1}";

                      return ChoiceChip(
                        selected: isSelected,
                        label: Text(vName),
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _selectedVariantIndex = idx;
                              _selectedAddonNames.clear(); // Reset addons on variant switch
                            });
                          }
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                ],

                // Variant Specific AddOn Services / Accessories
                if (variantAddons.isNotEmpty) ...[
                  Text(
                    "Optional AddOns & Customizations for Selected Variant",
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ...variantAddons.map((addonOffer) {
                    final itemOffered = addonOffer.fields['itemOffered']?.value;
                    String addonName = 'Custom Addon';
                    if (itemOffered is JsonLdNode) {
                      addonName = itemOffered.fields['name']?.value?.toString() ?? 'Custom Addon';
                    }
                    final price = _extractOfferPrice(addonOffer);
                    final isChecked = _selectedAddonNames.contains(addonName);
                    final areaServed = addonOffer.fields['areaServed']?.value;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            CheckboxListTile(
                              value: isChecked,
                              title: Text(addonName, style: const TextStyle(fontWeight: FontWeight.w600)),
                              secondary: Text(
                                "+$currency ${price.toStringAsFixed(2)}",
                                style: theme.textTheme.titleSmall?.copyWith(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              onChanged: (val) {
                                setState(() {
                                  if (val == true) {
                                    _selectedAddonNames.add(addonName);
                                  } else {
                                    _selectedAddonNames.remove(addonName);
                                  }
                                });
                              },
                            ),
                            if (areaServed != null) ...[
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 16.0),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text("Service Areas:", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                child: SchemaWidgetSocket(value: areaServed, slotName: 'areaServed'),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 20),
                ],

                // Seller / Store Socket Slot Plugin
                if (sellerNode != null) ...[
                  SchemaWidgetSocket(value: sellerNode, slotName: 'seller'),
                  const SizedBox(height: 16),
                ],

                // Description
                if (description != null) ...[
                  Text("Product Series Overview", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text(description, style: theme.textTheme.bodyMedium?.copyWith(height: 1.4)),
                  const SizedBox(height: 20),
                ],

                // Action Button
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.add_shopping_cart),
                  label: Text("Add Selected Configuration to Cart ($currency ${totalPrice.toStringAsFixed(2)})"),
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

  String? _extractBrandName(JsonLdNode n) {
    final b = n.fields['brand']?.value;
    if (b is JsonLdNode) return b.fields['name']?.value?.toString();
    if (b is String) return b;
    return null;
  }

  JsonLdNode? _extractAudienceNode() {
    final aud = widget.node.fields['audience']?.value;
    if (aud is JsonLdNode) return aud;
    return null;
  }

  List<String> _extractVariesBy() {
    List<String> res = [];
    final v = widget.node.fields['variesBy']?.value;
    if (v is List) {
      for (var item in v) {
        if (item is String) {
          res.add(item.replaceFirst('https://schema.org/', ''));
        }
      }
    } else if (v is String) {
      res.add(v.replaceFirst('https://schema.org/', ''));
    }
    return res;
  }

  List<JsonLdNode> _extractVariants() {
    List<JsonLdNode> res = [];
    final hv = widget.node.fields['hasVariant']?.value;
    if (hv is List) {
      res.addAll(hv.whereType<JsonLdNode>());
    } else if (hv is JsonLdNode) {
      res.add(hv);
    }
    return res;
  }

  List<JsonLdNode> _extractVariantAddons(JsonLdNode? variant) {
    List<JsonLdNode> res = [];
    if (variant == null) return res;

    final addOn = variant.fields['addOn']?.value;
    if (addOn is List) {
      res.addAll(addOn.whereType<JsonLdNode>());
    } else if (addOn is JsonLdNode) {
      res.add(addOn);
    }
    return res;
  }

  JsonLdNode? _extract3DModelNode(JsonLdNode? variant) {
    if (variant == null) return null;
    final sub = variant.fields['subjectOf']?.value;
    if (sub is JsonLdNode) return sub;
    return null;
  }

  JsonLdNode? _extractCertNode(JsonLdNode? variant) {
    if (variant == null) return null;
    final cert = variant.fields['hasCertification']?.value;
    if (cert is JsonLdNode) return cert;
    return null;
  }

  JsonLdNode? _extractSellerNode(JsonLdNode? variant) {
    if (variant == null) return null;
    final off = variant.fields['offers']?.value;
    if (off is JsonLdNode && off.fields.containsKey('seller')) {
      final s = off.fields['seller']!.value;
      if (s is JsonLdNode) return s;
    }
    return null;
  }

  double _extractVariantPrice(JsonLdNode n) {
    final off = n.fields['offers']?.value;
    if (off is JsonLdNode) {
      final p = off.fields['price']?.value;
      if (p is num) return p.toDouble();
      if (p is String) return double.tryParse(p) ?? 0.0;
    }
    final directP = n.fields['price']?.value;
    if (directP is num) return directP.toDouble();
    if (directP is String) return double.tryParse(directP) ?? 0.0;
    return 0.0;
  }

  double _extractOfferPrice(JsonLdNode offerNode) {
    final p = offerNode.fields['price']?.value;
    if (p is num) return p.toDouble();
    if (p is String) return double.tryParse(p) ?? 0.0;
    return 0.0;
  }

  String _extractVariantCurrency(JsonLdNode n) {
    final off = n.fields['offers']?.value;
    if (off is JsonLdNode) {
      return off.fields['priceCurrency']?.value?.toString() ?? 'INR';
    }
    return 'INR';
  }

  List<String> _extractImages(JsonLdNode n) {
    List<String> res = [];
    final img = n.fields['image']?.value;
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
}

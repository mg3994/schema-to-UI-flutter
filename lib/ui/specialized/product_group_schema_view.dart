import 'package:flutter/material.dart';
import '../../services/json_ld_parser.dart';

class ProductGroupSchemaView extends StatefulWidget {
  final JsonLdNode node;

  const ProductGroupSchemaView({super.key, required this.node});

  @override
  State<ProductGroupSchemaView> createState() => _ProductGroupSchemaViewState();
}

class _ProductGroupSchemaViewState extends State<ProductGroupSchemaView> {
  int _selectedVariantIndex = 0;
  final Set<String> _selectedAddonIds = {};

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final String title = widget.node.fields['name']?.value?.toString() ?? 'Product Group';
    final String? description = widget.node.fields['description']?.value?.toString();
    final String? brand = _extractBrandName(widget.node);
    final List<String> variesBy = _extractVariesBy();
    final List<JsonLdNode> variants = _extractVariants();
    final List<JsonLdNode> addons = _extractAddons();

    JsonLdNode? activeVariant = variants.isNotEmpty && _selectedVariantIndex < variants.length
        ? variants[_selectedVariantIndex]
        : null;

    final basePrice = _extractVariantPrice(activeVariant ?? widget.node);
    final currency = _extractVariantCurrency(activeVariant ?? widget.node);
    final imageUrls = _extractImages(activeVariant ?? widget.node);

    double addonTotal = 0.0;
    for (var addon in addons) {
      final addonId = addon.fields['name']?.value?.toString() ?? '';
      if (_selectedAddonIds.contains(addonId)) {
        addonTotal += _extractVariantPrice(addon);
      }
    }

    final double totalPrice = basePrice + addonTotal;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Carousel or Hero Image
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
                const SizedBox(height: 8),

                // Main Title
                Text(
                  activeVariant?.fields['name']?.value?.toString() ?? title,
                  style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),

                // Price Card with Addons calculation
                Card(
                  elevation: 0,
                  color: theme.colorScheme.surfaceContainerHigh,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Total Configured Price",
                                style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.outline)),
                            const SizedBox(height: 4),
                            Text(
                              "$currency${totalPrice.toStringAsFixed(2)}",
                              style: theme.textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Chip(
                          avatar: const Icon(Icons.check_circle, color: Colors.green, size: 18),
                          label: const Text("In Stock"),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Variant Selectors
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
                      final vName = v.fields['name']?.value?.toString() ??
                          v.fields['color']?.value?.toString() ??
                          v.fields['size']?.value?.toString() ??
                          "Variant ${idx + 1}";

                      return ChoiceChip(
                        selected: isSelected,
                        label: Text(vName),
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _selectedVariantIndex = idx;
                            });
                          }
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                ],

                // Product Addons / Nesting Section
                if (addons.isNotEmpty) ...[
                  Text(
                    "Available Addons & Customizations",
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ...addons.map((addon) {
                    final addonName = addon.fields['name']?.value?.toString() ?? 'Addon Option';
                    final addonDesc = addon.fields['description']?.value?.toString();
                    final price = _extractVariantPrice(addon);
                    final isChecked = _selectedAddonIds.contains(addonName);

                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: CheckboxListTile(
                        value: isChecked,
                        title: Text(addonName, style: const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: addonDesc != null ? Text(addonDesc) : null,
                        secondary: Text(
                          "+$currency${price.toStringAsFixed(2)}",
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onChanged: (val) {
                          setState(() {
                            if (val == true) {
                              _selectedAddonIds.add(addonName);
                            } else {
                              _selectedAddonIds.remove(addonName);
                            }
                          });
                        },
                      ),
                    );
                  }),
                  const SizedBox(height: 20),
                ],

                // Description
                if (description != null) ...[
                  Text("Product Overview", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text(description, style: theme.textTheme.bodyMedium?.copyWith(height: 1.4)),
                  const SizedBox(height: 20),
                ],

                // Action Button
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.add_shopping_cart),
                  label: Text("Add Configured Product to Cart ($currency${totalPrice.toStringAsFixed(2)})"),
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

  List<JsonLdNode> _extractAddons() {
    List<JsonLdNode> res = [];
    void check(dynamic val) {
      if (val is JsonLdNode) res.add(val);
      if (val is List) res.addAll(val.whereType<JsonLdNode>());
    }

    check(widget.node.fields['isRelatedTo']?.value);
    check(widget.node.fields['addOn']?.value);
    check(widget.node.fields['hasOption']?.value);
    return res;
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

  String _extractVariantCurrency(JsonLdNode n) {
    final off = n.fields['offers']?.value;
    if (off is JsonLdNode) {
      return off.fields['priceCurrency']?.value?.toString() ?? '\$';
    }
    return '\$';
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

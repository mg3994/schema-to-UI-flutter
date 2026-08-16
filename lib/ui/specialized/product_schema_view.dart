import 'package:flutter/material.dart';
import '../../services/json_ld_parser.dart';

class ProductSchemaView extends StatelessWidget {
  final JsonLdNode node;

  const ProductSchemaView({super.key, required this.node});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final String title = node.fields['name']?.value?.toString() ?? 'Unnamed Product';
    final String? description = node.fields['description']?.value?.toString();
    final String? brand = _extractBrandName();
    final String? sku = node.fields['sku']?.value?.toString() ?? node.fields['gtin']?.value?.toString();
    final List<String> imageUrls = _extractImages();

    final Map<String, dynamic>? offer = _extractOffer();
    final Map<String, dynamic>? rating = _extractRating();
    final List<JsonLdNode> reviews = _extractReviews();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // E-Commerce Image Carousel / Hero Image
          if (imageUrls.isNotEmpty)
            SizedBox(
              height: 320,
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
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        "Product",
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
                // Brand & SKU Header
                Row(
                  children: [
                    if (brand != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          brand.toUpperCase(),
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: theme.colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    const Spacer(),
                    if (sku != null)
                      Text(
                        "SKU: $sku",
                        style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
                      ),
                  ],
                ),
                const SizedBox(height: 12),

                // Title
                Text(
                  title,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),

                // Rating & Review Count
                if (rating != null) ...[
                  Row(
                    children: [
                      ...List.generate(5, (index) {
                        final double score = double.tryParse(rating['ratingValue']?.toString() ?? '5') ?? 5;
                        return Icon(
                          index < score.floor()
                              ? Icons.star
                              : (index < score ? Icons.star_half : Icons.star_border),
                          color: Colors.amber,
                          size: 20,
                        );
                      }),
                      const SizedBox(width: 8),
                      Text(
                        "${rating['ratingValue'] ?? '5.0'}",
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      if (rating['reviewCount'] != null) ...[
                        const SizedBox(width: 4),
                        Text(
                          "(${rating['reviewCount']} reviews)",
                          style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.outline),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 16),
                ],

                // Offer / Price Tag Card
                if (offer != null) ...[
                  Card(
                    color: theme.colorScheme.surfaceContainerHigh,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Price",
                                style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.outline),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "${offer['priceCurrency'] ?? '\$'}${offer['price'] ?? 'N/A'}",
                                style: theme.textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          if (offer['availability'] != null) ...[
                            Chip(
                              avatar: Icon(
                                offer['availability'].toString().contains('InStock')
                                    ? Icons.check_circle
                                    : Icons.remove_circle,
                                color: offer['availability'].toString().contains('InStock')
                                    ? Colors.green
                                    : Colors.orange,
                              ),
                              label: Text(
                                offer['availability'].toString().contains('InStock')
                                    ? "In Stock"
                                    : "Out of Stock",
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Description
                if (description != null) ...[
                  Text(
                    "About this item",
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
                  ),
                  const SizedBox(height: 20),
                ],

                // Action Button (Simulated Ecommerce Add to Cart)
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.shopping_cart),
                  label: const Text("Add to Shopping Cart"),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 24),

                // Reviews Section
                if (reviews.isNotEmpty) ...[
                  Text(
                    "Customer Reviews",
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  ...reviews.map((rev) {
                    final author = rev.fields['author']?.value;
                    String authorName = "Anonymous";
                    if (author is JsonLdNode) {
                      authorName = author.fields['name']?.value?.toString() ?? "Anonymous";
                    } else if (author is String) {
                      authorName = author;
                    }
                    final body = rev.fields['reviewBody']?.value?.toString() ?? '';

                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(child: Text(authorName[0])),
                        title: Text(authorName),
                        subtitle: Text(body),
                      ),
                    );
                  }),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String? _extractBrandName() {
    final b = node.fields['brand']?.value;
    if (b is JsonLdNode) return b.fields['name']?.value?.toString();
    if (b is String) return b;
    return null;
  }

  List<String> _extractImages() {
    List<String> res = [];
    final img = node.fields['image']?.value;
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

  Map<String, dynamic>? _extractOffer() {
    final off = node.fields['offers']?.value;
    if (off is JsonLdNode) {
      return {
        'price': off.fields['price']?.value,
        'priceCurrency': off.fields['priceCurrency']?.value,
        'availability': off.fields['availability']?.value,
      };
    }
    return null;
  }

  Map<String, dynamic>? _extractRating() {
    final agg = node.fields['aggregateRating']?.value;
    if (agg is JsonLdNode) {
      return {
        'ratingValue': agg.fields['ratingValue']?.value,
        'reviewCount': agg.fields['reviewCount']?.value,
      };
    }
    return null;
  }

  List<JsonLdNode> _extractReviews() {
    final rev = node.fields['review']?.value;
    if (rev is JsonLdNode) return [rev];
    if (rev is List) {
      return rev.whereType<JsonLdNode>().toList();
    }
    return [];
  }
}

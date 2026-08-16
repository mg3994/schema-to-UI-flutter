import 'package:flutter/material.dart';
import '../../services/json_ld_parser.dart';

class RecipeSchemaView extends StatelessWidget {
  final JsonLdNode node;

  const RecipeSchemaView({super.key, required this.node});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final String title = node.fields['name']?.value?.toString() ?? 'Recipe';
    final String? description = node.fields['description']?.value?.toString();
    final String? prepTime = node.fields['prepTime']?.value?.toString();
    final String? cookTime = node.fields['cookTime']?.value?.toString();
    final String? yieldStr = node.fields['recipeYield']?.value?.toString();
    final List<String> imageUrls = _extractImages();
    final List<String> ingredients = _extractIngredients();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (imageUrls.isNotEmpty)
            Image.network(
              imageUrls.first,
              height: 250,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 200,
                color: theme.colorScheme.surfaceContainerHighest,
                child: const Icon(Icons.restaurant, size: 64, color: Colors.grey),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                if (description != null) ...[
                  const SizedBox(height: 8),
                  Text(description, style: theme.textTheme.bodyMedium),
                ],
                const SizedBox(height: 16),
                Card(
                  elevation: 0,
                  color: theme.colorScheme.surfaceContainerLow,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        if (prepTime != null)
                          _buildStatItem(context, Icons.timer, "Prep", prepTime),
                        if (cookTime != null)
                          _buildStatItem(context, Icons.outdoor_grill, "Cook", cookTime),
                        if (yieldStr != null)
                          _buildStatItem(context, Icons.people, "Servings", yieldStr),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                if (ingredients.isNotEmpty) ...[
                  Text(
                    "Ingredients",
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ...ingredients.map((ing) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
                          children: [
                            const Icon(Icons.check_box_outlined, size: 20, color: Colors.green),
                            const SizedBox(width: 8),
                            Expanded(child: Text(ing, style: theme.textTheme.bodyLarge)),
                          ],
                        ),
                      )),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, IconData icon, String label, String value) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Icon(icon, color: theme.colorScheme.primary),
        const SizedBox(height: 4),
        Text(label, style: theme.textTheme.labelSmall),
        Text(value, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
      ],
    );
  }

  List<String> _extractImages() {
    List<String> res = [];
    final img = node.fields['image']?.value;
    if (img is String) res.add(img);
    if (img is List) res.addAll(img.whereType<String>());
    return res;
  }

  List<String> _extractIngredients() {
    List<String> res = [];
    final ing = node.fields['recipeIngredient']?.value;
    if (ing is List) {
      for (var item in ing) {
        if (item is String) res.add(item);
      }
    } else if (ing is String) {
      res.add(ing);
    }
    return res;
  }
}

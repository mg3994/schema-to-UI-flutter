import 'package:flutter/material.dart';
import '../../services/json_ld_parser.dart';

class HowToSchemaView extends StatelessWidget {
  final JsonLdNode node;

  const HowToSchemaView({super.key, required this.node});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final String title = node.fields['name']?.value?.toString() ?? 'HowTo Guide';
    final String? description = node.fields['description']?.value?.toString();
    final String? totalTime = node.fields['totalTime']?.value?.toString();
    final String? estimatedCost = node.fields['estimatedCost']?.value?.toString();
    final List<String> imageUrls = _extractImages();
    final List<String> supplies = _extractList('supply');
    final List<String> tools = _extractList('tool');
    final List<Map<String, String>> steps = _extractSteps();

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
                child: const Icon(Icons.build, size: 64, color: Colors.grey),
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
                        "HOW-TO GUIDE",
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Spacer(),
                    if (totalTime != null)
                      Chip(
                        avatar: const Icon(Icons.timer_outlined, size: 16),
                        label: Text(totalTime),
                        visualDensity: VisualDensity.compact,
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                if (description != null) ...[
                  const SizedBox(height: 8),
                  Text(description, style: theme.textTheme.bodyMedium),
                ],
                const SizedBox(height: 16),

                if (supplies.isNotEmpty || tools.isNotEmpty || estimatedCost != null) ...[
                  Card(
                    color: theme.colorScheme.surfaceContainerLow,
                    elevation: 0,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (estimatedCost != null) ...[
                            Text("Estimated Cost: $estimatedCost",
                                style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                          ],
                          if (supplies.isNotEmpty) ...[
                            Text("Supplies Needed:", style: theme.textTheme.labelLarge),
                            const SizedBox(height: 4),
                            Wrap(
                              spacing: 8,
                              children: supplies
                                  .map((s) => Chip(
                                        label: Text(s),
                                        visualDensity: VisualDensity.compact,
                                      ))
                                  .toList(),
                            ),
                          ],
                          if (tools.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text("Tools Required:", style: theme.textTheme.labelLarge),
                            const SizedBox(height: 4),
                            Wrap(
                              spacing: 8,
                              children: tools
                                  .map((t) => Chip(
                                        avatar: const Icon(Icons.handyman, size: 14),
                                        label: Text(t),
                                        visualDensity: VisualDensity.compact,
                                      ))
                                  .toList(),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                if (steps.isNotEmpty) ...[
                  Text(
                    "Step-by-Step Instructions",
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  ...steps.asMap().entries.map((entry) {
                    final index = entry.key + 1;
                    final stepMap = entry.value;
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              backgroundColor: theme.colorScheme.primary,
                              foregroundColor: theme.colorScheme.onPrimary,
                              radius: 16,
                              child: Text("$index", style: const TextStyle(fontWeight: FontWeight.bold)),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (stepMap['name'] != null && stepMap['name']!.isNotEmpty)
                                    Text(
                                      stepMap['name']!,
                                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                    ),
                                  if (stepMap['text'] != null) ...[
                                    const SizedBox(height: 4),
                                    Text(stepMap['text']!, style: theme.textTheme.bodyMedium),
                                  ],
                                  if (stepMap['image'] != null) ...[
                                    const SizedBox(height: 8),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        stepMap['image']!,
                                        height: 120,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
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

  List<String> _extractImages() {
    List<String> res = [];
    final img = node.fields['image']?.value;
    if (img is String) res.add(img);
    if (img is List) res.addAll(img.whereType<String>());
    return res;
  }

  List<String> _extractList(String key) {
    List<String> res = [];
    final val = node.fields[key]?.value;
    if (val is List) {
      for (var item in val) {
        if (item is String) res.add(item);
        if (item is JsonLdNode) {
          final n = item.fields['name']?.value?.toString();
          if (n != null) res.add(n);
        }
      }
    } else if (val is JsonLdNode) {
      final n = val.fields['name']?.value?.toString();
      if (n != null) res.add(n);
    } else if (val is String) {
      res.add(val);
    }
    return res;
  }

  List<Map<String, String>> _extractSteps() {
    List<Map<String, String>> res = [];
    final val = node.fields['step']?.value;

    void addStepNode(JsonLdNode stepNode) {
      final name = stepNode.fields['name']?.value?.toString() ?? '';
      final text = stepNode.fields['text']?.value?.toString() ??
          stepNode.fields['description']?.value?.toString() ??
          '';
      String? img;
      final imgVal = stepNode.fields['image']?.value;
      if (imgVal is String) img = imgVal;
      if (imgVal is JsonLdNode) img = imgVal.fields['url']?.value?.toString();

      res.add({'name': name, 'text': text, if (img != null) 'image': img});
    }

    if (val is List) {
      for (var item in val) {
        if (item is JsonLdNode) addStepNode(item);
        if (item is String) res.add({'name': '', 'text': item});
      }
    } else if (val is JsonLdNode) {
      addStepNode(val);
    }
    return res;
  }
}

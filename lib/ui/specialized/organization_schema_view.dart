import 'package:flutter/material.dart';
import '../../services/json_ld_parser.dart';

class OrganizationSchemaView extends StatelessWidget {
  final JsonLdNode node;

  const OrganizationSchemaView({super.key, required this.node});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final String title = node.fields['name']?.value?.toString() ?? 'Organization';
    final String? description = node.fields['description']?.value?.toString();
    final String? url = node.fields['url']?.value?.toString();
    final String? logo = _extractLogo();
    final List<JsonLdNode> members = _extractMembers();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  if (logo != null)
                    CircleAvatar(
                      radius: 40,
                      backgroundImage: NetworkImage(logo),
                      backgroundColor: theme.colorScheme.surfaceContainerHighest,
                    )
                  else
                    CircleAvatar(
                      radius: 40,
                      child: Text(title[0].toUpperCase(), style: theme.textTheme.headlineLarge),
                    ),
                  const SizedBox(height: 12),
                  Text(
                    title,
                    style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  if (url != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      url,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ],
                  if (description != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      description,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          if (members.isNotEmpty) ...[
            Text(
              "Team / Key People",
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...members.map((m) {
              final name = m.fields['name']?.value?.toString() ?? 'Member';
              final job = m.fields['jobTitle']?.value?.toString();
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(child: Text(name[0])),
                  title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: job != null ? Text(job) : null,
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  String? _extractLogo() {
    final l = node.fields['logo']?.value;
    if (l is String) return l;
    if (l is JsonLdNode) return l.fields['url']?.value?.toString();
    return null;
  }

  List<JsonLdNode> _extractMembers() {
    List<JsonLdNode> res = [];
    void check(dynamic val) {
      if (val is JsonLdNode) res.add(val);
      if (val is List) res.addAll(val.whereType<JsonLdNode>());
    }

    check(node.fields['founders']?.value);
    check(node.fields['member']?.value);
    check(node.fields['employee']?.value);
    return res;
  }
}

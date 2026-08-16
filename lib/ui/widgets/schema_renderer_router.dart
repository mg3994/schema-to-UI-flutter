import 'package:flutter/material.dart';
import '../../services/json_ld_parser.dart';
import '../specialized/product_schema_view.dart';
import '../specialized/recipe_schema_view.dart';
import '../specialized/article_schema_view.dart';
import '../specialized/event_schema_view.dart';
import '../specialized/organization_schema_view.dart';
import 'universal_schema_widget.dart';

class SchemaRendererRouter extends StatelessWidget {
  final JsonLdNode node;

  const SchemaRendererRouter({super.key, required this.node});

  @override
  Widget build(BuildContext context) {
    final typeName = node.primaryType.toLowerCase();

    switch (typeName) {
      case 'product':
        return ProductSchemaView(node: node);
      case 'recipe':
        return RecipeSchemaView(node: node);
      case 'article':
      case 'blogposting':
      case 'newsarticle':
        return ArticleSchemaView(node: node);
      case 'event':
        return EventSchemaView(node: node);
      case 'organization':
      case 'corporation':
      case 'company':
        return OrganizationSchemaView(node: node);
      default:
        // Universal Adaptive Renderer for all other Schema.org types
        return SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: UniversalSchemaWidget(node: node),
        );
    }
  }
}

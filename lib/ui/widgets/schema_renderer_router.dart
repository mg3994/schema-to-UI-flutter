import 'package:flutter/material.dart';
import '../../services/json_ld_parser.dart';
import '../../services/schema_ontology_service.dart';
import '../specialized/product_schema_view.dart';
import '../specialized/recipe_schema_view.dart';
import '../specialized/article_schema_view.dart';
import '../specialized/event_schema_view.dart';
import '../specialized/organization_schema_view.dart';
import '../specialized/howto_schema_view.dart';
import '../specialized/place_schema_view.dart';
import 'universal_schema_widget.dart';

class SchemaRendererRouter extends StatelessWidget {
  final JsonLdNode node;

  const SchemaRendererRouter({super.key, required this.node});

  @override
  Widget build(BuildContext context) {
    final String typeName = node.primaryType;
    final ontology = SchemaOntologyService();

    // Dynamically match type or subclass relationships using Schema.org ontology graph
    if (ontology.isSubclassOf(typeName, 'Product')) {
      return ProductSchemaView(node: node);
    }

    if (ontology.isSubclassOf(typeName, 'Recipe')) {
      return RecipeSchemaView(node: node);
    }

    if (ontology.isSubclassOf(typeName, 'Article')) {
      return ArticleSchemaView(node: node);
    }

    if (ontology.isSubclassOf(typeName, 'Event')) {
      return EventSchemaView(node: node);
    }

    if (ontology.isSubclassOf(typeName, 'Organization')) {
      return OrganizationSchemaView(node: node);
    }

    if (ontology.isSubclassOf(typeName, 'HowTo')) {
      return HowToSchemaView(node: node);
    }

    if (ontology.isSubclassOf(typeName, 'Place')) {
      return PlaceSchemaView(node: node);
    }

    // Universal Adaptive Renderer for all other Schema.org types and custom classes
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: UniversalSchemaWidget(node: node),
    );
  }
}

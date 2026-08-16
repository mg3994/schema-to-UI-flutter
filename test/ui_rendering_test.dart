import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:schema_org_ui/services/json_ld_parser.dart';
import 'package:schema_org_ui/ui/specialized/product_schema_view.dart';
import 'package:schema_org_ui/ui/specialized/recipe_schema_view.dart';
import 'package:schema_org_ui/ui/widgets/universal_schema_widget.dart';

void main() {
  group('UI Schema Rendering Tests', () {
    testWidgets('Renders ProductSchemaView with title, price, and stock', (WidgetTester tester) async {
      final jsonMap = {
        "@type": "Product",
        "name": "Super Gaming Laptop",
        "description": "High performance gaming laptop",
        "brand": {"@type": "Brand", "name": "TechCorp"},
        "offers": {
          "@type": "Offer",
          "price": "1499.99",
          "priceCurrency": "USD",
          "availability": "https://schema.org/InStock"
        }
      };

      final node = JsonLdNode.parse(jsonMap);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProductSchemaView(node: node),
          ),
        ),
      );

      expect(find.text("Super Gaming Laptop"), findsOneWidget);
      expect(find.text("TECHCORP"), findsOneWidget);
      expect(find.text("USD1499.99"), findsOneWidget);
      expect(find.text("In Stock"), findsOneWidget);
    });

    testWidgets('Renders RecipeSchemaView with ingredients', (WidgetTester tester) async {
      final jsonMap = {
        "@type": "Recipe",
        "name": "Chocolate Cake",
        "recipeIngredient": ["1 cup Cocoa Powder", "2 cups Flour", "1 cup Sugar"]
      };

      final node = JsonLdNode.parse(jsonMap);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RecipeSchemaView(node: node),
          ),
        ),
      );

      expect(find.text("Chocolate Cake"), findsOneWidget);
      expect(find.text("Ingredients"), findsOneWidget);
      expect(find.text("1 cup Cocoa Powder"), findsOneWidget);
    });

    testWidgets('Renders UniversalSchemaWidget for generic/nested types', (WidgetTester tester) async {
      final jsonMap = {
        "@type": "MedicalCondition",
        "name": "Common Cold",
        "description": "Viral infection of the upper respiratory tract."
      };

      final node = JsonLdNode.parse(jsonMap);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: UniversalSchemaWidget(node: node),
          ),
        ),
      );

      expect(find.text("MedicalCondition"), findsOneWidget);
      expect(find.text("Common Cold"), findsOneWidget);
      expect(find.text("Viral infection of the upper respiratory tract."), findsOneWidget);
    });
  });
}

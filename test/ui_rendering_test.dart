import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:schema_org_ui/services/json_ld_parser.dart';
import 'package:schema_org_ui/services/schema_enum_resolver.dart';
import 'package:schema_org_ui/services/schema_locale_text_extractor.dart';
import 'package:schema_org_ui/ui/specialized/product_schema_view.dart';
import 'package:schema_org_ui/ui/specialized/recipe_schema_view.dart';
import 'package:schema_org_ui/ui/widgets/universal_schema_widget.dart';
import 'package:schema_org_ui/ui/widgets/schema_socket_widget.dart';

void main() {
  group('SchemaEnumResolver Tests', () {
    test('Resolves InStock availability enum correctly', () {
      final details = SchemaEnumResolver.resolve('https://schema.org/InStock');
      expect(details.enumType, equals('ItemAvailability'));
      expect(details.formattedLabel, equals('In Stock'));
      expect(details.color, equals(Colors.green));
    });

    test('Resolves EventScheduled enum correctly', () {
      final details = SchemaEnumResolver.resolve('https://schema.org/EventScheduled');
      expect(details.enumType, equals('EventStatusType'));
      expect(details.formattedLabel, equals('Event Scheduled'));
    });
  });

  group('SchemaLocaleTextExtractor Tests', () {
    test('Extracts simple string value', () {
      final text = SchemaLocaleTextExtractor.extract('Plain Text');
      expect(text, equals('Plain Text'));
    });

    test('Extracts value from @value map', () {
      final text = SchemaLocaleTextExtractor.extract({'@value': 'Localized Name', '@language': 'en'});
      expect(text, equals('Localized Name'));
    });

    test('Extracts fallback item from multilingual array', () {
      final array = [
        {'@value': 'Running Shoes', '@language': 'en-US'},
        {'@value': 'Zapatillas de running', '@language': 'es-ES'},
      ];
      final text = SchemaLocaleTextExtractor.extract(array);
      expect(text, equals('Running Shoes'));
    });
  });

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
      expect(find.text("USD 1499.99"), findsOneWidget);
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

    testWidgets('Renders SchemaWidgetSocket for Enum badge', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SchemaWidgetSocket(
              value: "https://schema.org/InStock",
              slotName: "availability",
            ),
          ),
        ),
      );

      expect(find.text("In Stock"), findsOneWidget);
    });
  });
}

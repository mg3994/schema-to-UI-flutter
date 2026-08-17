import 'package:flutter_test/flutter_test.dart';
import 'package:schema_org_ui/services/json_ld_parser.dart';
import 'package:schema_org_ui/models/schema_ontology.dart';

void main() {
  group('JsonLdNode Parser Tests', () {
    test('Parses Product Schema successfully', () {
      final jsonMap = {
        "@context": "https://schema.org",
        "@type": "Product",
        "name": "Acme Smartphone",
        "image": "https://example.com/phone.png",
        "description": "Latest high-end flagship phone.",
        "brand": {
          "@type": "Brand",
          "name": "Acme"
        },
        "offers": {
          "@type": "Offer",
          "price": 799.99,
          "priceCurrency": "USD",
          "availability": "https://schema.org/InStock"
        }
      };

      final node = JsonLdNode.parse(jsonMap);

      expect(node.type, equals("Product"));
      expect(node.fields.containsKey('name'), isTrue);
      expect(node.fields['name']!.value, equals("Acme Smartphone"));
      expect(node.fields['image']!.valueType, equals(JsonLdValueType.image));
      expect(node.fields['brand']!.valueType, equals(JsonLdValueType.object));

      final brandNode = node.fields['brand']!.value as JsonLdNode;
      expect(brandNode.type, equals("Brand"));
      expect(brandNode.fields['name']!.value, equals("Acme"));
    });

    test('Parses array of values correctly', () {
      final jsonMap = {
        "@type": "Recipe",
        "recipeIngredient": [
          "1 cup Sugar",
          "2 cups Flour",
          "3 Eggs"
        ]
      };

      final node = JsonLdNode.parse(jsonMap);
      expect(node.type, equals("Recipe"));
      expect(node.fields['recipeIngredient']!.valueType, equals(JsonLdValueType.array));
      final ingredients = node.fields['recipeIngredient']!.value as List;
      expect(ingredients.length, equals(3));
    });
  });

  group('SchemaClass Model Tests', () {
    test('Cleans schema namespace prefixes correctly', () {
      final jsonMap = {
        "@id": "https://schema.org/Product",
        "rdfs:label": "Product",
        "rdfs:comment": "Any offered product or service."
      };

      final sc = SchemaClass.fromJson(jsonMap);
      expect(sc.id, equals("Product"));
      expect(sc.label, equals("Product"));
      expect(sc.comment, equals("Any offered product or service."));
    });
  });
}

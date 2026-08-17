import 'schema_ontology_service.dart';
import 'json_ld_parser.dart';

class SchemaValidationIssue {
  final String property;
  final String message;
  final bool isError; // true = error, false = warning/recommendation

  SchemaValidationIssue({
    required this.property,
    required this.message,
    this.isError = false,
  });
}

class SchemaValidationReport {
  final String primaryType;
  final int healthScore; // 0 - 100%
  final List<SchemaValidationIssue> issues;

  SchemaValidationReport({
    required this.primaryType,
    required this.healthScore,
    required this.issues,
  });
}

class SchemaValidationService {
  static SchemaValidationReport validate(JsonLdNode node) {
    final ontology = SchemaOntologyService();
    final typeName = node.primaryType;
    final sc = ontology.getClass(typeName);
    final issues = <SchemaValidationIssue>[];

    // Check basic metadata
    if (!node.rawJson.containsKey('@context')) {
      issues.add(SchemaValidationIssue(
        property: '@context',
        message: 'Missing @context definition (expected "https://schema.org").',
        isError: true,
      ));
    }

    if (node.type == null) {
      issues.add(SchemaValidationIssue(
        property: '@type',
        message: 'Missing explicit @type declaration.',
        isError: true,
      ));
    }

    // Recommended properties check
    if (!node.fields.containsKey('name') && !node.fields.containsKey('headline')) {
      issues.add(SchemaValidationIssue(
        property: 'name',
        message: 'Recommended property "name" or "headline" is missing.',
        isError: false,
      ));
    }

    if (!node.fields.containsKey('description')) {
      issues.add(SchemaValidationIssue(
        property: 'description',
        message: 'Recommended property "description" is missing.',
        isError: false,
      ));
    }

    if (!node.fields.containsKey('image')) {
      issues.add(SchemaValidationIssue(
        property: 'image',
        message: 'Recommended visual property "image" is missing.',
        isError: false,
      ));
    }

    // Check class ontology properties if class is known in ontology
    if (sc != null && sc.properties.isNotEmpty) {
      for (var propId in sc.properties.take(10)) {
        final prop = ontology.getProperty(propId);
        if (prop != null && !node.fields.containsKey(propId)) {
          issues.add(SchemaValidationIssue(
            property: propId,
            message: 'Class $typeName supports property "$propId" (${prop.comment.take(60)}...).',
            isError: false,
          ));
        }
      }
    }

    int errors = issues.where((i) => i.isError).length;
    int warnings = issues.where((i) => !i.isError).length;
    int score = (100 - (errors * 25 + warnings * 5)).clamp(0, 100);

    return SchemaValidationReport(
      primaryType: typeName,
      healthScore: score,
      issues: issues,
    );
  }
}

extension StringTakeExtension on String {
  String take(int n) {
    if (length <= n) return this;
    return substring(0, n);
  }
}

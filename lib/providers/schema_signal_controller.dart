import 'dart:convert';
import 'package:signals_flutter/signals_flutter.dart';
import '../models/schema_ontology.dart';
import '../services/schema_ontology_service.dart';
import '../services/json_ld_parser.dart';

class SchemaSignalController {
  static final SchemaSignalController _instance = SchemaSignalController._internal();
  factory SchemaSignalController() => _instance;
  SchemaSignalController._internal();

  final SchemaOntologyService ontologyService = SchemaOntologyService();

  // Reactive signals
  final Signal<bool> isLoading = signal(true);
  final Signal<String?> error = signal(null);
  final Signal<JsonLdNode?> currentSchemaNode = signal(null);
  final Signal<String> rawJsonInput = signal('');

  Future<void> initOntology() async {
    isLoading.value = true;
    try {
      await ontologyService.loadOntology();
      isLoading.value = false;
    } catch (e) {
      error.value = e.toString();
      isLoading.value = false;
    }
  }

  void updateJsonLdInput(String jsonStr) {
    rawJsonInput.value = jsonStr;
    error.value = null;

    if (jsonStr.trim().isEmpty) {
      currentSchemaNode.value = null;
      return;
    }

    try {
      final parsed = json.decode(jsonStr);
      if (parsed is Map<String, dynamic>) {
        currentSchemaNode.value = JsonLdNode.parse(parsed);
      } else if (parsed is List && parsed.isNotEmpty && parsed.first is Map<String, dynamic>) {
        currentSchemaNode.value = JsonLdNode.parse(parsed.first);
      } else {
        error.value = "Invalid JSON-LD format. Expected a JSON object or array of objects.";
        currentSchemaNode.value = null;
      }
    } catch (e) {
      error.value = "JSON Syntax Error: ${e.toString()}";
      currentSchemaNode.value = null;
    }
  }

  String generateSampleJsonLdForClass(String className) {
    final sc = ontologyService.getClass(className);
    final Map<String, dynamic> sample = {
      "@context": "https://schema.org",
      "@type": className,
    };

    if (sc != null) {
      sample["name"] = "Sample $className";
      sample["description"] = sc.comment.isNotEmpty
          ? sc.comment
          : "This is an automatically generated sample for $className.";

      int added = 0;
      for (var propId in sc.properties) {
        if (added >= 5) break;
        if (propId == 'name' || propId == 'description') continue;
        final prop = ontologyService.getProperty(propId);
        if (prop != null) {
          sample[propId] = _generateSamplePropValue(prop);
          added++;
        }
      }
    } else {
      sample["name"] = "Sample $className";
      sample["description"] = "Generic Schema.org object representation for $className.";
    }

    return JsonEncoder.withIndent('  ').convert(sample);
  }

  dynamic _generateSamplePropValue(SchemaProperty prop) {
    final idLower = prop.id.toLowerCase();
    if (idLower.contains('image') || idLower.contains('logo')) {
      return "https://images.unsplash.com/photo-1523275335684-37898b6baf30";
    }
    if (idLower.contains('url')) {
      return "https://example.com/${prop.id}";
    }
    if (idLower.contains('date') || idLower.contains('time')) {
      return DateTime.now().toIso8601String().split('T').first;
    }
    if (idLower.contains('price')) {
      return 99.99;
    }
    if (idLower.contains('rating')) {
      return {
        "@type": "AggregateRating",
        "ratingValue": "4.8",
        "reviewCount": "124"
      };
    }
    return "Sample ${prop.label}";
  }
}

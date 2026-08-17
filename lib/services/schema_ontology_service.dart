import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/schema_ontology.dart';

class SchemaOntologyService {
  static final SchemaOntologyService _instance = SchemaOntologyService._internal();
  factory SchemaOntologyService() => _instance;
  SchemaOntologyService._internal();

  final Map<String, SchemaClass> _classes = {};
  final Map<String, SchemaProperty> _properties = {};
  final Map<String, SchemaEnum> _enums = {};
  bool _isLoaded = false;
  bool get isLoaded => _isLoaded;

  Map<String, SchemaClass> get classes => _classes;
  Map<String, SchemaProperty> get properties => _properties;
  Map<String, SchemaEnum> get enums => _enums;

  Future<void> loadOntology() async {
    if (_isLoaded) return;
    try {
      final jsonString = await rootBundle.loadString('assets/schema/schemaorg-current-https.jsonld');
      final rawData = json.decode(jsonString);
      if (rawData is Map<String, dynamic> && rawData.containsKey('@graph')) {
        final List graph = rawData['@graph'];
        for (var item in graph) {
          if (item is Map<String, dynamic>) {
            _processGraphNode(item);
          }
        }
      }
      _isLoaded = true;
    } catch (e) {
      _isLoaded = true;
    }
  }

  void _processGraphNode(Map<String, dynamic> json) {
    final typeVal = json['@type'];
    final id = SchemaClass.cleanId(json['@id']?.toString() ?? '');
    if (id.isEmpty) return;

    List<String> types = [];
    if (typeVal is String) {
      types.add(typeVal);
    } else if (typeVal is List) {
      types.addAll(typeVal.map((e) => e.toString()));
    }

    bool isClass = types.any((t) => t.contains('rdfs:Class') || t.contains('Class'));
    bool isProp = types.any((t) => t.contains('rdf:Property') || t.contains('Property'));

    if (isClass) {
      final sc = SchemaClass.fromJson(json);
      _classes[sc.id] = sc;
    } else if (isProp) {
      final sp = SchemaProperty.fromJson(json);
      _properties[sp.id] = sp;
      for (var domain in sp.domainIncludes) {
        if (_classes.containsKey(domain)) {
          _classes[domain]!.properties.add(sp.id);
        }
      }
    } else {
      final label = SchemaClass.extractText(json['rdfs:label']) ?? id;
      final comment = SchemaClass.extractText(json['rdfs:comment']) ?? '';
      String enumType = '';
      if (types.isNotEmpty) {
        enumType = SchemaClass.cleanId(types.first);
      }
      _enums[id] = SchemaEnum(
        id: id,
        label: label,
        comment: comment,
        enumType: enumType,
      );
    }
  }

  SchemaClass? getClass(String typeName) {
    final clean = SchemaClass.cleanId(typeName);
    return _classes[clean];
  }

  SchemaProperty? getProperty(String propName) {
    final clean = SchemaClass.cleanId(propName);
    return _properties[clean];
  }

  List<String> getAllSubclasses(String parentType) {
    List<String> results = [];
    final cleanParent = SchemaClass.cleanId(parentType);
    _classes.forEach((key, value) {
      if (value.subClassOf.contains(cleanParent)) {
        results.add(key);
      }
    });
    return results;
  }

  bool isSubclassOf(String childType, String parentType) {
    final cleanChild = SchemaClass.cleanId(childType);
    final cleanParent = SchemaClass.cleanId(parentType);
    if (cleanChild == cleanParent) return true;

    final sc = _classes[cleanChild];
    if (sc == null) return false;

    for (var p in sc.subClassOf) {
      if (p == cleanParent || isSubclassOf(p, cleanParent)) {
        return true;
      }
    }
    return false;
  }
}

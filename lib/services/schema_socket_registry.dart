import 'package:flutter/material.dart';
import 'json_ld_parser.dart';

typedef SchemaSocketBuilder = Widget Function(BuildContext context, JsonLdNode node, String slotName);

class SchemaSocketRegistry {
  static final SchemaSocketRegistry _instance = SchemaSocketRegistry._internal();
  factory SchemaSocketRegistry() => _instance;
  SchemaSocketRegistry._internal();

  final Map<String, SchemaSocketBuilder> _socketBuilders = {};

  void registerSocket(String typeName, SchemaSocketBuilder builder) {
    _socketBuilders[typeName.toLowerCase()] = builder;
  }

  SchemaSocketBuilder? getSocketBuilder(String typeName) {
    return _socketBuilders[typeName.toLowerCase()];
  }

  bool hasSocketBuilder(String typeName) {
    return _socketBuilders.containsKey(typeName.toLowerCase());
  }

  void clearRegistry() {
    _socketBuilders.clear();
  }
}

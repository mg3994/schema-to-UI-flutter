class SchemaClass {
  final String id; // e.g., 'https://schema.org/Product' or 'Product'
  final String label; // e.g., 'Product'
  final String comment; // Description
  final List<String> subClassOf; // Parent class IDs
  final List<String> properties; // Property IDs defined on or associated with this class

  SchemaClass({
    required this.id,
    required this.label,
    required this.comment,
    required this.subClassOf,
    required this.properties,
  });

  factory SchemaClass.fromJson(Map<String, dynamic> json) {
    final rawId = json['@id']?.toString() ?? '';
    final rawLabel = _extractText(json['rdfs:label']) ?? _cleanId(rawId);
    final comment = _extractText(json['rdfs:comment']) ?? '';

    List<String> subClasses = [];
    final rawSub = json['rdfs:subClassOf'];
    if (rawSub is Map && rawSub.containsKey('@id')) {
      subClasses.add(_cleanId(rawSub['@id'].toString()));
    } else if (rawSub is List) {
      for (var item in rawSub) {
        if (item is Map && item.containsKey('@id')) {
          subClasses.add(_cleanId(item['@id'].toString()));
        }
      }
    }

    return SchemaClass(
      id: _cleanId(rawId),
      label: rawLabel,
      comment: comment,
      subClassOf: subClasses,
      properties: [],
    );
  }

  static String? _extractText(dynamic val) {
    if (val == null) return null;
    if (val is String) return val;
    if (val is Map) {
      if (val.containsKey('@value')) return val['@value'].toString();
    }
    if (val is List && val.isNotEmpty) {
      return _extractText(val.first);
    }
    return val.toString();
  }

  static String _cleanId(String id) {
    if (id.startsWith('https://schema.org/')) {
      return id.substring('https://schema.org/'.length);
    }
    if (id.startsWith('http://schema.org/')) {
      return id.substring('http://schema.org/'.length);
    }
    if (id.startsWith('schema:')) {
      return id.substring('schema:'.length);
    }
    return id;
  }
}

class SchemaProperty {
  final String id;
  final String label;
  final String comment;
  final List<String> domainIncludes; // Classes that can have this property
  final List<String> rangeIncludes; // Expected types/classes for value

  SchemaProperty({
    required this.id,
    required this.label,
    required this.comment,
    required this.domainIncludes,
    required this.rangeIncludes,
  });

  factory SchemaProperty.fromJson(Map<String, dynamic> json) {
    final rawId = json['@id']?.toString() ?? '';
    final label = SchemaClass._extractText(json['rdfs:label']) ?? SchemaClass._cleanId(rawId);
    final comment = SchemaClass._extractText(json['rdfs:comment']) ?? '';

    List<String> domains = _extractIdList(json['schema:domainIncludes']);
    List<String> ranges = _extractIdList(json['schema:rangeIncludes']);

    return SchemaProperty(
      id: SchemaClass._cleanId(rawId),
      label: label,
      comment: comment,
      domainIncludes: domains,
      rangeIncludes: ranges,
    );
  }

  static List<String> _extractIdList(dynamic val) {
    List<String> res = [];
    if (val == null) return res;
    if (val is Map && val.containsKey('@id')) {
      res.add(SchemaClass._cleanId(val['@id'].toString()));
    } else if (val is List) {
      for (var item in val) {
        if (item is Map && item.containsKey('@id')) {
          res.add(SchemaClass._cleanId(item['@id'].toString()));
        }
      }
    }
    return res;
  }
}

class SchemaEnum {
  final String id;
  final String label;
  final String comment;
  final String enumType; // e.g. ItemAvailability

  SchemaEnum({
    required this.id,
    required this.label,
    required this.comment,
    required this.enumType,
  });
}

enum JsonLdValueType {
  object,
  array,
  string,
  number,
  boolean,
  url,
  image,
  date,
  nullValue,
}

class JsonLdNode {
  final String? type; // @type e.g., 'Product', 'Offer', 'Person'
  final String? id; // @id
  final Map<String, dynamic> rawJson;
  final Map<String, JsonLdField> fields;

  JsonLdNode({
    this.type,
    this.id,
    required this.rawJson,
    required this.fields,
  });

  String get primaryType => type ?? 'Thing';

  static JsonLdNode parse(Map<String, dynamic> json) {
    String? type;
    final rawType = json['@type'];
    if (rawType is String) {
      type = _cleanType(rawType);
    } else if (rawType is List && rawType.isNotEmpty) {
      type = _cleanType(rawType.first.toString());
    }

    final id = json['@id']?.toString();

    final fields = <String, JsonLdField>{};
    json.forEach((key, val) {
      if (key.startsWith('@')) return; // Skip LD metadata keywords like @context, @type, @id
      fields[key] = JsonLdField.parse(key, val);
    });

    return JsonLdNode(
      type: type,
      id: id,
      rawJson: json,
      fields: fields,
    );
  }

  static String _cleanType(String t) {
    if (t.startsWith('https://schema.org/')) return t.substring('https://schema.org/'.length);
    if (t.startsWith('http://schema.org/')) return t.substring('http://schema.org/'.length);
    if (t.startsWith('schema:')) return t.substring('schema:'.length);
    return t;
  }
}

class JsonLdField {
  final String key;
  final dynamic value;
  final JsonLdValueType valueType;

  JsonLdField({
    required this.key,
    required this.value,
    required this.valueType,
  });

  factory JsonLdField.parse(String key, dynamic val) {
    if (val == null) {
      return JsonLdField(key: key, value: null, valueType: JsonLdValueType.nullValue);
    }

    if (val is Map<String, dynamic>) {
      // Support @value and multilingual objects like {"@value": "Running Shoes", "@language": "en-US"}
      if (val.containsKey('@value')) {
        final rawVal = val['@value'];
        return JsonLdField(
          key: key,
          value: rawVal,
          valueType: _detectPrimitiveType(rawVal),
        );
      }
      return JsonLdField(
        key: key,
        value: JsonLdNode.parse(val),
        valueType: JsonLdValueType.object,
      );
    }

    if (val is List) {
      final parsedList = val.map((e) {
        if (e is Map<String, dynamic>) {
          // Check if list item is a @value language map
          if (e.containsKey('@value')) {
            return e['@value'];
          }
          return JsonLdNode.parse(e);
        }
        return e;
      }).toList();

      // If array items were collapsed to plain string/primitives (e.g. multilingual names)
      if (parsedList.isNotEmpty && parsedList.every((item) => item is String)) {
        return JsonLdField(
          key: key,
          value: parsedList.first, // Extract primary string representation
          valueType: JsonLdValueType.string,
        );
      }

      return JsonLdField(
        key: key,
        value: parsedList,
        valueType: JsonLdValueType.array,
      );
    }

    if (val is bool) {
      return JsonLdField(key: key, value: val, valueType: JsonLdValueType.boolean);
    }

    if (val is num) {
      return JsonLdField(key: key, value: val, valueType: JsonLdValueType.number);
    }

    if (val is String) {
      return JsonLdField(
        key: key,
        value: val,
        valueType: _detectStringType(key, val),
      );
    }

    return JsonLdField(key: key, value: val.toString(), valueType: JsonLdValueType.string);
  }

  static JsonLdValueType _detectPrimitiveType(dynamic val) {
    if (val is bool) return JsonLdValueType.boolean;
    if (val is num) return JsonLdValueType.number;
    if (val is String) return _detectStringType('', val);
    return JsonLdValueType.string;
  }

  static JsonLdValueType _detectStringType(String key, String val) {
    final lowerKey = key.toLowerCase();
    final lowerVal = val.toLowerCase();

    // Check Image URLs
    if (lowerKey.contains('image') ||
        lowerKey.contains('logo') ||
        lowerKey.contains('photo') ||
        lowerKey.contains('thumbnail') ||
        lowerVal.endsWith('.jpg') ||
        lowerVal.endsWith('.jpeg') ||
        lowerVal.endsWith('.png') ||
        lowerVal.endsWith('.webp') ||
        lowerVal.endsWith('.gif') ||
        lowerVal.endsWith('.svg')) {
      if (val.startsWith('http://') || val.startsWith('https://')) {
        return JsonLdValueType.image;
      }
    }

    // Check URLs
    if (val.startsWith('http://') || val.startsWith('https://')) {
      return JsonLdValueType.url;
    }

    // Check Dates / ISO strings
    if (lowerKey.contains('date') ||
        lowerKey.contains('time') ||
        lowerKey.contains('published') ||
        lowerKey.contains('modified') ||
        lowerKey.contains('created')) {
      if (DateTime.tryParse(val) != null) {
        return JsonLdValueType.date;
      }
    }

    return JsonLdValueType.string;
  }
}

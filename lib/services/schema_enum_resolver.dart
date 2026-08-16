import 'package:flutter/material.dart';

class SchemaEnumDetails {
  final String enumType; // e.g., 'ItemAvailability', 'OfferItemCondition', 'EventStatusType'
  final String enumValue; // e.g., 'InStock', 'NewCondition', 'EventScheduled'
  final String formattedLabel; // e.g., 'In Stock', 'New Condition', 'Event Scheduled'
  final Color color;
  final IconData icon;

  SchemaEnumDetails({
    required this.enumType,
    required this.enumValue,
    required this.formattedLabel,
    required this.color,
    required this.icon,
  });
}

class SchemaEnumResolver {
  static SchemaEnumDetails resolve(String rawUrlOrString) {
    String value = rawUrlOrString;

    // Clean Schema.org namespace
    if (value.startsWith('https://schema.org/')) {
      value = value.substring('https://schema.org/'.length);
    } else if (value.startsWith('http://schema.org/')) {
      value = value.substring('http://schema.org/'.length);
    } else if (value.startsWith('schema:')) {
      value = value.substring('schema:'.length);
    }

    final formattedLabel = _formatLabel(value);
    final lower = value.toLowerCase();

    // Availability enums
    if (lower.contains('instock') || lower.contains('preorder') || lower.contains('presale')) {
      return SchemaEnumDetails(
        enumType: 'ItemAvailability',
        enumValue: value,
        formattedLabel: formattedLabel,
        color: Colors.green,
        icon: Icons.check_circle_outline,
      );
    }
    if (lower.contains('outofstock') || lower.contains('soldout') || lower.contains('discontinued')) {
      return SchemaEnumDetails(
        enumType: 'ItemAvailability',
        enumValue: value,
        formattedLabel: formattedLabel,
        color: Colors.red,
        icon: Icons.cancel_outlined,
      );
    }
    if (lower.contains('limitedavailability') || lower.contains('onlineonly') || lower.contains('instoreonly')) {
      return SchemaEnumDetails(
        enumType: 'ItemAvailability',
        enumValue: value,
        formattedLabel: formattedLabel,
        color: Colors.orange,
        icon: Icons.info_outline,
      );
    }

    // Condition enums
    if (lower.contains('newcondition')) {
      return SchemaEnumDetails(
        enumType: 'OfferItemCondition',
        enumValue: value,
        formattedLabel: formattedLabel,
        color: Colors.blue,
        icon: Icons.new_releases_outlined,
      );
    }
    if (lower.contains('refurbished') || lower.contains('used')) {
      return SchemaEnumDetails(
        enumType: 'OfferItemCondition',
        enumValue: value,
        formattedLabel: formattedLabel,
        color: Colors.purple,
        icon: Icons.build_circle_outlined,
      );
    }

    // Event Status enums
    if (lower.contains('eventscheduled') || lower.contains('eventmovedonline')) {
      return SchemaEnumDetails(
        enumType: 'EventStatusType',
        enumValue: value,
        formattedLabel: formattedLabel,
        color: Colors.teal,
        icon: Icons.event_available,
      );
    }
    if (lower.contains('eventcancelled') || lower.contains('eventpostponed')) {
      return SchemaEnumDetails(
        enumType: 'EventStatusType',
        enumValue: value,
        formattedLabel: formattedLabel,
        color: Colors.deepOrange,
        icon: Icons.event_busy,
      );
    }

    // Generic Schema Enum fallback
    return SchemaEnumDetails(
      enumType: 'SchemaEnum',
      enumValue: value,
      formattedLabel: formattedLabel,
      color: Colors.indigo,
      icon: Icons.label_outlined,
    );
  }

  static String _formatLabel(String text) {
    if (text.isEmpty) return text;
    final result = text.replaceAllMapped(
      RegExp(r'([A-Z])'),
      (Match match) => ' ${match.group(0)}',
    );
    return result[0].toUpperCase() + result.substring(1).trim();
  }
}

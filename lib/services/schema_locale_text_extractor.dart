import 'package:flutter/material.dart';

class SchemaLocaleTextExtractor {
  static String extract(dynamic val, [BuildContext? context]) {
    if (val == null) return '';
    if (val is String) return val;

    if (val is Map) {
      if (val.containsKey('@value')) return val['@value'].toString();
    }

    if (val is List && val.isNotEmpty) {
      // Check if items are @value/@language maps
      final langMaps = val.whereType<Map>().where((m) => m.containsKey('@value')).toList();
      if (langMaps.isEmpty) {
        return extract(val.first, context);
      }

      // Collect supported device/app locales
      final List<Locale> activeLocales = [];

      if (context != null) {
        final appLocale = Localizations.maybeLocaleOf(context);
        if (appLocale != null) activeLocales.add(appLocale);

        final systemLocales = View.of(context).platformDispatcher.locales;
        for (var sys in systemLocales) {
          if (!activeLocales.contains(sys)) {
            activeLocales.add(sys);
          }
        }
      }

      // 1. Try exact match (e.g. 'en-US' or 'es-ES')
      for (var active in activeLocales) {
        final tag = active.toLanguageTag().toLowerCase(); // e.g. en-us
        for (var item in langMaps) {
          final lang = item['@language']?.toString().toLowerCase();
          if (lang == tag) {
            return item['@value'].toString();
          }
        }
      }

      // 2. Try primary language code match (e.g. 'en' or 'es')
      for (var active in activeLocales) {
        final code = active.languageCode.toLowerCase(); // e.g. en
        for (var item in langMaps) {
          final lang = item['@language']?.toString().toLowerCase();
          if (lang != null && (lang.startsWith(code) || lang == code)) {
            return item['@value'].toString();
          }
        }
      }

      // 3. Fallback to very first entry
      return langMaps.first['@value'].toString();
    }

    return val.toString();
  }
}

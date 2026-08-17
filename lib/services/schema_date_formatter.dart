import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SchemaDateFormatter {
  static String formatDate(String isoDateString, [BuildContext? context]) {
    if (isoDateString.isEmpty) return isoDateString;

    final dateTime = DateTime.tryParse(isoDateString);
    if (dateTime == null) return isoDateString;

    String? localeTag;
    if (context != null) {
      localeTag = Localizations.maybeLocaleOf(context)?.toLanguageTag();
    }

    try {
      if (isoDateString.contains('T')) {
        // Date with Time
        final formatter = DateFormat.yMMMMd(localeTag).add_jm();
        return formatter.format(dateTime.toLocal());
      } else {
        // Date only
        final formatter = DateFormat.yMMMMd(localeTag);
        return formatter.format(dateTime);
      }
    } catch (_) {
      return isoDateString;
    }
  }
}

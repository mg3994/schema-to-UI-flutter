import 'package:flutter/material.dart';
import 'providers/schema_signal_controller.dart';
import 'ui/screens/home_screen.dart';

void main() {
  final controller = SchemaSignalController();
  controller.initOntology();

  runApp(
    SchemaApp(controller: controller),
  );
}

class SchemaApp extends StatefulWidget {
  final SchemaSignalController controller;

  const SchemaApp({super.key, required this.controller});

  @override
  State<SchemaApp> createState() => _SchemaAppState();
}

class _SchemaAppState extends State<SchemaApp> {
  ThemeMode _themeMode = ThemeMode.system;

  void _toggleTheme() {
    setState(() {
      if (_themeMode == ThemeMode.light) {
        _themeMode = ThemeMode.dark;
      } else if (_themeMode == ThemeMode.dark) {
        _themeMode = ThemeMode.light;
      } else {
        final brightness = MediaQuery.of(context).platformBrightness;
        _themeMode = brightness == Brightness.dark ? ThemeMode.light : ThemeMode.dark;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = _themeMode == ThemeMode.dark ||
        (_themeMode == ThemeMode.system &&
            MediaQuery.of(context).platformBrightness == Brightness.dark);

    return MaterialApp(
      title: 'Schema.org Universal UI Engine',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
        brightness: Brightness.dark,
      ),
      home: HomeScreen(
        controller: widget.controller,
        onToggleTheme: _toggleTheme,
        isDarkMode: isDark,
      ),
    );
  }
}

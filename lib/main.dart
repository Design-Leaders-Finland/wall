import 'package:flutter/material.dart';
import 'package:wall/home_page.dart';
import 'package:wall/utils/logger.dart';
import 'package:wall/widgets/app_startup_handler.dart';
import 'package:wall/widgets/theme_aware_icon_handler.dart';

void main() {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize the logger
  AppLogger.setup();
  
  // Run the app with the splash screen immediately
  runApp(const MyAppWithSplash());
}

// Wrapper for the splash screen
class MyAppWithSplash extends StatelessWidget {
  const MyAppWithSplash({super.key});

  @override
  Widget build(BuildContext context) {
    return ThemeAwareIconHandler(
      child: MaterialApp(
        title: 'WALL',
        // Use light theme
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
        ),
        // Use dark theme
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
        ),
        // Follow the system theme
        themeMode: ThemeMode.system,
        home: AppStartupHandler(
          appBuilder: () => const MyApp(),
        ),
      ),
    );
  }
}

// Main app widget
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ThemeAwareIconHandler(
      child: MaterialApp(
        title: 'WALL',
        // Use light theme
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
        ),
        // Use dark theme
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
        ),
        // Follow the system theme
        themeMode: ThemeMode.system,
        home: const HomePage(), // Your chat UI
      ),
    );
  }
}
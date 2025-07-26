// App startup handler widget for managing application initialization sequence
// Displays splash screen during startup, handles initialization errors, and provides retry functionality
import 'package:flutter/material.dart';
import '../services/app_initialization_service.dart';
import '../utils/logger.dart';
import '../widgets/splash_screen.dart';

class AppStartupHandler extends StatefulWidget {
  final Widget Function() appBuilder;

  const AppStartupHandler({super.key, required this.appBuilder});

  @override
  State<AppStartupHandler> createState() => _AppStartupHandlerState();
}

class _AppStartupHandlerState extends State<AppStartupHandler> {
  bool _initialized = false;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      await AppInitializationService.initializeApp();
      if (mounted) {
        setState(() {
          _initialized = true;
        });
      }
    } catch (e) {
      AppLogger.error('Failed to initialize app', e);
      if (mounted) {
        setState(() {
          _error = e;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show splash screen while initializing
    if (!_initialized) {
      return const SplashScreen();
    }

    // Show error screen if initialization failed
    if (_error != null) {
      return MaterialApp(
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
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  color: Theme.of(context).colorScheme.error,
                  size: 60,
                ),
                const SizedBox(height: 16),
                Text(
                  'Failed to initialize the app',
                  style: TextStyle(
                    fontSize: 20,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _error.toString(),
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _initializeApp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  ),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Show the main app when initialization is complete
    return widget.appBuilder();
  }
}

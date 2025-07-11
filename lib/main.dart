import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:wall/home_page.dart'; // Your main chat UI
import 'package:wall/utils/logger.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize the logger
  AppLogger.setup();

  await Supabase.initialize(
    url: 'https://vncfwjhduqhevwjspnny.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZuY2Z3amhkdXFoZXZ3anNwbm55Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTIyMzE0NDksImV4cCI6MjA2NzgwNzQ0OX0.3ATScVIraTIukGP0bchZrWOZEYmzRb0wO2GcqzqHt_A',
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WALL',
      theme: ThemeData.light(),
      home: const HomePage(), // Your chat UI
    );
  }
}
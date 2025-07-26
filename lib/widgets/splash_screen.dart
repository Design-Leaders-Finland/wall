// Splash screen widget displayed during app initialization
// Shows the app logo and loading indicator with theme-aware styling
import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Use the theme's background color instead of hardcoding white
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // You can use an image here
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  'WALL',
                  style: TextStyle(
                    // Use a contrast color based on the primary color
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Use theme-colored progress indicator
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).colorScheme.secondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

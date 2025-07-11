import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppIconService {
  static const _platform = MethodChannel('fi.designleaders.wall/app_icon');
  
  // Update app icon based on current theme brightness
  static Future<void> updateAppIcon(BuildContext context) async {
    try {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      await _platform.invokeMethod('updateAppIcon', {'isDark': isDark});
    } on PlatformException catch (e) {
      debugPrint('Failed to update app icon: ${e.message}');
    } catch (e) {
      debugPrint('Error updating app icon: $e');
    }
  }
}

import 'package:flutter/material.dart';
import 'package:wall/services/app_icon_service.dart';

/// A widget that listens for theme changes and updates the app icon accordingly
class ThemeAwareIconHandler extends StatefulWidget {
  final Widget child;

  const ThemeAwareIconHandler({super.key, required this.child});

  @override
  State<ThemeAwareIconHandler> createState() => _ThemeAwareIconHandlerState();
}

class _ThemeAwareIconHandlerState extends State<ThemeAwareIconHandler>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Update on first build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateAppIcon();
    });
  }

  @override
  void didChangePlatformBrightness() {
    super.didChangePlatformBrightness();
    _updateAppIcon();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateAppIcon();
  }

  void _updateAppIcon() {
    AppIconService.updateAppIcon(context);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

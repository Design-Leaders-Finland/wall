// SSL debug helper utility for development and troubleshooting
// Provides SSL certificate information display and debugging tools for development builds
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../services/ssl_certificate_service.dart';
import '../utils/logger.dart';

class SSLDebugHelper {
  /// Show SSL certificate information in debug mode
  static Future<void> showSSLInfo(BuildContext context) async {
    if (!kDebugMode) return;

    try {
      final certInfo = await SSLCertificateService.getCertificateInfo();

      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('SSL Certificate Info'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Loaded: ${certInfo['loaded']}'),
                  if (certInfo['loaded']) ...[
                    Text('Size: ${certInfo['size']} bytes'),
                    Text('Has BEGIN marker: ${certInfo['hasBeginMarker']}'),
                    Text('Has END marker: ${certInfo['hasEndMarker']}'),
                    const SizedBox(height: 8),
                    const Text(
                      'Preview:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      certInfo['preview'],
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                      ),
                    ),
                  ] else ...[
                    Text('Error: ${certInfo['error']}'),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  await _testSSLConnection(context);
                },
                child: const Text('Test SSL'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      AppLogger.error('Error showing SSL info', e);
    }
  }

  /// Test SSL connection and show results
  static Future<void> _testSSLConnection(BuildContext context) async {
    try {
      const url = 'https://vncfwjhduqhevwjspnny.supabase.co';
      final success = await SSLCertificateService.testSSLConnection(url);

      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('SSL Connection Test'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  success ? Icons.check_circle : Icons.error,
                  color: success ? Colors.green : Colors.red,
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  success
                      ? 'SSL connection successful!'
                      : 'SSL connection failed.',
                  style: TextStyle(
                    color: success ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text('URL: $url'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      AppLogger.error('Error testing SSL connection', e);
    }
  }
}

/// Extension to add SSL debug functionality to any widget
extension SSLDebugExtension on BuildContext {
  /// Show SSL certificate debug info (only in debug mode)
  Future<void> showSSLDebugInfo() async {
    await SSLDebugHelper.showSSLInfo(this);
  }
}

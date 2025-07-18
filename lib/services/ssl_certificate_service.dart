import 'dart:io';
import 'package:flutter/services.dart';
import '../utils/logger.dart';

class SSLCertificateService {
  static const String certificatePath =
      'assets/certificates/supabase-prod-ca-2021.crt';

  /// Load and configure the SSL certificate for Supabase connections
  static Future<void> configureCertificate() async {
    try {
      AppLogger.info('Loading SSL certificate from $certificatePath');

      // Load the certificate data from assets
      final certificateData = await rootBundle.loadString(certificatePath);

      if (certificateData.isEmpty) {
        throw Exception('SSL certificate file is empty');
      }

      // Validate certificate format
      if (!certificateData.contains('BEGIN CERTIFICATE') ||
          !certificateData.contains('END CERTIFICATE')) {
        throw Exception('Invalid certificate format');
      }

      // Add the certificate to the global security context
      SecurityContext.defaultContext.setTrustedCertificatesBytes(
        certificateData.codeUnits,
      );

      AppLogger.info('SSL certificate successfully configured');
    } catch (e) {
      AppLogger.error('Failed to load SSL certificate', e);

      // Log warning but don't throw - allow the app to continue with system certificates
      AppLogger.warning(
        'Falling back to system SSL certificates. '
        'Ensure your certificate file is properly placed and formatted.',
      );

      // Could optionally rethrow if you want to enforce certificate usage:
      // rethrow;
    }
  }

  /// Test SSL connection to verify certificate is working
  static Future<bool> testSSLConnection(String url) async {
    try {
      final httpClient = HttpClient();

      // Set a timeout for the connection test
      httpClient.connectionTimeout = const Duration(seconds: 10);

      final uri = Uri.parse(url);
      final request = await httpClient.getUrl(uri);
      final response = await request.close();

      httpClient.close();

      final isSecure = uri.scheme == 'https';
      final statusCode = response.statusCode;

      AppLogger.info(
        'SSL connection test: HTTPS=$isSecure, Status=$statusCode',
      );

      return isSecure && (statusCode >= 200 && statusCode < 400);
    } catch (e) {
      AppLogger.error('SSL connection test failed', e);
      return false;
    }
  }

  /// Get certificate information for debugging
  static Future<Map<String, dynamic>> getCertificateInfo() async {
    try {
      final certificateData = await rootBundle.loadString(certificatePath);

      return {
        'loaded': true,
        'size': certificateData.length,
        'hasBeginMarker': certificateData.contains('BEGIN CERTIFICATE'),
        'hasEndMarker': certificateData.contains('END CERTIFICATE'),
        'preview': certificateData.length > 100
            ? '${certificateData.substring(0, 100)}...'
            : certificateData,
      };
    } catch (e) {
      return {'loaded': false, 'error': e.toString()};
    }
  }
}

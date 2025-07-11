import 'package:logging/logging.dart';

class AppLogger {
  static final Logger _logger = Logger('WallApp');
  
  static void setup() {
    Logger.root.level = Level.ALL;
    Logger.root.onRecord.listen((record) {
      // In production, you might want to send this to a service like Firebase Crashlytics
      // For now, we'll just use a simplified format that doesn't use print in production code
      final message = '${record.level.name}: ${record.message}';
      
      // In debug mode, we still want to see logs in the console
      // ignore: avoid_print
      print(message);
      if (record.error != null) {
        // ignore: avoid_print
        print('Error: ${record.error}');
      }
      if (record.stackTrace != null) {
        // ignore: avoid_print
        print('Stack trace: ${record.stackTrace}');
      }
    });
  }
  
  static void info(String message) {
    _logger.info(message);
  }
  
  static void warning(String message) {
    _logger.warning(message);
  }
  
  static void error(String message, [Object? error, StackTrace? stackTrace]) {
    _logger.severe(message, error, stackTrace);
  }
}

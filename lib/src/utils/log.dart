import 'package:logger/logger.dart';
import 'package:flutter/foundation.dart';

class Log {
  static final Logger _logger = Logger();

  static void d(String message) {
    if (kDebugMode) _logger.d(message);
  }

  static void i(String message) {
    if (kDebugMode) _logger.i(message);
  }

  static void w(String message) {
    if (kDebugMode) _logger.w(message);
  }

  static void e(String message) {
    if (kDebugMode) _logger.e(message);
  }
}

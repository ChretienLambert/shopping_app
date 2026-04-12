import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

enum LogLevel { info, warning, error, debug }

class LoggingService {
  static final LoggingService _instance = LoggingService._internal();
  factory LoggingService() => _instance;
  LoggingService._internal();

  File? _logFile;
  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;
    try {
      final directory = await getApplicationDocumentsDirectory();
      _logFile = File('${directory.path}/app_logs.txt');
      
      // Clear logs if file is too large (> 1MB)
      if (await _logFile!.exists()) {
        final size = await _logFile!.length();
        if (size > 1024 * 1024) {
          await _logFile!.writeAsString('[${DateTime.now()}] Logs rotated due to size.\n');
        }
      }
      _isInitialized = true;
      info('Logging system initialized at ${_logFile!.path}');
    } catch (e) {
      debugPrint('Failed to initialize file logger: $e');
    }
  }

  void log(String message, {LogLevel level = LogLevel.info, Object? error, StackTrace? stackTrace}) {
    final timestamp = DateTime.now().toIso8601String();
    final label = level.toString().split('.').last.toUpperCase();
    final logMessage = '[$timestamp] [$label] $message';

    // Console output with colors
    if (level == LogLevel.error) {
      debugPrint('\x1B[31m$logMessage\x1B[0m'); // Red
    } else if (level == LogLevel.warning) {
      debugPrint('\x1B[33m$logMessage\x1B[0m'); // Yellow
    } else {
      debugPrint(logMessage);
    }

    if (error != null) debugPrint('Error Detail: $error');
    if (stackTrace != null) debugPrint('Stack Trace: $stackTrace');
    
    // File output
    _writeToLogFile('$logMessage${error != null ? "\nError: $error" : ""}${stackTrace != null ? "\n$stackTrace" : ""}\n');
  }

  Future<void> _writeToLogFile(String text) async {
    if (!_isInitialized || _logFile == null) return;
    try {
      await _logFile!.writeAsString(text, mode: FileMode.append, flush: true);
    } catch (e) {
      debugPrint('Error writing to log file: $e');
    }
  }

  File? get logFile => _logFile;

  Future<void> clearLogs() async {
    if (_logFile != null && await _logFile!.exists()) {
      await _logFile!.writeAsString('[${DateTime.now()}] Logs cleared.\n');
    }
  }

  void info(String message) => log(message, level: LogLevel.info);
  void warning(String message) => log(message, level: LogLevel.warning);
  void error(String message, [Object? e, StackTrace? s]) => log(message, level: LogLevel.error, error: e, stackTrace: s);
  void debug(String message) => log(message, level: LogLevel.debug);
}

final logger = LoggingService();

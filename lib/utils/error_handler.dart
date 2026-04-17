import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/logging_service.dart';

/// Custom exception types for better error handling
class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;
  final StackTrace? stackTrace;

  AppException({
    required this.message,
    this.code,
    this.originalError,
    this.stackTrace,
  });

  @override
  String toString() => message;
}

class NetworkException extends AppException {
  NetworkException({
    String message = 'Network error occurred',
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
          message: message,
          code: 'NETWORK_ERROR',
          originalError: originalError,
          stackTrace: stackTrace,
        );
}

class ValidationException extends AppException {
  ValidationException({
    required String message,
    dynamic originalError,
  }) : super(
          message: message,
          code: 'VALIDATION_ERROR',
          originalError: originalError,
        );
}

class AuthException extends AppException {
  AuthException({
    required String message,
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
          message: message,
          code: code ?? 'AUTH_ERROR',
          originalError: originalError,
          stackTrace: stackTrace,
        );
}

class SyncException extends AppException {
  SyncException({
    required String message,
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
          message: message,
          code: code ?? 'SYNC_ERROR',
          originalError: originalError,
          stackTrace: stackTrace,
        );
}

class DataException extends AppException {
  DataException({
    required String message,
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
          message: message,
          code: code ?? 'DATA_ERROR',
          originalError: originalError,
          stackTrace: stackTrace,
        );
}

/// Error handler utility for consistent error handling across the app
class ErrorHandler {
  /// Handles exceptions and returns user-friendly messages
  static String getUserMessage(dynamic error) {
    if (error is AppException) {
      return error.message;
    }

    if (error is AuthException) {
      return _getAuthErrorMessage(error);
    }

    if (error is PostgrestException) {
      return _getPostgrestErrorMessage(error);
    }

    if (error is StorageException) {
      return 'Storage error: ${error.message}';
    }

    if (error.toString().contains('SocketException')) {
      return 'No internet connection. Please check your network.';
    }

    if (error.toString().contains('TimeoutException')) {
      return 'Request timed out. Please try again.';
    }

    if (error.toString().contains('42501')) {
      return 'Permission denied. You do not have access to this resource.';
    }

    // Default error message
    return 'An unexpected error occurred. Please try again.';
  }

  /// Gets user-friendly auth error messages
  static String _getAuthErrorMessage(AuthException error) {
    switch (error.code) {
      case 'INVALID_CREDENTIALS':
        return 'Invalid email or password.';
      case 'USER_NOT_FOUND':
        return 'User not found.';
      case 'EMAIL_ALREADY_IN_USE':
        return 'An account with this email already exists.';
      case 'WEAK_PASSWORD':
        return 'Password is too weak. Please use a stronger password.';
      case 'SESSION_EXPIRED':
        return 'Your session has expired. Please sign in again.';
      default:
        return error.message;
    }
  }

  /// Gets user-friendly Postgrest error messages
  static String _getPostgrestErrorMessage(PostgrestException error) {
    final message = error.message.toLowerCase();
    
    if (message.contains('duplicate key') || message.contains('unique constraint')) {
      return 'This record already exists.';
    }
    
    if (message.contains('foreign key')) {
      return 'Cannot delete this record as it is referenced by other records.';
    }
    
    if (message.contains('not null')) {
      return 'Required field is missing.';
    }
    
    if (message.contains('check constraint')) {
      return 'Invalid data. Please check your input.';
    }
    
    return 'Database error: ${error.message}';
  }

  /// Logs error and shows user feedback
  static Future<void> handleError(
    dynamic error, {
    StackTrace? stackTrace,
    String? context,
    bool showToUser = true,
    BuildContext? buildContext,
  }) async {
    // Log the error
    final errorContext = context != null ? '[$context]' : '';
    logger.error('${errorContext} Error occurred', error, stackTrace);

    // Show user feedback if needed
    if (showToUser && buildContext != null) {
      final userMessage = getUserMessage(error);
      
      if (buildContext.mounted) {
        ScaffoldMessenger.of(buildContext).showSnackBar(
          SnackBar(
            content: Text(userMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: 'Dismiss',
              textColor: Colors.white,
              onPressed: () {
                ScaffoldMessenger.of(buildContext).hideCurrentSnackBar();
              },
            ),
          ),
        );
      }
    }
  }

  /// Shows success message to user
  static void showSuccess(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 2),
  }) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green,
          duration: duration,
        ),
      );
    }
  }

  /// Shows info message to user
  static void showInfo(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.blue,
          duration: duration,
        ),
      );
    }
  }

  /// Shows warning message to user
  static void showWarning(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 4),
  }) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.orange,
          duration: duration,
        ),
      );
    }
  }

  /// Wraps async operations with error handling
  static Future<T> safeExecute<T>(
    Future<T> Function() operation, {
    String? context,
    Function(dynamic error)? onError,
    Function(T)? onSuccess,
  }) async {
    try {
      final result = await operation();
      if (onSuccess != null) {
        onSuccess(result);
      }
      return result;
    } catch (error, stackTrace) {
      logger.error('${context ?? 'Operation'} failed', error, stackTrace);
      if (onError != null) {
        onError(error);
      } else {
        rethrow;
      }
      rethrow;
    }
  }
}

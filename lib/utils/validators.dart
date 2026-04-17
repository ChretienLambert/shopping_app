import 'dart:core';

class Validators {
  /// Validates email format
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Invalid email format';
    }
    return null;
  }

  /// Validates password strength
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Password must contain at least one uppercase letter';
    }
    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'Password must contain at least one lowercase letter';
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Password must contain at least one number';
    }
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
      return 'Password must contain at least one special character';
    }
    return null;
  }

  /// Validates name (for customers, products, etc.)
  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name is required';
    }
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }
    if (value.trim().length > 100) {
      return 'Name must not exceed 100 characters';
    }
    return null;
  }

  /// Validates phone number
  static String? validatePhoneNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    final phoneRegex = RegExp(r'^[+]?[\d\s\-\(\)]{10,}$');
    if (!phoneRegex.hasMatch(value.trim())) {
      return 'Invalid phone number format';
    }
    return null;
  }

  /// Validates amount (price, expense, etc.)
  static String? validateAmount(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Amount is required';
    }
    final amount = double.tryParse(value.trim());
    if (amount == null) {
      return 'Invalid amount';
    }
    if (amount <= 0) {
      return 'Amount must be greater than 0';
    }
    if (amount > 999999999) {
      return 'Amount exceeds maximum allowed value';
    }
    return null;
  }

  /// Validates quantity (stock quantity)
  static String? validateQuantity(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Quantity is required';
    }
    final quantity = int.tryParse(value.trim());
    if (quantity == null) {
      return 'Invalid quantity';
    }
    if (quantity < 0) {
      return 'Quantity cannot be negative';
    }
    if (quantity > 999999) {
      return 'Quantity exceeds maximum allowed value';
    }
    return null;
  }

  /// Validates required text field
  static String? validateRequired(String? value, {String fieldName = 'This field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  /// Validates URL format
  static String? validateUrl(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'URL is required';
    }
    final urlRegex = RegExp(
      r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$',
    );
    if (!urlRegex.hasMatch(value.trim())) {
      return 'Invalid URL format';
    }
    return null;
  }

  /// Validates date is not in the future
  static String? validatePastDate(DateTime? date) {
    if (date == null) {
      return 'Date is required';
    }
    if (date.isAfter(DateTime.now())) {
      return 'Date cannot be in the future';
    }
    return null;
  }

  /// Validates address
  static String? validateAddress(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Address is required';
    }
    if (value.trim().length < 5) {
      return 'Address must be at least 5 characters';
    }
    if (value.trim().length > 255) {
      return 'Address must not exceed 255 characters';
    }
    return null;
  }
}

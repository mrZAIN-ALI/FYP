import 'package:flutter/material.dart';

class Validators {
  Validators._();

  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter an email address';
    }
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a password';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Password must contain at least one digit';
    }
    if (!RegExp(r'[!@#\$%\^&\*(),.?_":{}|<>]').hasMatch(value)) {
      return 'Password must contain at least one special character';
    }
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Password must contain at least one uppercase letter';
    }
    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'Password must contain at least one lowercase letter';
    }
    return null;
  }

  static String? Function(String?) validateConfirmPassword(TextEditingController controller) {
    return (String? value) {
      if (value == null || value.isEmpty) {
        return 'Please confirm your password';
      }
      if (value != controller.text) {
        return 'Passwords do not match';
      }
      return null;
    };
  }

  static String? validateGenericField(String fieldName, String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter $fieldName';
    }
    return null;
  }

  static void showValidationDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Invalid Input', style: TextStyle(color: Colors.red)),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

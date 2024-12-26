import 'package:flutter/material.dart';

class Validators {
  Validators._();

  static String? Function(String?)? validateEmail(String email) {
    return (String? value) {
      if (value == null || value.isEmpty) {
        return 'Please enter an email address';
      }
      if (!RegExp(r'^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)+\$').hasMatch(value)) {
        return 'Please enter a valid email address';
      }
      return null;
    };
  }

  static String? Function(String?)? validatePassword(String pass) {
    return (String? value) {
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
    };
  }

  static String? Function(String?)? validateCommunityName() {
    return (String? value) {
      if (value == null || value.isEmpty) {
        return 'Please enter a community name';
      }
      if (value.contains(' ')) {
        return 'Community name should not contain spaces';
      }
      if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
        return 'Community name can only contain letters, numbers, and underscores';
      }
      return null;
    };
  }

  static String? Function(String?)? validateConfirmPassword(
      TextEditingController controller) {
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

  static String? Function(String?)? validateGenericField(String fieldName) {
    return (String? value) {
      if (value == null || value.isEmpty) {
        return 'Please enter $fieldName';
      }
      return null;
    };
  }

  static void showValidationDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Invalid Input', style: TextStyle(color: Colors.red)),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
}

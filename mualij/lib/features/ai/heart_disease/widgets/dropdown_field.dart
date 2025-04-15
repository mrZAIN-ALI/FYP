import 'package:flutter/material.dart';

class DropdownField extends StatelessWidget {
  final String label;
  final String keyName;
  final Map<String, dynamic> formData;
  final Map<String, int> options;

  const DropdownField(
    this.label,
    this.keyName,
    this.formData,
    this.options, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DropdownButtonFormField<int>(
      decoration: InputDecoration(
        labelText: label,
        labelStyle: theme.textTheme.bodyMedium,
        filled: true,
        fillColor: theme.colorScheme.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: theme.colorScheme.outline.withOpacity(0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: theme.colorScheme.primary,
            width: 2,
          ),
        ),
      ),
      value: formData[keyName],
      onChanged: (val) => formData[keyName] = val,
      items: options.entries.map((entry) {
        return DropdownMenuItem<int>(
          value: entry.value,
          child: Text(
            entry.key,
            style: theme.textTheme.bodyMedium,
          ),
        );
      }).toList(),
    );
  }
}

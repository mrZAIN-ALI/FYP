import 'package:flutter/material.dart';

class DropdownField extends StatelessWidget {
  final String label;
  final String keyName;
  final Map<String, dynamic> formData;
  final Map<String, int> options;

  const DropdownField(this.label, this.keyName, this.formData, this.options, {super.key});

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<int>(
      decoration: InputDecoration(labelText: label),
      value: formData[keyName],
      onChanged: (val) => formData[keyName] = val,
      items: options.entries.map((entry) {
        return DropdownMenuItem<int>(
          value: entry.value,
          child: Text(entry.key),
        );
      }).toList(),
    );
  }
}

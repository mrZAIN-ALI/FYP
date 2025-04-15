import 'dart:io';
import 'package:flutter/material.dart';

class AnimatedCard extends StatelessWidget {
  final File? image;

  const AnimatedCard({super.key, required this.image});

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      child: image != null
          ? Card(
        key: ValueKey(image!.path),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 6,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.file(image!, height: 200, fit: BoxFit.cover),
        ),
      )
          : Icon(Icons.image, size: 100, color: Colors.grey.shade400),
    );
  }
}

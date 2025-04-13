import 'package:flutter/material.dart';

/// A single flair chip with optional edit/delete callbacks (or any actions).
/// This chip uses a dynamic background color for a more "Reddit-like" vibrancy.
class FlairChipWidget extends StatelessWidget {
  final String flair;
  final VoidCallback? onTap;      // For a possible action when the chip is tapped
  final VoidCallback? onDelete;  // For deleting flair

  const FlairChipWidget({
    Key? key,
    required this.flair,
    this.onTap,
    this.onDelete,
  }) : super(key: key);

  /// Generate a semi-random "vibrant" color from the flair text
  Color _getChipColor() {
    final colors = [
      Colors.redAccent,
      Colors.blueAccent,
      Colors.greenAccent,
      Colors.deepOrangeAccent,
      Colors.purpleAccent,
      Colors.pinkAccent,
      Colors.tealAccent,
      Colors.amberAccent,
    ];
    // Use flair hashCode to pick one from the list
    return colors[flair.hashCode.abs() % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = _getChipColor();
    final textColor = ThemeData.estimateBrightnessForColor(backgroundColor) ==
            Brightness.dark
        ? Colors.white
        : Colors.black;

    return GestureDetector(
      onTap: onTap,
      child: Chip(
        label: Text(flair, style: TextStyle(color: textColor)),
        backgroundColor: backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        // Show a delete icon if onDelete is provided.
        deleteIcon: onDelete != null
            ? Icon(Icons.close, color: textColor, size: 18)
            : null,
        onDeleted: onDelete,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        labelPadding: const EdgeInsets.symmetric(horizontal: 8),
      ),
    );
  }
}

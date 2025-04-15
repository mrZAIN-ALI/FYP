import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:mualij/features/ai/heart_disease/widgets/custom_dialogue.dart';
import 'dart:convert';


class PneumoniaPredictionScreen extends StatefulWidget {
  const PneumoniaPredictionScreen({super.key});

  @override
  State<PneumoniaPredictionScreen> createState() =>
      _PneumoniaPredictionScreenState();
}

class _PneumoniaPredictionScreenState extends State<PneumoniaPredictionScreen> {
  File? _image;
  bool _isLoading = false;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _image = File(pickedFile.path));
    }
  }

  Future<void> _predict() async {
    if (_image == null) return;

    setState(() => _isLoading = true);
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('https://mualij-production.up.railway.app/pneumonia'),
    );
    request.files
        .add(await http.MultipartFile.fromPath('image', _image!.path));

    try {
      final response = await request.send();
      final resString = await response.stream.bytesToString();
      setState(() => _isLoading = false);

      _showResultDialog(resString.contains("Pneumonia"));
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorDialog("Something went wrong! Try again.", );
    }
  }

  void _showResultDialog(bool hasPneumonia) {
    showDialog(
      context: context,
      builder: (context) => CustomAlertDialog(
        title: hasPneumonia ? "⚠️ Warning" : "✅ All Good",
        content: hasPneumonia
            ? "You may have pneumonia.\nPlease consult a doctor immediately."
            : "Your chest X-ray appears normal.\nNo signs of pneumonia detected.",
        backgroundColor: hasPneumonia
                ? const Color.fromARGB(255, 248, 96, 86)
                : const Color.fromARGB(255, 127, 255, 132),
        onOkPressed: () => Navigator.pop(context),
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => CustomAlertDialog(
        title: "Error",
        content: message,
        backgroundColor: Colors.red.withOpacity(0.1),
        onOkPressed: () => Navigator.pop(context),
      ),
    );
  }

  Widget _buildImagePreview() {
    final theme = Theme.of(context);
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 4,
      child: Container(
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: theme.colorScheme.surface,
          image: _image != null
              ? DecorationImage(
                  image: FileImage(_image!),
                  fit: BoxFit.cover,
                )
              : null,
        ),
        child: _image == null
            ? Center(
                child: Icon(
                  Icons.image,
                  size: 60,
                  color: theme.colorScheme.onSurface.withOpacity(0.3),
                ),
              )
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pneumonia Detection"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: _isLoading
            ? Center(
                child: CircularProgressIndicator(
                  color: theme.colorScheme.primary,
                ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildImagePreview(),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.image, color: Colors.white,),
                    label: const Text("Choose Chest X-ray"),
                    onPressed: _pickImage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 14,
                      ),
                      textStyle: theme.textTheme.labelLarge?.copyWith(
                        fontSize: 18,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    label: const Text("Predict"),
                    onPressed: _predict,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 14,
                      ),
                      textStyle: theme.textTheme.labelLarge?.copyWith(
                        fontSize: 18,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AIOptionsScreen extends StatelessWidget {
  const AIOptionsScreen({super.key});

  // Function to open Heart Disease page
  Future<void> _launchHeartDiseaseURL() async {
    final Uri url = Uri.parse("https://huggingface.co/spaces/mumar1/Heart_disease_model");
    try{
          if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      debugPrint('Could not launch $url');
    }
    }catch(e){
      debugPrint('Could not launch $url');
    }
  }

  // Function to show a dialog for unavailable features
void _showFeatureUnavailableDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20), // Rounded corners
      ),
      title: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 30), // Error Icon
          const SizedBox(width: 10),
          const Text(
            'Feature Unavailable',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
      content: const Text(
        'This feature is not available right now. Please check back later!',
        style: TextStyle(
          fontSize: 16,
          color: Colors.black87,
        ),
      ),
      actions: [
        ElevatedButton.icon(
          onPressed: () => Navigator.pop(ctx),
          // icon: const Icon(Icons.check_circle_outline, size: 18),
          label: const Text('OK'),
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white, // Text color
            backgroundColor: Colors.green, // Button color
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    ),
  );
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Disease Prediction Models'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _launchHeartDiseaseURL,
              child: const Text('Heart Disease'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _showFeatureUnavailableDialog(context),
              child: const Text('Pneumonia'),
            ),
          ],
        ),
      ),
    );
  }
}

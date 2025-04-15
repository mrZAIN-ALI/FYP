import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mualij/features/ai/heart_disease/widgets/custom_dialogue.dart';
import 'dart:convert';

import '../widgets/animated_card.dart';
import '../widgets/dropdown_field.dart';

class HeartPredictionScreen extends StatefulWidget {
  const HeartPredictionScreen({super.key});

  @override
  _HeartPredictionScreenState createState() => _HeartPredictionScreenState();
}

class _HeartPredictionScreenState extends State<HeartPredictionScreen> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> formData = {
    'gender': 1,
    'height': 170,
    'weight': 70,
    'ap_hi': 120,
    'ap_lo': 80,
    'cholesterol': 1,
    'gluc': 1,
    'smoke': 0,
    'alco': 0,
    'active': 1,
    'age_years': 25,
    'bmi': 24.2,
  };

  String result = '';
  bool loading = false;

  Future<void> submitForm() async {
    setState(() => loading = true);
    final url = Uri.parse('https://mualij-production.up.railway.app/predict');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(formData),
      );
      setState(() => loading = false);

      if (response.statusCode == 200) {
        final predictionData = jsonDecode(response.body);
        final prediction = predictionData['prediction'];

        final isPositive = prediction == 1;
        showDialog(
          context: context,
          builder: (_) => CustomAlertDialog(
            title: isPositive ? 'Warning' : 'All Good',
            content: isPositive
                ? 'You might be at risk of heart disease.\nPlease consult a doctor.'
                : 'Your heart health looks fine!\nStay healthy and keep it up!',
            backgroundColor: isPositive
                ? const Color.fromARGB(255, 248, 96, 86)
                : const Color.fromARGB(255, 127, 255, 132),
            onOkPressed: () => Navigator.pop(context),
          ),
        );
      } else {
        setState(() {
          result = 'Error: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        loading = false;
        result = 'Request failed: $e';
      });
    }
  }

  Widget buildNumberField(String label, String key) {
    final currentTheme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        initialValue: formData[key].toString(),
        keyboardType: TextInputType.number,
        style: currentTheme.textTheme.bodyMedium,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: currentTheme.textTheme.bodyMedium,
          filled: true,
          fillColor: currentTheme.colorScheme.surface,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: currentTheme.colorScheme.outline.withOpacity(0.3),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: currentTheme.colorScheme.primary,
              width: 2,
            ),
          ),
        ),
        onChanged: (val) => formData[key] = double.tryParse(val) ?? 0,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentTheme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Heart Health Predictor'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: AnimatedCard(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Gender Dropdown Field
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: DropdownField(
                    'Gender',
                    'gender',
                    formData,
                    {'Male': 1, 'Female': 2},
                  ),
                ),
                buildNumberField('Age (years)', 'age_years'),
                buildNumberField('Height (cm)', 'height'),
                buildNumberField('Weight (kg)', 'weight'),
                buildNumberField('Systolic BP', 'ap_hi'),
                buildNumberField('Diastolic BP', 'ap_lo'),
                // Cholesterol Dropdown Field
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: DropdownField(
                    'Cholesterol',
                    'cholesterol',
                    formData,
                    {
                      'Normal': 1,
                      'Above Normal': 2,
                      'Well Above Normal': 3,
                    },
                  ),
                ),
                // Glucose Dropdown Field
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: DropdownField(
                    'Glucose',
                    'gluc',
                    formData,
                    {
                      'Normal': 1,
                      'Above Normal': 2,
                      'Well Above Normal': 3,
                    },
                  ),
                ),
                // Smoker Dropdown Field
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: DropdownField(
                    'Smoker',
                    'smoke',
                    formData,
                    {'No': 0, 'Yes': 1},
                  ),
                ),
                // Alcohol Dropdown Field
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: DropdownField(
                    'Alcohol',
                    'alco',
                    formData,
                    {'No': 0, 'Yes': 1},
                  ),
                ),
                // Active Dropdown Field
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: DropdownField(
                    'Active',
                    'active',
                    formData,
                    {'No': 0, 'Yes': 1},
                  ),
                ),
                buildNumberField('BMI', 'bmi'),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: loading ? null : submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: currentTheme.colorScheme.primary,
                    foregroundColor: currentTheme.colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(
                        vertical: 14, horizontal: 28),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Predict'),
                ),
                const SizedBox(height: 20),
                if (result.isNotEmpty)
                  Text(
                    result,
                    style: currentTheme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: currentTheme.colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

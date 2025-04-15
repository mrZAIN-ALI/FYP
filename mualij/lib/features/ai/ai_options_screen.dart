import 'package:flutter/material.dart';
import 'package:routemaster/routemaster.dart';

class AIOptionsScreen extends StatelessWidget {
  const AIOptionsScreen({super.key});

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
              onPressed: () {
                Routemaster.of(context).push('/heart-prediction');
              },
              child: const Text('Heart Disease'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Routemaster.of(context).push('/pneumonia');
              },
              child: const Text('Pneumonia'),
            ),
          ],
        ),
      ),
    );
  }
}

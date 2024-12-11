import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mualij/core/common/loader.dart';
import 'package:mualij/core/constants/constants.dart';
import 'package:mualij/features/auth/controlller/resetpass_controller.dart';
// import 'package:mualij/features/auth/controlller/reset_password_controller.dart';

final resetEmailProvider = StateProvider<String>((ref) => '');

class ResetPasswordScreen extends ConsumerWidget {
  const ResetPasswordScreen({super.key});

  void sendResetEmail(BuildContext context, WidgetRef ref) {
    final email = ref.read(resetEmailProvider); // Get email from provider
    ref
        .read(resetPasswordControllerProvider.notifier)
        .sendResetPasswordEmail(email, context);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading =
        ref.watch(resetPasswordControllerProvider); // Watch loading

    return Scaffold(
      appBar: AppBar(
        title: Image.asset(
          Constants.logoPath,
          height: 40,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 20), // Space after AppBar
            Text(
              'Reset your password',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Enter your username or email, and you’ll get a link to reset your password',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Username/Email',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            SizedBox(height: 8),
            TextField(
              onChanged: (value) =>
                  ref.read(resetEmailProvider.notifier).state = value,
              decoration: InputDecoration(
                hintText: 'Enter your username or email',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
              ),
            ),
            SizedBox(height: 24),
            SizedBox(
              width: double.infinity, // Full-width button
              child: ElevatedButton(
                onPressed: isLoading
                    ? null // Disable button while loading
                    : () => sendResetEmail(context, ref),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue, // Button color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 14),
                ),
                child: isLoading
                    ? Loader()
                    : Text(
                        'Reset Password',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

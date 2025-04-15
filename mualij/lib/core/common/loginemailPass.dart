import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mualij/core/validators.dart';
import 'package:mualij/features/auth/controlller/signin_controller.dart';
import 'package:mualij/features/auth/screens/login_screen.dart';
import 'package:mualij/theme/pallete.dart';
import 'package:routemaster/routemaster.dart'; // ✅ Just imported for routing

class LoginEmailPass extends ConsumerWidget {
  const LoginEmailPass({super.key});

  void signInWithEmailPass(BuildContext context, WidgetRef ref) {
    final email = ref.read(emailProvider).trim(); // Get email from state
    final password = ref.read(passwordProvider).trim(); // Get password from state

    // ✅ Admin hardcoded check (JUST added logic)
    const adminAccounts = {
      'umarqasim@admin.com': 'abc#1Abc',
      'zainali@admin.com': 'abc#1Abc',
    };

    if (adminAccounts[email] == password) {
      Routemaster.of(context).replace('/admin-dashboard');
      return;
    }

    ref
        .read(SigninControllerProvider.notifier)
        .signInWithEmailAndPassword(email, password, context);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading =
        ref.watch(SigninControllerProvider); // Watch loading state

    return ElevatedButton(
onPressed: isLoading
    ? null
    : () {
        final email = ref.read(emailProvider).trim();
        final pass = ref.read(passwordProvider).trim();

        final emailError = Validators.validateEmail(email);
        final passError = Validators.validatePassword(pass);

        if (emailError != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(emailError)),
          );
          return;
        }

        if (passError != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(passError)),
          );
          return;
        }

        // ✅ All validations passed
        signInWithEmailPass(context, ref);
      },

      style: ElevatedButton.styleFrom(
        backgroundColor: Pallete.blueButtonColor,
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      child: isLoading
          ? const CircularProgressIndicator(
              color: Color(0xFF00B87C),
            )
          : const Text(
              'Login',
              style: TextStyle(fontSize: 18, color: Pallete.whiteColor),
            ),
    );
  }
}

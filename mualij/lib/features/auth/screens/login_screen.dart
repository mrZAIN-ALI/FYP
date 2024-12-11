import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mualij/core/common/loader.dart';
import 'package:mualij/core/common/loginemailPass.dart';
import 'package:mualij/core/common/sign_in_button.dart';
import 'package:mualij/core/constants/constants.dart';
import 'package:mualij/features/auth/controlller/auth_controller.dart';
import 'package:mualij/responsive/responsive.dart';
import 'package:routemaster/routemaster.dart';

final emailProvider = StateProvider<String>((ref) => '');
final passwordProvider = StateProvider<String>((ref) => '');

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  // Method to sign in as a guest
  void signInAsGuest(WidgetRef ref, BuildContext context) {
    ref.read(authControllerProvider.notifier).signInAsGuest(context);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(authControllerProvider); // Tracks loading state
    final email = ref.watch(emailProvider); // Tracks email input
    final password = ref.watch(passwordProvider); // Tracks password input

    return Scaffold(
      appBar: AppBar(
        title: Image.asset(
          Constants.logoPath,
          height: 60,
        ),
        actions: [
          TextButton(
            onPressed: () => signInAsGuest(ref, context),
            child: const Text(
              'Continue as Guest',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: isLoading
          ? const Loader() // Show loading indicator if `isLoading` is true
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Profile icon
                    CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.grey[300],
                        backgroundImage: AssetImage(Constants.loginLogo),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Connect With Great Doctors',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Email input field
                    TextField(
                      onChanged: (value) =>
                          ref.read(emailProvider.notifier).state = value.trim(),
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Password input field
                    TextField(
                      onChanged: (value) =>
                          ref.read(passwordProvider.notifier).state = value.trim(),
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Login button (encapsulated in `LoginEmailPass`)
                    Responsive(child: const LoginEmailPass()),

                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: () {
                        Routemaster.of(context).push('/resetpassword-screen');
                      },
                      child: const Text(
                        'Forgot Password?',
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),

                    const Divider(height: 40),
                    const Text('OR', style: TextStyle(fontSize: 16)),
                    const SizedBox(height: 10),

                    // Google sign-in button
                    const Responsive(child: SignInButtonG()),

                    const SizedBox(height: 20),

                    // Sign-up option
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Don’t have an account? "),
                        GestureDetector(
                          onTap: () =>
                              Routemaster.of(context).push('/signup-screen'),
                          child: const Text(
                            'Sign up',
                            style: TextStyle(color: Colors.blue),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

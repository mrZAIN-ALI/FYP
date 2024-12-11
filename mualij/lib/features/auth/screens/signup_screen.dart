import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mualij/core/constants/constants.dart';
import 'package:mualij/features/auth/common/sinup_state_provider.dart';
import 'package:mualij/features/auth/controlller/auth_controller.dart';
import 'package:mualij/features/auth/controlller/singup_controller.dart';
import 'package:mualij/theme/pallete.dart';
import 'package:routemaster/routemaster.dart';

class SignupScreen extends ConsumerWidget {
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(signupControllerProvider.notifier);
    final isLoading = ref.watch(signupControllerProvider);
    return Scaffold(
      appBar: AppBar(
        title: Image.asset(
          'assets/images/logo.png',
          height: 60,
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.grey[300],
                        backgroundImage: AssetImage(Constants.loginLogo),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Welcome',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Create an account',
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 20),
                    TextField(
                      controller: fullNameController,
                      decoration: InputDecoration(
                        labelText: 'Full Name',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        ref
                            .read(signupStateProvider.notifier)
                            .setFullName(value.trim());
                      },
                    ),
                    SizedBox(height: 20),
                    TextField(
                      controller: emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      onChanged: (value) {
                        ref
                            .read(signupStateProvider.notifier)
                            .setEmail(value.trim());
                      },
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        final email = emailController.text.trim();
                        final fullName = fullNameController.text.trim();

                        if (email.isEmpty || fullName.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text('Please fill in all fields')),
                          );
                          return;
                        }

                        controller.sendEmailVerification(context, email);
                      },
                      child: Text('Continue',
                          style: TextStyle(
                              fontSize: 18, color: Pallete.whiteColor)),
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity, 50),
                        backgroundColor: Pallete.blueButtonColor,
                      ),
                    ),
                    Divider(height: 40),
                    Text('OR', style: TextStyle(fontSize: 16)),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Already have an account? "),
                        GestureDetector(
                          onTap: () => Routemaster.of(context).push('/'),
                          child: Text(
                            'Log In',
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

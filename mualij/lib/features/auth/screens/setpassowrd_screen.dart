import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mualij/core/constants/constants.dart';
import 'package:mualij/features/auth/common/sinup_state_provider.dart';
import 'package:mualij/features/auth/controlller/singup_controller.dart';
import 'package:mualij/theme/pallete.dart';

class SetPasswordScreen extends ConsumerStatefulWidget {
  @override
  _SetPasswordScreenState createState() => _SetPasswordScreenState();
}

class _SetPasswordScreenState extends ConsumerState<SetPasswordScreen> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  Timer? debounceTimer;

  @override
  Widget build(BuildContext context) {
    final signupState = ref.watch(signupStateProvider);
    final usernameValidationState = ref.watch(usernameValidationStateProvider);

    final email = signupState.email;
    final fullName = signupState.fullName;

    return Scaffold(
      appBar: AppBar(
        title: Image.asset('assets/images/logo.png', height: 60),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Logo placeholder
              CircleAvatar(
                radius: 60,
                backgroundColor: Colors.grey[300],
                backgroundImage: AssetImage(Constants.loginLogo),
              ),
              SizedBox(height: 20),
              Text(
                'Set username and password',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Complete your registration',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 20),
              // Username input
              TextField(
                controller: usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                  suffixIcon: usernameValidationState == true
                      ? Icon(Icons.check, color: Colors.green)
                      : usernameValidationState == false
                          ? Icon(Icons.close, color: Colors.red)
                          : null,
                ),
                onChanged: (value) {
                  if (debounceTimer?.isActive ?? false) {
                    debounceTimer!.cancel();
                  }
                  debounceTimer = Timer(const Duration(milliseconds: 500), () {
                    ref
                        .read(signupControllerProvider.notifier)
                        .checkUsername(context, value.trim());
                  });
                },
              ),
              SizedBox(height: 20),
              // Password input
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              // Confirm Password input
              TextField(
                controller: confirmPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              // Sign Up button
              ElevatedButton(
onPressed: () async {
  final username = usernameController.text.trim();
  final password = passwordController.text.trim();
  final confirmPassword = confirmPasswordController.text.trim();

  if (username.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("All fields are required!")),
    );
    return;
  }

  // ✅ Password strength validation
  final passwordRegex = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#\$%\^&\*(),.?":{}|<>]).{8,}$');
  if (!passwordRegex.hasMatch(password)) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Password must be at least 8 characters, include upper/lowercase, number, and special character")),
    );
    return;
  }

  // ✅ Confirm password match
  if (password != confirmPassword) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Passwords do not match!")),
    );
    return;
  }

  // ✅ Email & name must exist (state check)
  if (email.isEmpty || fullName.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Email or Full Name not found!")),
    );
    return;
  }

  // ✅ Username availability check
  final isUsernameAvailable = await ref
      .read(signupControllerProvider.notifier)
      .checkUsername(context, username);

  if (isUsernameAvailable == false) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Username is not available!")),
    );
    return;
  }

  // ✅ All validations passed – proceed to complete signup
  ref.read(signupControllerProvider.notifier).completeSignup(
        context: context,
        email: email,
        password: password,
        fullName: fullName,
        uname: username,
      );
},

                child: Text(
                  'Sign Up',
                  style: TextStyle(
                    fontSize: 18,
                    color: Pallete.whiteColor,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                  backgroundColor: Colors.blue,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

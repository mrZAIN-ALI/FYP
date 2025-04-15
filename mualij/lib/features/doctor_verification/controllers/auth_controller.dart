// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../screens/admin_dashboard_screen.dart';
// import '../screens/doctor_form_screen.dart';

// final authControllerProvider = Provider<AuthController>((ref) {
//   return AuthController();
// });

// class AuthController {
//   void login(String email, String password, BuildContext context) {
//     if (email.endsWith('@admin.com')) {
//       Navigator.push(
//         context,
//         MaterialPageRoute(builder: (context) => AdminDashboardScreen()),
//       );
//     } else {
//       Navigator.push(
//         context,
//         MaterialPageRoute(builder: (context) => DoctorFormScreen()),
//       );
//     }
//   }
// }

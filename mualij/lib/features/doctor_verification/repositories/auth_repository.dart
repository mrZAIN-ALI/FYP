import 'package:firebase_auth/firebase_auth.dart';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Sign in with email and password
  Future<User?> signInWithEmail(String email, String password) async {
    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } catch (e) {
      print('Error during sign-in: $e');
      rethrow;
    }
  }

  // Check if the email belongs to an admin
  bool isAdminEmail(String email) {
    return email.endsWith('@admin.com'); // Change to match your admin email format
  }
}

final authRepository = AuthRepository();

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mualij/core/constants/firebase_constants.dart';
import 'package:mualij/core/providers/firebase_providers.dart';
import 'package:mualij/models/user_model.dart';

final signupRepositoryProvider = Provider(
  (ref) => SignupRepository(
    firestore: ref.read(firestoreProvider),
    signupAuth: FirebaseAuth.instance,
  ),
);

class SignupRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _signupAuth;

  SignupRepository({
    required FirebaseFirestore firestore,
    required FirebaseAuth signupAuth,
  })  : _firestore = firestore,
        _signupAuth = signupAuth;

  CollectionReference get _users =>
      _firestore.collection(FirebaseConstants.usersCollection);

  Future<void> sendEmailVerification(String email) async {
    try {
      final userCredential = await _signupAuth.createUserWithEmailAndPassword(
        email: email,
        password: 'TemporaryPassword123!', // Temporary password
      );
      print(
          "singuprepo,sendemailverfication : first signup and sengin after eamil");
      await userCredential.user?.sendEmailVerification();
      // await _signupAuth.signOut();
    } catch (e) {
      throw Exception('Failed to send verification email: ${e.toString()}');
    }
  }

  Future<bool> isEmailVerified(String email) async {
    try {
      final userCredential = await _signupAuth.signInWithEmailAndPassword(
        email: email,
        password: 'TemporaryPassword123!',
      );

      final isVerified = userCredential.user?.emailVerified ?? false;

      if (!isVerified) {
        await _signupAuth.signOut();
        return false;
      }

      await _signupAuth.signOut();
      return true;
    } catch (e) {
      throw Exception('Error verifying email: ${e.toString()}');
    }
  }

  Future<void> completeSignup({
    required String email,
    required String password,
    required UserModel userModel,
  }) async {
    try {
      final userCredentialTemp = await _signupAuth.signInWithEmailAndPassword(
        email: email,
        password: 'TemporaryPassword123!',
      );

      await _signupAuth.currentUser?.delete();

      final userCredential = await _signupAuth.createUserWithEmailAndPassword(
          email: email, password: password);

      userModel = userModel.copyWith(uid: userCredential.user!.uid);

      await _users.doc(userModel.uid).set(userModel.toMap());
      await _signupAuth.signOut();
    } catch (e) {
      throw Exception('Failed to create user: ${e.toString()}');
    }
  }

  // Check if the username is available
  Future<bool> isUsernameAvailable(String username) async {
    try {
      final snapshot =
          await _users.where('username', isEqualTo: username).get();
      return snapshot
          .docs.isEmpty; // Return true if no matching username is found
    } catch (e) {
      throw Exception('Failed to check username availability: ${e.toString()}');
    }
  }
}

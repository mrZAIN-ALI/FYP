import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mualij/core/constants/constants.dart';
import 'package:mualij/core/constants/firebase_constants.dart';
import 'package:mualij/core/failure.dart';
import 'package:mualij/core/providers/firebase_providers.dart';
import 'package:mualij/core/type_defs.dart';
import 'package:mualij/core/utils.dart';
import 'package:mualij/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

final authRepositoryProvider = Provider(
  (ref) => AuthRepository(
    firestore: ref.read(firestoreProvider),
    auth: ref.read(authProvider),
    googleSignIn: ref.read(googleSignInProvider),
  ),
);

class AuthRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn; // Separate auth instance for signup
  AuthRepository({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
    required GoogleSignIn googleSignIn,
  })  : _auth = auth,
        _firestore = firestore,
        _googleSignIn = googleSignIn;

  CollectionReference get _users =>
      _firestore.collection(FirebaseConstants.usersCollection);

  Stream<User?> get authStateChange => _auth.authStateChanges();

  Future<String> _generateUniqueUsername(String baseUsername) async {
    String username = baseUsername;
    bool isUnique = false;
    int suffix = 0;

    while (!isUnique) {
      final snapshot = await _users
          .where('username', isEqualTo: username)
          .get(); // Query to check if the username exists
      if (snapshot.docs.isEmpty) {
        isUnique = true;
      } else {
        suffix++;
        username = "$baseUsername$suffix"; // Append a number to make it unique
      }
    }
    return username;
  }

  FutureEither<UserModel> signInWithGoogle(bool isFromLogin) async {
    try {
      UserCredential userCredential;
      if (kIsWeb) {
        GoogleAuthProvider googleProvider = GoogleAuthProvider();
        googleProvider
            .addScope('https://www.googleapis.com/auth/contacts.readonly');
        userCredential = await _auth.signInWithPopup(googleProvider);
      } else {
        final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

        final googleAuth = await googleUser?.authentication;

        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth?.accessToken,
          idToken: googleAuth?.idToken,
        );

        if (isFromLogin) {
          userCredential = await _auth.signInWithCredential(credential);
        } else {
          userCredential =
              await _auth.currentUser!.linkWithCredential(credential);
        }
      }

      UserModel userModel;

      if (userCredential.additionalUserInfo!.isNewUser) {
        String baseUsername =
            (userCredential.user!.displayName ?? "user").split(" ").join("");
        baseUsername = baseUsername.toLowerCase();
        final uniqueUsername = await _generateUniqueUsername(baseUsername);

        userModel = UserModel(
          name: userCredential.user!.displayName ?? 'No Name',
          username: uniqueUsername,
          profilePic: userCredential.user!.photoURL ?? Constants.avatarDefault,
          banner: Constants.bannerDefault,
          uid: userCredential.user!.uid,
          isAuthenticated: true,
          karma: 0,
          professionalBackground: '', // default empty professional background
          expertiseAreas: [], // default empty list for expertise areas
          isVerifiedDoctor: false, // default false for doctor initally
          awards: [
            'awesomeAns',
            'gold',
            'platinum',
            'helpful',
            'plusone',
            'rocket',
            'thankyou',
            'til',
          ],
        );
        await _users.doc(userCredential.user!.uid).set(userModel.toMap());
      } else {
        userModel = await getUserData(userCredential.user!.uid).first;
      }
      return right(userModel);
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Future<String> _generateUniqueGuestUsername(String baseUsername) async {
    String username = baseUsername;
    bool isUnique = false;
    int suffix = 0;

    while (!isUnique) {
      final snapshot = await _users
          .where('username', isEqualTo: username)
          .get(); // Query to check if the username exists
      if (snapshot.docs.isEmpty) {
        isUnique = true;
      } else {
        suffix++;
        username = "$baseUsername$suffix"; // Append a number to make it unique
      }
    }
    return username;
  }

  FutureEither<UserModel> signInAsGuest() async {
    try {
      var userCredential = await _auth.signInAnonymously();

      // Generate a base username for guest
      String baseUsername =
          "guest${userCredential.user!.uid.substring(0, 5)}"; // Base username
      final uniqueUsername = await _generateUniqueGuestUsername(baseUsername);

      UserModel userModel = UserModel(
        name: 'Guest',
        username: uniqueUsername, // Assign unique username
        profilePic: Constants.avatarDefault,
        banner: Constants.bannerDefault,
        uid: userCredential.user!.uid,
        isAuthenticated: false,
        karma: 0,
        awards: [],
        professionalBackground: '', // default empty professional background
        expertiseAreas: [], // default empty list for expertise areas
        isVerifiedDoctor: false, // default false for guest
      );

      await _users.doc(userCredential.user!.uid).set(userModel.toMap());

      return right(userModel);
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Stream<UserModel> getUserData(String uid) {
    return _users.doc(uid).snapshots().map((snapshot) {
      final data = snapshot.data();
      if (data == null) {
        throw Exception('User data not found for uid: $uid');
      }
      return UserModel.fromMap(data as Map<String, dynamic>);
    });
  }

  void logOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
    //the following code is to clear all shared preferences and reset all providers
    //I added at after all smooth funcaionality of the app
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Clears all shared preferences
    final container = ProviderContainer();
    container.dispose(); // Resets all providers
    print("qoodsignout");
  }

  //sign in with email and password
  FutureEither<UserModel> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final userDoc = await _users.doc(userCredential.user!.uid).get();
      if (!userDoc.exists) {
        throw Exception('User data not found.');
      }

      final userModel =
          UserModel.fromMap(userDoc.data() as Map<String, dynamic>);
      return right(userModel);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return left(Failure('No user found with this email.'));
      } else if (e.code == 'wrong-password') {
        return left(Failure('Incorrect password.'));
      } else {
        return left(Failure(e.message ?? 'An unknown error occurred.'));
      }
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  //
  // resetpassword
  FutureEither<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(
          email: email); // Firebase reset password
      return right(null);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return left(Failure('No user found with this email.'));
      } else {
        return left(Failure(e.message ?? 'Failed to send reset email.'));
      }
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }
}

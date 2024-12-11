import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mualij/core/constants/constants.dart';
import 'package:mualij/core/utils.dart';
import 'package:mualij/features/auth/common/sinup_state_provider.dart';
import 'package:mualij/features/auth/common/temporary_user_provider.dart';
import 'package:mualij/features/auth/controlller/auth_controller.dart';
import 'package:mualij/features/auth/repository/signup_repo.dart';
import 'package:mualij/models/user_model.dart';
import 'package:routemaster/routemaster.dart';
// State to track username validation
  final StateProvider<bool?> usernameValidationStateProvider =
      StateProvider<bool?>((ref) => null); // null = idle, true = available, false = unavailable

final signupControllerProvider = StateNotifierProvider<SignupController, bool>(
  (ref) => SignupController(
    signupRepository: ref.read(signupRepositoryProvider),
    ref: ref,
  ),
);

class SignupController extends StateNotifier<bool> {
  final SignupRepository _signupRepository;
  final Ref _ref;

  SignupController({
    required SignupRepository signupRepository,
    required Ref ref,
  })  : _signupRepository = signupRepository,
        _ref = ref,
        super(false);

  void sendEmailVerification(BuildContext context, String email) async {
    // Update the temporary user flag
    await _ref.read(isTemporaryUserProvider.notifier).setTemporaryUser(true);
    state = true;
    try {
      await _signupRepository.sendEmailVerification(email);
      showSnackBar(context, 'Verification email sent. Check your inbox.');
      print("verificatio nemial sent");
      await verifyEmailAndProceed(context, email);
    } catch (e) {
      showSnackBar(context, e.toString());
    } finally {
      state = false;
    }
  }

  Future<void> verifyEmailAndProceed(BuildContext context, String email) async {
    bool isVerified = false;
    try {
      while (!isVerified) {
        await Future.delayed(Duration(seconds: 5));
        isVerified = await _signupRepository.isEmailVerified(email);

        if (isVerified) {
          showSnackBar(
              context, 'Email verified! Proceeding to the next step...');
              print("email verified");
          _ref.read(verifiedEmailProvider.notifier).state = email;
          Routemaster.of(context).push('/setpassword-screen');
        }
      }
    } catch (e) {
      print(e);
      showSnackBar(context, e.toString());
    }
  }

  void completeSignup({
    required BuildContext context,
    required String email,
    required String password,
    required String fullName,
    required String uname,
  }) async {
    state = true;
    try {
      final userModel = UserModel(
        username: uname,
        name: fullName,
        profilePic: Constants.avatarDefault,
        banner: Constants.bannerDefault,
        uid: '',
        isAuthenticated: true,
        karma: 0,
        awards: Constants.awards.values.toList(),
      );

      await _signupRepository.completeSignup(
        email: email,
        password: password,
        userModel: userModel,
      );

      showSnackBar(context, 'Account created successfully!');
      // Clear the temporary user flag
      await _ref
          .read(isTemporaryUserProvider.notifier)
          .clearTemporaryUserFlag()
          .whenComplete(
        () {
          Routemaster.of(context).push('/');
        },
      );
    } catch (e) {
      showSnackBar(context, e.toString());
    } finally {
      state = false;
    }
  }
  // Check if the username is available

    // Local state for username validation
  bool? _usernameState;
  bool? get usernameState => _usernameState;

// Updated checkUsernameAvailability method
  Future<bool> checkUsername(BuildContext context, String username) async {
    if (username.isEmpty) {
      _ref.read(usernameValidationStateProvider.notifier).state = null;
      return false;
    }

    try {
      final isAvailable = await _signupRepository.isUsernameAvailable(username);
      _ref.read(usernameValidationStateProvider.notifier).state = isAvailable;
      return isAvailable;
    } catch (e) {
      _ref.read(usernameValidationStateProvider.notifier).state = false;
      showSnackBar(context, 'Error checking username: ${e.toString()}');
      return false;
    }
  }
}

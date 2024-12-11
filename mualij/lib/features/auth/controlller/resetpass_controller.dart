import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mualij/features/auth/repository/auth_repository.dart';
import 'package:mualij/core/utils.dart';

final resetPasswordControllerProvider =
    StateNotifierProvider<ResetPasswordController, bool>((ref) {
  final authRepository = ref.read(authRepositoryProvider);
  return ResetPasswordController(authRepository);
});

class ResetPasswordController extends StateNotifier<bool> {
  final AuthRepository _authRepository;

  ResetPasswordController(this._authRepository) : super(false);

  Future<void> sendResetPasswordEmail(String email, BuildContext context) async {
    state = true; // Start loading
    final result = await _authRepository.resetPassword(email);

    result.fold(
      // Handle failure
      (failure) {
        state = false; // Stop loading
        showSnackBar(context, failure.message);
      },
      // Handle success
      (_) {
        state = false; // Stop loading
        showSnackBar(context, 'Password reset email sent. Check your inbox!');
        Navigator.pop(context); // Go back to the login screen
      },
    );
  }
}

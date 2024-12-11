import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mualij/features/auth/repository/auth_repository.dart';
import 'package:mualij/core/utils.dart';
import 'package:routemaster/routemaster.dart';

final SigninControllerProvider =
    StateNotifierProvider<SigninController, bool>((ref) {
  final authRepository = ref.read(authRepositoryProvider);
  return SigninController(authRepository);
});

class SigninController extends StateNotifier<bool> {
  final AuthRepository _authRepository;

  SigninController(this._authRepository) : super(false); // Initial state

  Future<void> signInWithEmailAndPassword(
      String email, String password, BuildContext context) async {
    state = true; // Set loading to true
    final result =
        await _authRepository.signInWithEmailAndPassword(email, password);

    result.fold(
      // Handle failure
      (failure) {
        state = false; // Stop loading
        showSnackBar(context, failure.message);
      },
      // Handle success
      (userModel) {
        state = false; // Stop loading
        // Routemaster.of(context).push('/');
      },
    );
  }
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mualij/core/constants/constants.dart';
import 'package:mualij/core/utils.dart';
import 'package:mualij/features/auth/common/temporary_user_provider.dart';
import 'package:mualij/features/auth/repository/auth_repository.dart';
import 'package:mualij/features/auth/screens/setpassowrd_screen.dart';
import 'package:mualij/models/user_model.dart';
import 'package:routemaster/routemaster.dart';

final userProvider = StateProvider<UserModel?>((ref) => null);
final verifiedEmailProvider = StateProvider<String?>((ref) => null);

final authControllerProvider = StateNotifierProvider<AuthController, bool>(
  (ref) => AuthController(
    authRepository: ref.watch(authRepositoryProvider),
    ref: ref,
  ),
);

// final authStateChangeProvider = StreamProvider<User?>((ref) {
//   final authController = ref.watch(authControllerProvider.notifier);
//   final isTemporaryUser = ref.watch(isTemporaryUserProvider);

//   return authController.authStateChange.map((user) {
//     if (isTemporaryUser || user == null) {
//       //return nothing
//       print("lol");
//       return null;
//     }
//     print("bond");
//     return user;
//   });
// });

final authStateChangeProvider = StreamProvider((ref) {
  final authController = ref.watch(authControllerProvider.notifier);
  return authController.authStateChange;
});

final getUserDataProvider = StreamProvider.family((ref, String uid) {
  final authController = ref.watch(authControllerProvider.notifier);
  return authController.getUserData(uid);
});

class AuthController extends StateNotifier<bool> {
  final AuthRepository _authRepository;
  final Ref _ref;
  AuthController({required AuthRepository authRepository, required Ref ref})
      : _authRepository = authRepository,
        _ref = ref,
        super(false); // loading

  Stream<User?> get authStateChange => _authRepository.authStateChange;

  void signInWithGoogle(BuildContext context, bool isFromLogin) async {
    state = true;
    final user = await _authRepository.signInWithGoogle(isFromLogin);
    state = false;
    user.fold(
      (l) => showSnackBar(context, l.message),
      (userModel) =>
          _ref.read(userProvider.notifier).update((state) => userModel),
    );
  }

  void signInAsGuest(BuildContext context) async {
    state = true;
    final user = await _authRepository.signInAsGuest();
    state = false;
    user.fold(
      (l) => showSnackBar(context, l.message),
      (userModel) =>
          _ref.read(userProvider.notifier).update((state) => userModel),
    );
  }

  Stream<UserModel> getUserData(String uid) {
    return _authRepository.getUserData(uid);
  }

  void logout(BuildContext context) async {
    _authRepository.logOut();

    Phoenix.rebirth(context);
    print("rebirth called");
  }
}

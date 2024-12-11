import 'package:flutter_riverpod/flutter_riverpod.dart';

class SignupState {
  final String fullName;
  final String email;
  final String username;

  SignupState({
    this.fullName = '',
    this.email = '',
    this.username = '',
  });

  SignupState copyWith({
    String? fullName,
    String? email,
    String? username,
  }) {
    return SignupState(
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      username: username ?? this.username,
    );
  }
}

class SignupStateNotifier extends StateNotifier<SignupState> {
  SignupStateNotifier() : super(SignupState());

  void setFullName(String fullName) {
    state = state.copyWith(fullName: fullName);
  }

  void setEmail(String email) {
    state = state.copyWith(email: email);
  }

  void setUsername(String username) {
    state = state.copyWith(username: username);
  }
}

final signupStateProvider =
    StateNotifierProvider<SignupStateNotifier, SignupState>(
        (ref) => SignupStateNotifier());

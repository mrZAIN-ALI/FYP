import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final isTemporaryUserProvider = StateNotifierProvider<TemporaryUserNotifier, bool>(
  (ref) => TemporaryUserNotifier(),
);

class TemporaryUserNotifier extends StateNotifier<bool> {
  TemporaryUserNotifier() : super(false) {
    _loadTemporaryUserFlag(); // Load flag on initialization
  }

  // Save the flag to SharedPreferences
  Future<void> setTemporaryUser(bool isTemporary) async {
    state = isTemporary;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isTemporaryUser', isTemporary);
  }

  // Load the flag from SharedPreferences
  Future<void> _loadTemporaryUserFlag() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool('isTemporaryUser') ?? false;
  }

  // Clear the flag from SharedPreferences
  Future<void> clearTemporaryUserFlag() async {
    state = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('isTemporaryUser');
  }
}

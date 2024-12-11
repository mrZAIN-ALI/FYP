import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final themeNotifierProvider =
    StateNotifierProvider<ThemeNotifier, ThemeData>((ref) {
  return ThemeNotifier();
});

class Pallete {
  // Primary Colors
  static const Color blackColor = Color(0xFF000000); // Dark mode background
  static const Color whiteColor = Color(0xFFFFFFFF); // Light mode background
  static const Color greyColor = Color(0xFF1A272D); // Card or secondary dark mode
  static const Color lightGreyColor = Color(0xFFF5F5F5); // Card light mode
  static const Color drawerColor = Color(0xFF121212); // Drawer background (dark mode)

  // Button Colors
  static const Color blueButtonColor = Color(0xFF1E88E5); // Primary action button
  static const Color greyButtonColor = Color(0xFFBDBDBD); // Secondary buttons

  // Text Colors
  static const Color darkTextColor = Color(0xFFFFFFFF); // Dark mode text
  static const Color lightTextColor = Color(0xFF000000); // Light mode text
  static const Color hintTextColor = Color(0xFF9E9E9E); // Placeholder/hint text

  // Divider Colors
  static const Color dividerColor = Color(0xFFE0E0E0); // Light mode divider
  static const Color darkDividerColor = Color(0xFF424242); // Dark mode divider

  // Icon Colors
  static const Color lightIconColor = Color(0xFF000000); // Light mode icons
  static const Color darkIconColor = Color(0xFFFFFFFF); // Dark mode icons

  // Error Colors
  static const Color errorColor = Colors.red;

  // Light Theme
  static final ThemeData lightModeAppTheme = ThemeData.light().copyWith(
    scaffoldBackgroundColor: whiteColor,
    cardColor: lightGreyColor,
    appBarTheme: const AppBarTheme(
      backgroundColor: whiteColor,
      elevation: 0,
      iconTheme: IconThemeData(color: lightIconColor),
    ),
    drawerTheme: const DrawerThemeData(
      backgroundColor: whiteColor,
    ),
    buttonTheme: const ButtonThemeData(buttonColor: blueButtonColor),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: lightTextColor),
      bodyMedium: TextStyle(color: hintTextColor),
    ),
    dividerColor: dividerColor,
    primaryColor: blueButtonColor,
    colorScheme: const ColorScheme.light(
      primary: blueButtonColor,
      onPrimary: whiteColor,
      secondary: greyButtonColor,
      onSecondary: lightTextColor,
      surface: lightGreyColor,
      onSurface: lightTextColor,
      error: errorColor,
      onError: lightTextColor,
      brightness: Brightness.light,
    ),
  );

  // Dark Theme
  static final ThemeData darkModeAppTheme = ThemeData.dark().copyWith(
    scaffoldBackgroundColor: blackColor,
    cardColor: greyColor,
    appBarTheme: const AppBarTheme(
      backgroundColor: drawerColor,
      iconTheme: IconThemeData(color: darkIconColor),
    ),
    drawerTheme: const DrawerThemeData(
      backgroundColor: drawerColor,
    ),
    buttonTheme: const ButtonThemeData(buttonColor: blueButtonColor),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: darkTextColor),
      bodyMedium: TextStyle(color: hintTextColor),
    ),
    dividerColor: darkDividerColor,
    primaryColor: blueButtonColor,
    colorScheme: const ColorScheme.dark(
      primary: blueButtonColor,
      onPrimary: whiteColor,
      secondary: greyButtonColor,
      onSecondary: darkTextColor,
      surface: greyColor,
      onSurface: darkTextColor,
      error: errorColor,
      onError: darkTextColor,
      brightness: Brightness.dark,
    ),
  );
}

class ThemeNotifier extends StateNotifier<ThemeData> {
  ThemeMode _mode;

  ThemeNotifier()
      : _mode = ThemeMode.system,
        super(Pallete.lightModeAppTheme) {
    _loadTheme();
  }

  ThemeMode get mode => _mode;

  void _loadTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final theme = prefs.getString('theme');

    if (theme == 'light') {
      _mode = ThemeMode.light;
      state = Pallete.lightModeAppTheme;
    } else if (theme == 'dark') {
      _mode = ThemeMode.dark;
      state = Pallete.darkModeAppTheme;
    } else if (theme == null) {
      _mode = ThemeMode.system; // Fallback to system default
      state =
          WidgetsBinding.instance.window.platformBrightness == Brightness.dark
              ? Pallete.darkModeAppTheme
              : Pallete.lightModeAppTheme;
    }
  }

  void setTheme(ThemeMode mode) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    _mode = mode;

    if (mode == ThemeMode.light) {
      state = Pallete.lightModeAppTheme;
      prefs.setString('theme', 'light');
    } else if (mode == ThemeMode.dark) {
      state = Pallete.darkModeAppTheme;
      prefs.setString('theme', 'dark');
    } else {
      state =
          WidgetsBinding.instance.window.platformBrightness == Brightness.dark
              ? Pallete.darkModeAppTheme
              : Pallete.lightModeAppTheme;
      prefs.setString('theme', 'system');
    }
  }

  /// Toggle theme between light and dark mode.
  void toggleTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (_mode == ThemeMode.dark ||
        (_mode == ThemeMode.system &&
            WidgetsBinding.instance.window.platformBrightness ==
                Brightness.dark)) {
      // Switch to light mode
      _mode = ThemeMode.light;
      state = Pallete.lightModeAppTheme;
      prefs.setString('theme', 'light');
    } else {
      // Switch to dark mode
      _mode = ThemeMode.dark;
      state = Pallete.darkModeAppTheme;
      prefs.setString('theme', 'dark');
    }
  }
}

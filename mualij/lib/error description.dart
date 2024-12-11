
// // login_screen.dart
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:mualij/core/common/loader.dart';
// import 'package:mualij/core/common/sign_in_button.dart';
// import 'package:mualij/core/constants/constants.dart';
// import 'package:mualij/features/auth/controlller/auth_controller.dart';
// import 'package:mualij/responsive/responsive.dart';

// class LoginScreen extends ConsumerWidget {
//   const LoginScreen({super.key});

//   void signInAsGuest(WidgetRef ref, BuildContext context) {
//     ref.read(authControllerProvider.notifier).signInAsGuest(context);
//   }

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final isLoading = ref.watch(authControllerProvider);

//     return Scaffold(
//       appBar: AppBar(
//         title: Image.asset(
//           Constants.logoPath,
//           height: 40,
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => signInAsGuest(ref, context),
//             child: const Text(
//               'Skip',
//               style: TextStyle(
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),
//         ],
//       ),
//       body: isLoading
//           ? const Loader()
//           : Column(
//               children: [
//                 const SizedBox(height: 30),
//                 const Text(
//                   'Dive into anything',
//                   style: TextStyle(
//                     fontSize: 24,
//                     fontWeight: FontWeight.bold,
//                     letterSpacing: 0.5,
//                   ),
//                 ),
//                 const SizedBox(height: 30),
//                 Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: Image.asset(
//                     Constants.loginEmotePath,
//                     height: 400,
//                   ),
//                 ),
//                 const SizedBox(height: 20),
//                 const Responsive(child: SignInButton()),
//               ],
//             ),
//     );
//   }
// }

// // Above is login screen widget whcih calls signinbutton() wdiget 

// // signinbutton.dart

// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:mualij/core/constants/constants.dart';
// import 'package:mualij/features/auth/controlller/auth_controller.dart';
// import 'package:mualij/theme/pallete.dart';

// class SignInButton extends ConsumerWidget {
//   final bool isFromLogin;
//   const SignInButton({super.key, this.isFromLogin = true});

//   void signInWithGoogle(BuildContext context, WidgetRef ref) {
//     ref
//         .read(authControllerProvider.notifier)
//         .signInWithGoogle(context, isFromLogin);
//   }

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     return Padding(
//       padding: const EdgeInsets.all(18.0),
//       child: ElevatedButton.icon(
//         onPressed: () => signInWithGoogle(context, ref),
//         icon: Image.asset(
//           Constants.googlePath,
//           width: 35,
//         ),
//         label: const Text(
//           'Continue with Google',
//           style: TextStyle(fontSize: 18),
//         ),
//         style: ElevatedButton.styleFrom(
//           backgroundColor: Pallete.greyColor,
//           minimumSize: const Size(double.infinity, 50),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(20),
//           ),
//         ),
//       ),
//     );
//   }
// }
// // above is signinbutton widget which calls SignInWithGoogle() function
// //  signInWithGoogle(BuildContext context, WidgetRef ref) {
// //     ref
// //         .read(authControllerProvider.notifier)
// //         .signInWithGoogle(context, isFromLogin);
// //   }

// // signinWithGoogle function from Sign_in_button.dart  calls
// //  void signInWithGoogle(BuildContext context, bool isFromLogin) async function from auth_controller 

// // auth_controller.dart
//   import 'package:firebase_auth/firebase_auth.dart';
//   import 'package:flutter/material.dart';
//   import 'package:flutter_riverpod/flutter_riverpod.dart';
//   import 'package:mualij/core/utils.dart';
//   import 'package:mualij/features/auth/repository/auth_repository.dart';
//   import 'package:mualij/models/user_model.dart';

//   final userProvider = StateProvider<UserModel?>((ref) => null);

//   final authControllerProvider = StateNotifierProvider<AuthController, bool>(
//     (ref) => AuthController(
//       authRepository: ref.watch(authRepositoryProvider),
//       ref: ref,
//     ),
//   );

//   final authStateChangeProvider = StreamProvider((ref) {
//     final authController = ref.watch(authControllerProvider.notifier);
//     return authController.authStateChange;
//   });

//   final getUserDataProvider = StreamProvider.family((ref, String uid) {
//     final authController = ref.watch(authControllerProvider.notifier);
//     return authController.getUserData(uid);
//   });

//   class AuthController extends StateNotifier<bool> {
//     final AuthRepository _authRepository;
//     final Ref _ref;
//     AuthController({required AuthRepository authRepository, required Ref ref})
//         : _authRepository = authRepository,
//           _ref = ref,
//           super(false); // loading

//     Stream<User?> get authStateChange => _authRepository.authStateChange;

//     void signInWithGoogle(BuildContext context, bool isFromLogin) async {
//       state = true;
//       final user = await _authRepository.signInWithGoogle(isFromLogin);
//       state = false;
//       user.fold(
//         (l) => showSnackBar(context, l.message),
//         (userModel) =>
//             _ref.read(userProvider.notifier).update((state) => userModel),
//       );
//     }

//     void signInAsGuest(BuildContext context) async {
//       state = true;
//       final user = await _authRepository.signInAsGuest();
//       state = false;
//       user.fold(
//         (l) => showSnackBar(context, l.message),
//         (userModel) =>
//             _ref.read(userProvider.notifier).update((state) => userModel),
//       );
//     }

//     Stream<UserModel> getUserData(String uid) {
//       return _authRepository.getUserData(uid);
//     }

//     void logout() async {
//       _authRepository.logOut();
//     }
//   }

// // signInWithGoogle() function calls showsncakbar from utils

//     void signInWithGoogle(BuildContext context, bool isFromLogin) async {
//       state = true;
//       final user = await _authRepository.signInWithGoogle(isFromLogin);
//       state = false;
//       user.fold(
//         (l) => showSnackBar(context, l.message),
//         (userModel) =>
//             _ref.read(userProvider.notifier).update((state) => userModel),
//       );
//     }

// // utils.dart
// import 'package:file_picker/file_picker.dart';
// import 'package:flutter/material.dart';

// void showSnackBar(BuildContext context, String text) {
//   ScaffoldMessenger.of(context)
//     ..hideCurrentSnackBar()
//     ..showSnackBar(
//       SnackBar(
//         content: Text(text),
//       ),
//     );
// }

// Future<FilePickerResult?> pickImage() async {
//   final image = await FilePicker.platform.pickFiles(type: FileType.image);

//   return image;
// }

// // above is ,utils.dart widget in this i got error at line 5 error is explained below

// Exception has occurred.
// FlutterError (Looking up a deactivated widget's ancestor is unsafe.
// At this point the state of the widget's element tree is no longer stable.
// To safely refer to a widget's ancestor in its dispose() method, save a reference to the ancestor by calling dependOnInheritedWidgetOfExactType() in the widget's didChangeDependencies() method.)

// // Give me solution to remove this error 
// the probnlime is that context is not mounted i used if statemetn as below
//   if (context.mounted) {
//     user.fold(
//       (l) => showSnackBar(context, l.message),
//       (userModel) => _ref.read(userProvider.notifier).update((state) => userModel),
//     );
//   }
//   else{
 
//     print('\x1B[31m********** Lol bond  Context is not mounted **********\x1B[0m');
//   }
// i dont waht to avoid erroor give me soultion
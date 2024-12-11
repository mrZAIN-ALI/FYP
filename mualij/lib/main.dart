import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart'; // Import Phoenix
import 'package:mualij/core/common/error_text.dart';
import 'package:mualij/core/common/loader.dart';
import 'package:mualij/features/auth/common/temporary_user_provider.dart';
import 'package:mualij/features/auth/controlller/auth_controller.dart';
import 'package:mualij/firebase_options.dart';
import 'package:mualij/models/user_model.dart';
import 'package:mualij/router.dart';
import 'package:mualij/theme/pallete.dart';
import 'package:routemaster/routemaster.dart';
//testing git
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    Phoenix(
      // Wrap your app with Phoenix
      child: const ProviderScope(
        child: MyApp(),
      ),
    ),
  );
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  UserModel? userModel;
  bool isLoadingUser = false;

  // Future<void> getData(WidgetRef ref, User data) async {
  //   setState(() => isLoadingUser = true);
  //   userModel = await ref
  //       .watch(authControllerProvider.notifier)
  //       .getUserData(data.uid)
  //       .first;
  //   ref.read(userProvider.notifier).update((state) => userModel);
  //   setState(() => isLoadingUser = false);
  // }
  Future<void> getData(WidgetRef ref, User data) async {
    try {
      setState(() => isLoadingUser = true);
      userModel = await ref
          .watch(authControllerProvider.notifier)
          .getUserData(data.uid)
          .first;
      ref.read(userProvider.notifier).update((state) => userModel);
    } catch (e) {
      // Log the error or show an appropriate message
      print('Error fetching user data: $e');
    } finally {
      setState(() => isLoadingUser = false);
    }
  }

  @override
  Widget build(BuildContext context) {

  final isTemporaryUser = ref.watch(isTemporaryUserProvider);
    if (isTemporaryUser) {
      // Handle the case when isTemporaryUser is active
      return MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'Mualij',
        theme: ref.watch(themeNotifierProvider),
        routerDelegate: RoutemasterDelegate(
          routesBuilder: (_) => loggedOutRoute,
        ),
        routeInformationParser: const RoutemasterParser(),
      );
    }
    return ref.watch(authStateChangeProvider).when(
          data: (data) {
            if (data != null) {
              if (userModel == null && !isLoadingUser) {
                getData(ref, data);
                return const Loader();
              }
              if (userModel != null) {
                return MaterialApp.router(
                  debugShowCheckedModeBanner: false,
                  title: 'Mualij',
                  theme: ref.watch(themeNotifierProvider),
                  routerDelegate: RoutemasterDelegate(
                    routesBuilder: (_) => loggedInRoute,
                  ),
                  routeInformationParser: const RoutemasterParser(),
                );
              }
            }

            return MaterialApp.router(
              debugShowCheckedModeBanner: false,
              title: 'Mualij',
              theme: ref.watch(themeNotifierProvider),
              routerDelegate: RoutemasterDelegate(
                routesBuilder: (_) => loggedOutRoute,
              ),
              routeInformationParser: const RoutemasterParser(),
            );
          },
          error: (error, stackTrace) => ErrorText(error: error.toString()),
          loading: () => const Loader(),
        );
  }
}

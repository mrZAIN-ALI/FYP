// loggedOut
// loggedIn

import 'package:flutter/material.dart';
import 'package:mualij/features/ai/ai_options_screen.dart';
import 'package:mualij/features/ai/hear_dis_screen.dart';
import 'package:mualij/features/auth/screens/login_screen.dart';
import 'package:mualij/features/auth/screens/resetpassword_screen.dart';
import 'package:mualij/features/auth/screens/setpassowrd_screen.dart';
import 'package:mualij/features/auth/screens/signup_screen.dart';
import 'package:mualij/features/community/screens/add_mods_screen.dart';
import 'package:mualij/features/community/screens/community_screen.dart';
import 'package:mualij/features/community/screens/create_community_screen.dart';
import 'package:mualij/features/community/screens/edit_community_screen.dart';
import 'package:mualij/features/community/screens/mod_tools_screen.dart';
import 'package:mualij/features/home/screens/home_screen.dart';
import 'package:mualij/features/home/screens/searched_post_scren.dart';
import 'package:mualij/features/post/screens/add_post_screen.dart';
import 'package:mualij/features/post/screens/add_post_type_screen.dart';
import 'package:mualij/features/post/screens/comments_screen.dart';
import 'package:mualij/features/user_profile/screens/edit_profile_screen.dart';
import 'package:mualij/features/user_profile/screens/user_profile_screen.dart';
import 'package:routemaster/routemaster.dart';

final loggedOutRoute = RouteMap(routes: {
  '/': (_) => const MaterialPage(child: LoginScreen()),
  '/signup-screen': (_) => MaterialPage(child: SignupScreen()),
  '/setpassword-screen': (_) => MaterialPage(child: SetPasswordScreen()),
  '/resetpassword-screen': (_) => MaterialPage(child: ResetPasswordScreen()),
});

final loggedInRoute = RouteMap(
  routes: {
    '/signup-screen': (_) => MaterialPage(child: SignupScreen()),
    '/login': (_) => const MaterialPage(child: LoginScreen()),
    '/': (_) => const MaterialPage(child: HomeScreen()),
    '/create-community': (_) =>
        const MaterialPage(child: CreateCommunityScreen()),
    '/r/:name': (route) => MaterialPage(
          child: CommunityScreen(
            name: route.pathParameters['name']!,
          ),
        ),
    '/mod-tools/:name': (routeData) => MaterialPage(
          child: ModToolsScreen(
            name: routeData.pathParameters['name']!,
          ),
        ),
    '/edit-community/:name': (routeData) => MaterialPage(
          child: EditCommunityScreen(
            name: routeData.pathParameters['name']!,
          ),
        ),
    '/add-mods/:name': (routeData) => MaterialPage(
          child: AddModsScreen(
            name: routeData.pathParameters['name']!,
          ),
        ),
    '/u/:uid': (routeData) => MaterialPage(
          child: UserProfileScreen(
            uid: routeData.pathParameters['uid']!,
          ),
        ),
    '/edit-profile/:uid': (routeData) => MaterialPage(
          child: EditProfileScreen(
            uid: routeData.pathParameters['uid']!,
          ),
        ),
    '/add-post/:type': (routeData) => MaterialPage(
          child: AddPostTypeScreen(
            type: routeData.pathParameters['type']!,
          ),
        ),
    '/post/:postId/comments': (route) => MaterialPage(
          child: CommentsScreen(
            postId: route.pathParameters['postId']!,
          ),
        ),
    '/add-post': (routeData) => const MaterialPage(
          child: AddPostScreen(),
        ),
    '/p/:id': (routeData) => MaterialPage(
          child: PostScreen(
            postId: routeData.pathParameters['id']!,
          ),
        ),

    '/ai-options': (_) => const MaterialPage(child: AIOptionsScreen()),
    // '/heart-disease': (_) => const MaterialPage(child: HeartDiseaseScreen()),
  },
);

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mualij/core/constants/constants.dart';
import 'package:mualij/features/auth/controlller/auth_controller.dart';
import 'package:mualij/theme/pallete.dart';
import 'package:routemaster/routemaster.dart';

class ProfileDrawer extends ConsumerWidget {
  const ProfileDrawer({super.key});

  void logOut(WidgetRef ref, BuildContext context) {
    ref.read(authControllerProvider.notifier).logout(context);
  }

  void navigateToUserProfile(BuildContext context, String uid) {
    Routemaster.of(context).push('/u/$uid');
  }

  void toggleTheme(WidgetRef ref) {
    ref.read(themeNotifierProvider.notifier).toggleTheme();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider)!;
    final isGuest = !user.isAuthenticated; // Determine if the user is a guest
    final isDarkMode =
        ref.watch(themeNotifierProvider.notifier).mode == ThemeMode.dark;

    return Drawer(
      child: SafeArea(
        
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // Header: User Info
            UserAccountsDrawerHeader(
              accountName: Text(
                isGuest ? 'Guest' : 'u/${user.name}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              accountEmail: user.username.isEmpty ? Text("username") : Text("@"+(user.username)),
              currentAccountPicture: CircleAvatar(
                backgroundImage: user.profilePic.isEmpty
                    ? AssetImage(Constants.avatarDefault)
                    : NetworkImage(user.profilePic) as ImageProvider,
              ),
              decoration: BoxDecoration(
                color: user.banner.isEmpty
                    ? const Color.fromARGB(255, 75, 90, 101)
                    : null, // Default blue banner
                image: user.banner.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(user.banner),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
            ),
            // Drawer Items
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profile'),
              onTap: isGuest ? null : () => navigateToUserProfile(context, user.uid),
              enabled: !isGuest, // Disable for guest users
            ),
            ListTile(
              leading: const Icon(Icons.group),
              title: const Text('Create Community'),
              onTap: isGuest
                  ? null
                  : () => Routemaster.of(context).push('/create-community'),
              enabled: !isGuest,
            ),
            ListTile(
              leading: const Icon(Icons.verified_user),
              title: const Text('Get Verified as Doctor'),

            ),
            ListTile(
              leading: const Icon(Icons.post_add),
              title: const Text('Add Post'),
              onTap: isGuest
                  ? null
                  : () => Routemaster.of(context).push('/add-post'),
              enabled: !isGuest,
            ),
            const Divider(),
            // Theme Toggle
            SwitchListTile(
              secondary: const Icon(Icons.brightness_6),
              title: const Text('Dark Mode'),
              value: isDarkMode,
              onChanged: (val) => toggleTheme(ref),
            ),
            const Divider(),
            // Logout
            ListTile(
              leading: Icon(Icons.logout, color: Pallete.errorColor),
              title: const Text('Logout'),
              onTap: () {
                logOut(ref, context);
              },
            ),
          ],
        ),
      ),
    );
  }
}

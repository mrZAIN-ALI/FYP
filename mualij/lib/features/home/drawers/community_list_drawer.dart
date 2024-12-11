import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mualij/core/common/error_text.dart';
import 'package:mualij/core/common/loader.dart';
import 'package:mualij/core/constants/constants.dart';
import 'package:mualij/features/auth/controlller/auth_controller.dart';
import 'package:mualij/features/community/controller/community_controller.dart';
import 'package:mualij/models/community_model.dart';
import 'package:routemaster/routemaster.dart';

class CommunityListDrawer extends ConsumerWidget {
  const CommunityListDrawer({super.key});

  void navigateToCreateCommunity(BuildContext context) {
    Routemaster.of(context).push('/create-community');
  }

  void navigateToCommunity(BuildContext context, Community community) {
    Routemaster.of(context).push('/r/${community.name}');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider)!;
    final isGuest = !user.isAuthenticated;

    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drawer Header
            Container(
              color: Theme.of(context).primaryColor,
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: isGuest
                        ? const AssetImage(Constants.avatarDefault)
                        : NetworkImage(user.profilePic) as ImageProvider<Object>,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isGuest ? 'Guest User' : user.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (!isGuest)
                    Text(
                      user.username,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                ],
              ),
            ),
            const Divider(),
            // Guest Login Button or Create Community
            isGuest
                ? Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ElevatedButton.icon(
                      onPressed: () {
                        ref
                            .read(authControllerProvider.notifier)
                            .logout(context);
                      },
                      icon: const Icon(Icons.login),
                      label: const Text(
                        'Sign In to Explore',
                        style: TextStyle(fontSize: 16),
                      ),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  )
                : ListTile(
                    leading: const Icon(Icons.add),
                    title: const Text('Create a Community'),
                    onTap: () => navigateToCreateCommunity(context),
                  ),
            const Divider(),
            // Community List
            if (!isGuest)
              Expanded(
                child: ref.watch(userCommunitiesProvider).when(
                      data: (communities) {
                        if (communities.isEmpty) {
                          return const Center(
                            child: Text(
                              'No communities joined yet!',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        }
                        return ListView.builder(
                          itemCount: communities.length,
                          itemBuilder: (context, index) {
                            final community = communities[index];
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundImage: NetworkImage(community.avatar),
                              ),
                              title: Text('r/${community.name}'),
                              onTap: () {
                                navigateToCommunity(context, community);
                              },
                            );
                          },
                        );
                      },
                      error: (error, stackTrace) => Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: ErrorText(error: error.toString()),
                      ),
                      loading: () => const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Loader(),
                      ),
                    ),
              ),
          ],
        ),
      ),
    );
  }
}

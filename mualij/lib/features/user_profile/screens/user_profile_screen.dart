import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mualij/core/common/error_text.dart';
import 'package:mualij/core/common/loader.dart';
import 'package:mualij/core/common/post_card.dart';
import 'package:mualij/features/auth/controlller/auth_controller.dart';
import 'package:mualij/features/community/controller/community_controller.dart';
import 'package:mualij/features/user_profile/controller/user_profile_controller.dart';
import 'package:routemaster/routemaster.dart';
import 'package:mualij/features/user_profile/controller/user_profile_controller.dart';

class UserProfileScreen extends ConsumerStatefulWidget {
  final String uid;
  const UserProfileScreen({
    super.key,
    required this.uid,
  });

  @override
  ConsumerState<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends ConsumerState<UserProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this); // Posts & Communities tabs
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void navigateToEditUser(BuildContext context) {
    Routemaster.of(context).push('/edit-profile/${widget.uid}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ref.watch(getUserDataProvider(widget.uid)).when(
        data: (user) => NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverAppBar(
                expandedHeight: 250,
                floating: true,
                snap: true,
                flexibleSpace: Stack(
                  children: [
                    Positioned.fill(
                      child: Image.network(
                        user.banner,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Container(
                      alignment: Alignment.bottomLeft,
                      padding: const EdgeInsets.all(20).copyWith(bottom: 70),
                      child: CircleAvatar(
                        backgroundImage: NetworkImage(user.profilePic),
                        radius: 45,
                      ),
                    ),
                    
                    Container(
                      alignment: Alignment.bottomLeft,
                      padding: const EdgeInsets.all(20),
                      child: user.uid == ref.watch(userProvider)!.uid
                          ? OutlinedButton(
                              onPressed: () => navigateToEditUser(context),
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 25),
                              ),
                              child: const Text('Edit Profile'),
                            )
                          : const SizedBox(height: 2),
                    ),
                  ],
                ),
                
              ),
              SliverToBoxAdapter(
  child: Padding(
    padding: const EdgeInsets.only(left: 20, top: 8, bottom: 4),
    child: Row(
      children: [
        Text(
          'u/${user.username}',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 6),
        if (user.isVerifiedDoctor)
          const Icon(
            Icons.verified,
            color: Colors.blue,
            size: 18,
          ),
      ],
    ),
  ),
),

              // Display Professional Background and Expertise using Cards:
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Professional Background Card
                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.work_outline, color: Colors.blue),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Professional Background",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      user.professionalBackground.isNotEmpty
                                          ? user.professionalBackground
                                          : "Not added yet",
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: user.professionalBackground.isNotEmpty
                                            ? Colors.black
                                            : Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Areas of Expertise Card
                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.star_border, color: Colors.blue),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Areas of Expertise",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      user.expertiseAreas.isNotEmpty
                                          ? user.expertiseAreas.join(", ")
                                          : "Not added yet",
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: user.expertiseAreas.isNotEmpty
                                            ? Colors.black
                                            : Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TabBar(
                        controller: _tabController,
                        indicatorColor: Colors.blue,
                        labelColor: Colors.blue,
                        unselectedLabelColor: Colors.grey,
                        tabs: const [
                          Tab(text: 'Posts'),
                          Tab(text: 'Communities'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ];
          },
          body: TabBarView(
            controller: _tabController,
            children: [
              // Posts Tab
              ref.watch(getUserPostsProvider(widget.uid)).when(
                data: (data) {
                  return ListView.builder(
                    itemCount: data.length,
                    itemBuilder: (BuildContext context, int index) {
                      final post = data[index];
                      return PostCard(post: post);
                    },
                  );
                },
                error: (error, stackTrace) {
                  return ErrorText(error: error.toString());
                },
                loading: () => const Loader(),
              ),
              // Communities Tab
              ref.watch(userCommunitiesProvider).when(
                data: (communities) {
                  if (communities.isEmpty) {
                    return const Center(
                      child: Text('No communities joined yet.'),
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
                        title: Text("c/" + community.name),
                        onTap: () {
                          Routemaster.of(context).push('/r/${community.name}');
                        },
                      );
                    },
                  );
                },
                error: (error, stackTrace) {
                  return ErrorText(error: error.toString());
                },
                loading: () => const Loader(),
              ),
            ],
          ),
        ),
        error: (error, stackTrace) => ErrorText(error: error.toString()),
        loading: () => const Loader(),
      ),
    );
  }
}

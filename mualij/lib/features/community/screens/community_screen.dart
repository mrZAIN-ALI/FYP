import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mualij/core/common/error_text.dart';
import 'package:mualij/core/common/loader.dart';
import 'package:mualij/core/common/post_card.dart';
import 'package:mualij/features/auth/controlller/auth_controller.dart';
import 'package:mualij/features/community/controller/community_controller.dart';
import 'package:mualij/features/community/screens/tag_filter_bottom_sheet.dart';
import 'package:mualij/models/community_model.dart';
import 'package:routemaster/routemaster.dart';

class CommunityScreen extends ConsumerStatefulWidget {
  final String name;
  const CommunityScreen({Key? key, required this.name}) : super(key: key);

  @override
  ConsumerState<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends ConsumerState<CommunityScreen> {
  @override
  void initState() {
    super.initState();
    // Ensure filters are cleared every time this screen is loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(selectedFilterTagsProvider.notifier).state = [];
    });
  }

  void navigateToModTools(BuildContext context) {
    Routemaster.of(context).push('/mod-tools/${widget.name}');
  }

  void joinCommunity(Community community, BuildContext context) {
    ref.read(communityControllerProvider.notifier).joinCommunity(community, context);
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider)!;
    final isGuest = !user.isAuthenticated;

    return Scaffold(
      body: ref.watch(getCommunityByNameProvider(widget.name)).when(
        data: (community) => NestedScrollView(
          headerSliverBuilder: (_, __) => [
            SliverAppBar(
              expandedHeight: 150,
              floating: true,
              snap: true,
              flexibleSpace: Image.network(community.banner, fit: BoxFit.cover),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  Align(
                    alignment: Alignment.topLeft,
                    child: CircleAvatar(
                      backgroundImage: NetworkImage(community.avatar),
                      radius: 35,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'c/${community.name}',
                        style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
                      ),
                      if (!isGuest)
                        community.mods.contains(user.uid)
                            ? OutlinedButton(
                                onPressed: () => navigateToModTools(context),
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                  padding: const EdgeInsets.symmetric(horizontal: 25),
                                ),
                                child: const Text('Mod Tools'),
                              )
                            : OutlinedButton(
                                onPressed: () => joinCommunity(community, context),
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                  padding: const EdgeInsets.symmetric(horizontal: 25),
                                ),
                                child: Text(
                                  community.members.contains(user.uid) ? 'Joined' : 'Join',
                                ),
                              ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      OutlinedButton(
                        onPressed: () async {
                          final selectedTags = await showModalBottomSheet<List<String>>(
                            context: context,
                            isScrollControlled: true,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                            ),
                            builder: (_) => TagFilterBottomSheet(communityName: widget.name),
                          );
                          if (selectedTags != null) {
                            ref.read(selectedFilterTagsProvider.notifier).state = selectedTags;
                            ref.refresh(filteredCommunityPostsProvider(widget.name));
                          }
                        },
                        child: const Text('Filter Tags/Flair'),
                      ),
                      OutlinedButton(
                        onPressed: () {
                          ref.read(selectedFilterTagsProvider.notifier).state = [];
                          ref.refresh(filteredCommunityPostsProvider(widget.name));
                        },
                        child: const Text('Clear Filter'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text('${community.members.length} members'),
                ]),
              ),
            ),
          ],
          body: ref.watch(filteredCommunityPostsProvider(widget.name)).when(
            data: (posts) {
              if (posts.isEmpty) {
                return const Center(child: Text('No posts found.'));
              }
              return ListView.builder(
                itemCount: posts.length,
                itemBuilder: (_, index) => PostCard(post: posts[index]),
              );
            },
            error: (error, _) => ErrorText(error: error.toString()),
            loading: () => const Loader(),
          ),
        ),
        error: (error, _) => ErrorText(error: error.toString()),
        loading: () => const Loader(),
      ),
    );
  }
}

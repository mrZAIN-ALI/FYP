import 'package:any_link_preview/any_link_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mualij/core/common/tags_or_flair_chips.dart';
import 'package:mualij/core/constants/constants.dart';
import 'package:mualij/features/auth/controlller/auth_controller.dart';
import 'package:mualij/features/post/controller/post_controller.dart';
import 'package:mualij/models/post_model.dart';
import 'package:routemaster/routemaster.dart';

class PostCard extends ConsumerWidget {
  final Post post;

  const PostCard({
    super.key,
    required this.post,
  });

  void deletePost(WidgetRef ref, BuildContext context) async {
    ref.read(postControllerProvider.notifier).deletePost(post, context);
  }

  void upvotePost(WidgetRef ref) async {
    ref.read(postControllerProvider.notifier).upvote(post);
  }

  void downvotePost(WidgetRef ref) async {
    ref.read(postControllerProvider.notifier).downvote(post);
  }

  void awardPost(WidgetRef ref, String award, BuildContext context) async {
    ref
        .read(postControllerProvider.notifier)
        .awardPost(post: post, award: award, context: context);
  }

  void navigateToUser(BuildContext context) {
    Routemaster.of(context).push('/u/${post.uid}');
  }

  void navigateToCommunity(BuildContext context) {
    Routemaster.of(context).push('/r/${post.communityName}');
  }

  void navigateToComments(BuildContext context) {
    Routemaster.of(context).push('/post/${post.id}/comments');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider)!;
    final isGuest = !user.isAuthenticated;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Container(
              padding:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(15)),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => navigateToCommunity(context),
                    child: CircleAvatar(
                      backgroundImage: NetworkImage(Constants.avatarDefault),
                      radius: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () => navigateToCommunity(context),
                          child: Text(
                            'c/${post.communityName}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => navigateToUser(context),
                          child: Text(
                            'u/${post.username}',
                            style: const TextStyle(
                                fontSize: 14, color: Colors.grey),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (post.uid == user.uid)
                    IconButton(
                      onPressed: () => deletePost(ref, context),
                      icon: const Icon(Icons.delete, color: Colors.red),
                    ),
                ],
              ),
            ),

            // Flair Chips Section
            if (post.flairs.isNotEmpty)
              Wrap(
                runSpacing: 2,
                children: post.flairs.map((flair) {
                  return GestureDetector(
                    onTap: () {
                      // Optional tap action.
                    },
                    child: Transform.scale(
                      scale: 0.8, // scale down the size by 80%
                      child: FlairChipWidget(flair: flair),
                    ),
                  );
                }).toList(),
              ),

            // Title Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Text(
                post.title,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 4),

            // Content Section
            if (post.type == 'text')
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Text(
                  post.description ?? '',
                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                ),
              ),
            if (post.type == 'image')
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    post.link!,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: 200,
                  ),
                ),
              ),
            if (post.type == 'link')
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: AnyLinkPreview(
                  link: post.link!,
                  displayDirection: UIDirection.uiDirectionHorizontal,
                  bodyMaxLines: 3,
                  borderRadius: 10,
                  backgroundColor: Colors.grey[100],
                ),
              ),

            // Awards Section
            if (post.awards.isNotEmpty)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                child: SizedBox(
                  height: 25,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: post.awards.length,
                    itemBuilder: (context, index) {
                      final award = post.awards[index];
                      return Padding(
                        padding: const EdgeInsets.only(right: 4.0),
                        child: Image.asset(
                          Constants.awards[award]!,
                          height: 23,
                        ),
                      );
                    },
                  ),
                ),
              ),

            // Action Buttons Section
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.arrow_upward,
                      color: post.upvotes.contains(user.uid)
                          ? Colors.blue
                          : Colors.grey,
                    ),
                    onPressed: isGuest ? null : () => upvotePost(ref),
                  ),
                  Text('${post.upvotes.length - post.downvotes.length}'),
                  IconButton(
                    icon: Icon(
                      Icons.arrow_downward,
                      color: post.downvotes.contains(user.uid)
                          ? Colors.red
                          : Colors.grey,
                    ),
                    onPressed: isGuest ? null : () => downvotePost(ref),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.insert_comment_rounded),
                    onPressed: () => navigateToComments(context),
                  ),
                  Text('${post.commentCount} Comments'),
                  const Spacer(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mualij/core/common/post_card.dart';
import 'package:mualij/features/home/rep_single_searched_post/searched_post_repo.dart';


class PostScreen extends ConsumerWidget {
  final String postId;

  const PostScreen({Key? key, required this.postId}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Fetch post details using the postId
    final postAsyncValue = ref.watch(postProvider(postId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Post Details'),
      ),
      body: postAsyncValue.when(
        data: (post) => SingleChildScrollView(
          child: Column(
            children: [
              PostCard(post: post), // Reusing the PostCard widget
              const Divider(),
              // Comments Section
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Comments',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // Display comments if available
              ...post.comments.map(
                (comment) => ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(comment.profilePic),
                  ),
                  title: Text(comment.username),
                  subtitle: Text(comment.text),
                ),
              ),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }
}

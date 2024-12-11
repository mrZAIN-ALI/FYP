import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mualij/core/common/error_text.dart';
import 'package:mualij/core/common/loader.dart';
import 'package:mualij/core/common/post_card.dart';
import 'package:mualij/features/auth/controlller/auth_controller.dart';
import 'package:mualij/features/post/controller/post_controller.dart';
import 'package:mualij/features/post/widgets/comment_card.dart';
import 'package:mualij/models/post_model.dart';

class CommentsScreen extends ConsumerStatefulWidget {
  final String postId;
  const CommentsScreen({
    super.key,
    required this.postId,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends ConsumerState<CommentsScreen> {
  final commentController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    commentController.dispose();
  }

  void addComment(Post post) {
    ref.read(postControllerProvider.notifier).addComment(
          context: context,
          text: commentController.text.trim(),
          post: post,
        );
    setState(() {
      commentController.text = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider)!;
    final isGuest = !user.isAuthenticated;

    return Scaffold(
      appBar: AppBar(),
      body: ref.watch(getPostByIdProvider(widget.postId)).when(
            data: (post) {
              return Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          PostCard(post: post),
                          const SizedBox(height: 8),
                          ref
                              .watch(getPostCommentsProvider(widget.postId))
                              .when(
                                data: (comments) {
                                  return ListView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: comments.length,
                                    itemBuilder: (context, index) {
                                      final comment = comments[index];
                                      return CommentCard(comment: comment);
                                    },
                                  );
                                },
                                error: (error, stackTrace) =>
                                    ErrorText(error: error.toString()),
                                loading: () =>
                                    const LinearProgressIndicator(),
                              ),
                        ],
                      ),
                    ),
                  ),

                  // Text Field Section (Fixed Overflow)
                  if (!isGuest)
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextField(
                          onSubmitted: (val) => addComment(post),
                          controller: commentController,
                          decoration: InputDecoration(
                            hintText: 'What are your thoughts?',
                            filled: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
            error: (error, stackTrace) =>
                ErrorText(error: error.toString()),
            loading: () => const Loader(),
          ),
    );
  }
}

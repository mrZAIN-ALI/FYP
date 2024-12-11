import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mualij/features/auth/controlller/auth_controller.dart';
import 'package:mualij/features/post/controller/post_controller.dart';
import 'package:mualij/models/comment_model.dart';
import 'package:mualij/models/user_model.dart';
import 'package:mualij/responsive/responsive.dart';
import 'package:routemaster/routemaster.dart';

class CommentCard extends ConsumerWidget {
  void navigateToUser(BuildContext context, String uid) {
    print("Navigating to user profile" + uid);
    Routemaster.of(context).push('/u/$uid');
  }

  // String getUsername(String uid){
  //   final user = ref.watch(getUserByUidProvider(uid));
  // }

  final Comment comment;
  const CommentCard({
    super.key,
    required this.comment,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Responsive(
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: 10,
          horizontal: 4,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: () => navigateToUser(context, comment.commenterid),
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(
                      comment.profilePic,
                    ),
                    radius: 18,
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ref.watch(getUserByUidProvider(comment.commenterid)).
                          when(
                            data: (data) => data.name,
                            loading: () => 'Loading...',
                            error: (error, _) => 'doctor: $error',
                          ),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(comment.text)
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.reply),
                ),
                const Text('Reply'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

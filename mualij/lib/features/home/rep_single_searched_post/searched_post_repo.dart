import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mualij/models/post_model.dart';

class PostRepository {
  final FirebaseFirestore _firestore;

  PostRepository({required FirebaseFirestore firestore})
      : _firestore = firestore;

  Future<Post> getPostById(String postId) async {
    final doc = await _firestore.collection('posts').doc(postId).get();

    if (!doc.exists) {
      throw Exception('Post not found');
    }

    return Post.fromMap(doc.data()!);
  }
}
final postRepositoryProvider = Provider<PostRepository>((ref) {
  return PostRepository(firestore: FirebaseFirestore.instance);
});

final postProvider = FutureProvider.family<Post, String>((ref, postId) async {
  final postRepository = ref.read(postRepositoryProvider);
  return postRepository.getPostById(postId);
});

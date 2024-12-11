import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final usersSearchProvider = Provider((ref) => FirebaseFirestore.instance.collection('users'));
final communitiesSearchProvider = Provider((ref) => FirebaseFirestore.instance.collection('communities'));
final postsSearchProvider = Provider((ref) => FirebaseFirestore.instance.collection('posts'));

class SearchRepository {
  final FirebaseFirestore _firestore;

  SearchRepository({required FirebaseFirestore firestore}) : _firestore = firestore;

 // Search Users with Substring Matching
Stream<List<Map<String, dynamic>>> searchUsers(String query) {
  if (query.isEmpty) return Stream.value([]);
  return _firestore.collection('users').snapshots().map((snapshot) {
    return snapshot.docs
        .map((doc) => doc.data())
        .where((data) => data['username']
            .toString()
            .toLowerCase()
            .contains(query.toLowerCase()))
        .toList();
  });
}

// Search Communities with Substring Matching
Stream<List<Map<String, dynamic>>> searchCommunities(String query) {
  if (query.isEmpty) return Stream.value([]);
  return _firestore.collection('communities').snapshots().map((snapshot) {
    return snapshot.docs
        .map((doc) => doc.data())
        .where((data) => data['name']
            .toString()
            .toLowerCase()
            .contains(query.toLowerCase()))
        .toList();
  });
}

// Search Posts with Substring Matching
Stream<List<Map<String, dynamic>>> searchPosts(String query) {
  if (query.isEmpty) return Stream.value([]);
  return _firestore.collection('posts').snapshots().map((snapshot) {
    return snapshot.docs
        .map((doc) => doc.data())
        .where((data) => data['title']
            .toString()
            .toLowerCase()
            .contains(query.toLowerCase()))
        .toList();
  });
}
}

final searchRepositoryProvider = Provider(
  (ref) => SearchRepository(firestore: FirebaseFirestore.instance),
);

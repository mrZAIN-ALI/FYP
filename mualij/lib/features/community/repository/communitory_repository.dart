import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mualij/core/constants/firebase_constants.dart';
import 'package:mualij/core/failure.dart';
import 'package:mualij/core/providers/firebase_providers.dart';
import 'package:mualij/core/type_defs.dart';
import 'package:mualij/models/community_model.dart';
import 'package:mualij/models/post_model.dart';

final communityRepositoryProvider = Provider((ref) {
  return CommunityRepository(firestore: ref.watch(firestoreProvider));
});

class CommunityRepository {
  final FirebaseFirestore _firestore;
  CommunityRepository({required FirebaseFirestore firestore})
      : _firestore = firestore;

  FutureVoid createCommunity(Community community) async {
    try {
      var communityDoc = await _communities.doc(community.name).get();
      if (communityDoc.exists) {
        throw 'Community with the same name already exists!';
      }

      return right(_communities.doc(community.name).set(community.toMap()));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  FutureVoid joinCommunity(String communityName, String userId) async {
    try {
      return right(_communities.doc(communityName).update({
        'members': FieldValue.arrayUnion([userId]),
      }));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  FutureVoid leaveCommunity(String communityName, String userId) async {
    try {
      return right(_communities.doc(communityName).update({
        'members': FieldValue.arrayRemove([userId]),
      }));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Stream<List<Community>> getUserCommunities(String uid) {
    return _communities
        .where('members', arrayContains: uid)
        .snapshots()
        .map((event) {
      List<Community> communities = [];
      for (var doc in event.docs) {
        communities.add(Community.fromMap(doc.data() as Map<String, dynamic>));
      }
      return communities;
    });
  }

  Stream<Community> getCommunityByName(String name) {
    return _communities.doc(name).snapshots().map(
        (event) => Community.fromMap(event.data() as Map<String, dynamic>));
  }

  FutureVoid editCommunity(Community community) async {
    try {
      return right(_communities.doc(community.name).update(community.toMap()));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Stream<List<Community>> searchCommunity(String query) {
    return _communities
        .where(
          'name',
          isGreaterThanOrEqualTo: query.isEmpty ? 0 : query,
          isLessThan: query.isEmpty
              ? null
              : query.substring(0, query.length - 1) +
                  String.fromCharCode(
                    query.codeUnitAt(query.length - 1) + 1,
                  ),
        )
        .snapshots()
        .map((event) {
      List<Community> communities = [];
      for (var community in event.docs) {
        communities
            .add(Community.fromMap(community.data() as Map<String, dynamic>));
      }
      return communities;
    });
  }

  FutureVoid addMods(String communityName, List<String> uids) async {
    try {
      return right(_communities.doc(communityName).update({
        'mods': uids,
      }));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Stream<List<Post>> getCommunityPosts(String name) {
    return _posts
        .where('communityName', isEqualTo: name)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (event) => event.docs
              .map(
                (e) => Post.fromMap(
                  e.data() as Map<String, dynamic>,
                ),
              )
              .toList(),
        );
  }
//Tagging/Flair

FutureVoid addFlair(String communityName, String flair) async {
  try {
    return right(_communities.doc(communityName).update({
      'flairs': FieldValue.arrayUnion([flair]),
    }));
  } on FirebaseException catch (e) {
    return left(Failure(e.message ?? 'Error adding flair'));
  } catch (e) {
    return left(Failure(e.toString()));
  }
}

FutureVoid removeFlair(String communityName, String flair) async {
  try {
    return right(_communities.doc(communityName).update({
      'flairs': FieldValue.arrayRemove([flair]),
    }));
  } on FirebaseException catch (e) {
    return left(Failure(e.message ?? 'Error removing flair'));
  } catch (e) {
    return left(Failure(e.toString()));
  }
}
// Add this updateFlair method inside your CommunityRepository class:
FutureVoid updateFlair(
  String communityName, 
  String oldFlair, 
  String newFlair
) async {
  try {
    await _firestore.runTransaction((transaction) async {
      DocumentReference communityRef = _communities.doc(communityName);
      DocumentSnapshot snapshot = await transaction.get(communityRef);
      if (!snapshot.exists) {
        throw 'Community not found!';
      }
      List<dynamic> currentFlairs = snapshot.get('flairs');
      // Remove old flair if it exists
      if (currentFlairs.contains(oldFlair)) {
        currentFlairs.remove(oldFlair);
      }
      // Add new flair if it doesn't already exist
      if (!currentFlairs.contains(newFlair)) {
        currentFlairs.add(newFlair);
      }
      transaction.update(communityRef, {'flairs': currentFlairs});
    });
    return right(null);
  } on FirebaseException catch (e) {
    return left(Failure(e.message ?? 'Error updating flair'));
  } catch (e) {
    return left(Failure(e.toString()));
  }
}

//
  CollectionReference get _posts =>
      _firestore.collection(FirebaseConstants.postsCollection);
  CollectionReference get _communities =>
      _firestore.collection(FirebaseConstants.communitiesCollection);
}

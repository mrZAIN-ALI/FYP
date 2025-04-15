import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mualij/core/constants/firebase_constants.dart';
import 'package:mualij/core/failure.dart';
import 'package:mualij/core/type_defs.dart';
import 'package:mualij/models/notification_model.dart';
import '../../../core/providers/firebase_providers.dart';

final notificationRepositoryProvider = Provider((ref) {
  return NotificationRepository(firestore: ref.watch(firestoreProvider));
});

class NotificationRepository {
  final FirebaseFirestore _firestore;
  NotificationRepository({required FirebaseFirestore firestore})
      : _firestore = firestore;

  CollectionReference get _notifications =>
      _firestore.collection(FirebaseConstants.notificationsCollection);

  // Fetch notifications for the user (receiverId)
  Stream<List<NotificationModel>> getNotifications(String userId) {
    return _notifications
        .where('receiverId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) =>
                NotificationModel.fromMap(doc.data() as Map<String, dynamic>))
            .toList());
  }

  FutureVoid markAllAsRead(String userId) async {
    try {
      final querySnapshot =
          await _notifications.where('receiverId', isEqualTo: userId).get();
      for (var doc in querySnapshot.docs) {
        await doc.reference.update({'isRead': true});
      }
      return right(null);
    } on FirebaseException catch (e) {
      return left(Failure(e.message!));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  FutureVoid deleteAllNotifications(String userId) async {
    try {
      final querySnapshot =
          await _notifications.where('receiverId', isEqualTo: userId).get();
      for (var doc in querySnapshot.docs) {
        await doc.reference.delete();
      }
      return right(null);
    } on FirebaseException catch (e) {
      return left(Failure(e.message!));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  FutureVoid addNotification(NotificationModel notification) async {
    try {
      return right(
          _notifications.doc(notification.id).set(notification.toMap()));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }
}

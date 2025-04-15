import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mualij/core/failure.dart';
import 'package:mualij/core/type_defs.dart';
import 'package:mualij/models/notification_model.dart';
import 'package:mualij/features/notifications/notification_repository.dart';
import 'package:mualij/features/auth/controlller/auth_controller.dart';

final notificationControllerProvider =
    StateNotifierProvider<NotificationController, bool>((ref) {
  final notificationRepository = ref.watch(notificationRepositoryProvider);
  return NotificationController(
      notificationRepository: notificationRepository, ref: ref);
});

final getNotificationsProvider =
    StreamProvider.family<List<NotificationModel>, String>((ref, userId) {
  return ref.read(notificationControllerProvider.notifier).getNotifications(userId);
});

class NotificationController extends StateNotifier<bool> {
  final NotificationRepository _notificationRepository;
  final Ref _ref;
  NotificationController({
    required NotificationRepository notificationRepository,
    required Ref ref,
  })  : _notificationRepository = notificationRepository,
        _ref = ref,
        super(false);

  Stream<List<NotificationModel>> getNotifications(String userId) {
    return _notificationRepository.getNotifications(userId);
  }

  FutureVoid markAllAsRead(String userId, BuildContext context) async {
    state = true;
    final result = await _notificationRepository.markAllAsRead(userId);
    result.fold(
      (l) => ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l.message))),
      (r) => ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('All notifications marked as read'))),
    );
    state = false;
    return right(null);
  }

  FutureVoid deleteAllNotifications(String userId, BuildContext context) async {
    state = true;
    final result = await _notificationRepository.deleteAllNotifications(userId);
    result.fold(
      (l) => ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l.message))),
      (r) => ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('All notifications deleted'))),
    );
    state = false;
    return right(null);
  }
}

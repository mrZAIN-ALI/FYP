import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mualij/core/common/error_text.dart';
import 'package:mualij/core/common/loader.dart';
import 'package:mualij/models/notification_model.dart';
import 'package:mualij/features/notifications/notification_controller.dart';
import 'package:mualij/features/auth/controlller/auth_controller.dart';

class NotificationScreen extends ConsumerWidget {
  const NotificationScreen({Key? key}) : super(key: key);
  
  String _formatTime(DateTime timestamp) {
    final hour = timestamp.hour.toString().padLeft(2, '0');
    final minute = timestamp.minute.toString().padLeft(2, '0');
    return "$hour:$minute";
  }
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider)!;
    final notificationsAsyncValue = ref.watch(getNotificationsProvider(user.uid));
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: Column(
        children: [
          // Action Buttons Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () async {
                      await ref
                          .read(notificationControllerProvider.notifier)
                          .markAllAsRead(user.uid, context);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.blueGrey, side: const BorderSide(color: Colors.blueGrey),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text("Mark all as read"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () async {
                      await ref
                          .read(notificationControllerProvider.notifier)
                          .deleteAllNotifications(user.uid, context);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.blueGrey, side: const BorderSide(color: Colors.blueGrey),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text("Delete all"),
                  ),
                ),
              ],
            ),
          ),
          // Notification List
          Expanded(
            child: notificationsAsyncValue.when(
              data: (notifications) {
                if (notifications.isEmpty) {
                  return const Center(child: Text("No notifications available"));
                }
                return ListView.builder(
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    final notification = notifications[index];
                    final isUnread = !notification.isRead;
                    final actionMessage = notification.notificationType == "upvote"
                        ? "liked your post"
                        : "downvoted your post";
                    
                    return Card(
                      color: isUnread ? Colors.blue.shade50 : Colors.white,
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Time Row
                            Row(
                              children: [
                                Text(
                                  _formatTime(notification.timestamp),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            // Post Title Label Row
                            Row(
                              children: [
                                const Text(
                                  "Post Title: ",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.blueGrey,
                                  ),
                                ),
                                                          Text(
                              notification.postTitle.isNotEmpty
                                  ? notification.postTitle
                                  : "Post",
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
                              ),
                            )
                              ],
                            ),

                            const SizedBox(height: 10),
                            // Descriptive notification message with icon
                            Row(
                              children: [
                                Icon(
                                  notification.notificationType == 'upvote'
                                      ? Icons.thumb_up
                                      : Icons.thumb_down,
                                  color: notification.notificationType == 'upvote'
                                      ? Colors.green
                                      : Colors.red,
                                  size: 20,
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    "${notification.senderUsername} $actionMessage.",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: isUnread ? Colors.black : Colors.grey.shade700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              error: (error, stackTrace) => ErrorText(error: error.toString()),
              loading: () => const Loader(),
            ),
          ),
        ],
      ),
    );
  }
}

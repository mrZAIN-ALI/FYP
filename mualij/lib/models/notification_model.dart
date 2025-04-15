import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String id;
  final String postId;
  final String notificationType; // e.g., "upvote" or "downvote"
  final String receiverId;
  final String senderId;
  final DateTime timestamp;
  final bool isRead;
  final String postTitle; // New: Title of the post
  final String senderUsername; // New: Username of the sender

  NotificationModel({
    required this.id,
    required this.postId,
    required this.notificationType,
    required this.receiverId,
    required this.senderId,
    required this.timestamp,
    required this.isRead,
    required this.postTitle,
    required this.senderUsername,
  });

  NotificationModel copyWith({
    String? id,
    String? postId,
    String? notificationType,
    String? receiverId,
    String? senderId,
    DateTime? timestamp,
    bool? isRead,
    String? postTitle,
    String? senderUsername,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      notificationType: notificationType ?? this.notificationType,
      receiverId: receiverId ?? this.receiverId,
      senderId: senderId ?? this.senderId,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      postTitle: postTitle ?? this.postTitle,
      senderUsername: senderUsername ?? this.senderUsername,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'postId': postId,
      'notificationType': notificationType,
      'receiverId': receiverId,
      'senderId': senderId,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'isRead': isRead,
      'postTitle': postTitle,
      'senderUsername': senderUsername,
    };
  }

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      id: map['id'] ?? '',
      postId: map['postId'] ?? '',
      notificationType: map['notificationType'] ?? '',
      receiverId: map['receiverId'] ?? '',
      senderId: map['senderId'] ?? '',
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp']),
      isRead: map['isRead'] ?? false,
      postTitle: map['postTitle'] ?? '',
      senderUsername: map['senderUsername'] ?? '',
    );
  }
}

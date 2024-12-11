class Comment {
  final String id;
  final String text;
  final DateTime createdAt;
  final String postId;
  final String commenterid;
  final String profilePic;
  Comment({
    required this.id,
    required this.text,
    required this.createdAt,
    required this.postId,
    required this.commenterid,
    required this.profilePic,
  });

  Comment copyWith({
    String? id,
    String? text,
    DateTime? createdAt,
    String? postId,
    String? commenterid,
    String? profilePic,
  }) {
    return Comment(
      id: id ?? this.id,
      text: text ?? this.text,
      createdAt: createdAt ?? this.createdAt,
      postId: postId ?? this.postId,
      commenterid: commenterid ?? this.commenterid,
      profilePic: profilePic ?? this.profilePic,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'postId': postId,
      'commenterid': commenterid,
      'profilePic': profilePic,
    };
  }

  factory Comment.fromMap(Map<String, dynamic> map) {
    return Comment(
      id: map['id'] ?? '',
      text: map['text'] ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      postId: map['postId'] ?? '',
      commenterid: map['commenterid'] ?? '',
      profilePic: map['profilePic'] ?? '',
    );
  }

  @override
  String toString() {
    return 'Comment(id: $id, text: $text, createdAt: $createdAt, postId: $postId, commenterid: $commenterid, profilePic: $profilePic)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Comment &&
        other.id == id &&
        other.text == text &&
        other.createdAt == createdAt &&
        other.postId == postId &&
        other.commenterid == commenterid &&
        other.profilePic == profilePic;
  }

  @override
  int get hashCode {
    return id.hashCode ^ text.hashCode ^ createdAt.hashCode ^ postId.hashCode ^ commenterid.hashCode ^ profilePic.hashCode;
  }
}

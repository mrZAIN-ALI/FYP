import 'package:flutter/foundation.dart';

class UserModel {
  final String username;
  final String name;
  final String profilePic;
  final String banner;
  final String uid;
  final bool isAuthenticated;
  final int karma;
  final List<String> awards;
  final String professionalBackground;
  final List<String> expertiseAreas;
  final bool isVerifiedDoctor; // ✅ NEW FIELD

  UserModel({
    required this.username,
    required this.name,
    required this.profilePic,
    required this.banner,
    required this.uid,
    required this.isAuthenticated,
    required this.karma,
    required this.awards,
    required this.professionalBackground,
    required this.expertiseAreas,
    required this.isVerifiedDoctor, // ✅ NEW FIELD
  });

  UserModel copyWith({
    String? username,
    String? name,
    String? profilePic,
    String? banner,
    String? uid,
    bool? isAuthenticated,
    int? karma,
    List<String>? awards,
    String? professionalBackground,
    List<String>? expertiseAreas,
    bool? isVerifiedDoctor, // ✅ NEW FIELD
  }) {
    return UserModel(
      username: username ?? this.username,
      name: name ?? this.name,
      profilePic: profilePic ?? this.profilePic,
      banner: banner ?? this.banner,
      uid: uid ?? this.uid,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      karma: karma ?? this.karma,
      awards: awards ?? this.awards,
      professionalBackground: professionalBackground ?? this.professionalBackground,
      expertiseAreas: expertiseAreas ?? this.expertiseAreas,
      isVerifiedDoctor: isVerifiedDoctor ?? this.isVerifiedDoctor, // ✅ NEW FIELD
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'name': name,
      'profilePic': profilePic,
      'banner': banner,
      'uid': uid,
      'isAuthenticated': isAuthenticated,
      'karma': karma,
      'awards': awards,
      'professionalBackground': professionalBackground,
      'expertiseAreas': expertiseAreas,
      'isVerifiedDoctor': isVerifiedDoctor, // ✅ NEW FIELD
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      username: map['username'] ?? '',
      name: map['name'] ?? '',
      profilePic: map['profilePic'] ?? '',
      banner: map['banner'] ?? '',
      uid: map['uid'] ?? '',
      isAuthenticated: map['isAuthenticated'] ?? false,
      karma: map['karma']?.toInt() ?? 0,
      awards: List<String>.from(map['awards'] ?? []),
      professionalBackground: map['professionalBackground'] ?? '',
      expertiseAreas: List<String>.from(map['expertiseAreas'] ?? []),
      isVerifiedDoctor: map['isVerifiedDoctor'] ?? false, // ✅ NEW FIELD
    );
  }

  @override
  String toString() {
    return 'UserModel(username: $username, name: $name, profilePic: $profilePic, banner: $banner, uid: $uid, isAuthenticated: $isAuthenticated, karma: $karma, awards: $awards, professionalBackground: $professionalBackground, expertiseAreas: $expertiseAreas, isVerifiedDoctor: $isVerifiedDoctor)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserModel &&
        other.username == username &&
        other.name == name &&
        other.profilePic == profilePic &&
        other.banner == banner &&
        other.uid == uid &&
        other.isAuthenticated == isAuthenticated &&
        other.karma == karma &&
        listEquals(other.awards, awards) &&
        other.professionalBackground == professionalBackground &&
        listEquals(other.expertiseAreas, expertiseAreas) &&
        other.isVerifiedDoctor == isVerifiedDoctor; // ✅ NEW FIELD
  }

  @override
  int get hashCode {
    return username.hashCode ^
        name.hashCode ^
        profilePic.hashCode ^
        banner.hashCode ^
        uid.hashCode ^
        isAuthenticated.hashCode ^
        karma.hashCode ^
        awards.hashCode ^
        professionalBackground.hashCode ^
        expertiseAreas.hashCode ^
        isVerifiedDoctor.hashCode; // ✅ NEW FIELD
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';

class UserEntity {
  final String? uId;
  final String? name;
  final String? email;
  final String? password;
  final String? image;
  final DateTime? lastActive;
  final bool? isOnline;

  UserEntity({
    this.password,
    this.uId,
    this.name,
    this.email,
    this.image,
    this.lastActive,
    this.isOnline,
  });

  factory UserEntity.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      // Handle null case, throw an error or return default values
      throw Exception('User data is null');
    }
    DateTime lastActiveDateTime;

    try {
      final lastActive = json['lastActive'];
      if (lastActive is String) {
        lastActiveDateTime = DateTime.parse(lastActive);
      } else if (lastActive is Timestamp) {
        lastActiveDateTime = lastActive.toDate();
      } else {
        // Handle other cases or set a default value
        lastActiveDateTime = DateTime.now();
      }
    } catch (e) {
      // Handle any parsing errors here
      lastActiveDateTime = DateTime.now();
    }
    return UserEntity(
      uId: json["uId"] ?? '',
      name: json["name"] ?? '',
      email: json["email"] ?? '',
      password: json["password"] ?? '',
      image: json["image"] ?? '',
      lastActive: lastActiveDateTime,
      isOnline: json["isOnline"]?.toString().toLowerCase() == 'true',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "uId": uId,
      "name": name,
      "email": email,
      "password": password,
      "image": image,
      "lastActive": lastActive!.toIso8601String(),
      "isOnline": isOnline,
    };
  }
}

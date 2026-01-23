import 'package:communal/backend/users_backend.dart';
import 'package:communal/routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

class Profile {
  String username;
  String id;
  bool show_email;
  String? email;
  String? bio;
  String? avatar_path;
  String? fcm_token;
  bool is_admin = false;
  bool is_friend = false;

  final RxBool loading = false.obs;

  Profile({
    required this.username,
    required this.id,
    required this.show_email,
    this.avatar_path,
    this.is_admin = false,
  });

  bool get isCurrentUser {
    return UsersBackend.currentUserId == id;
  }

  void goToProfilePage(BuildContext context) {
    if (id == UsersBackend.currentUserId) {
      context.push(
        RouteNames.profileOwnPage,
      );
    } else {
      context.push(
        RouteNames.profileOtherPage.replaceFirst(':userId', id),
      );
    }
  }

  Profile.empty()
      : username = '',
        show_email = false,
        id = '';

  Profile.copy(Profile source)
      : username = source.username,
        id = source.id,
        show_email = source.show_email,
        bio = source.bio,
        email = source.email,
        avatar_path = source.avatar_path,
        is_admin = source.is_admin;

  Profile.fromMap(Map<String, dynamic> map)
      : username = map['username'],
        id = map['id'],
        show_email = map['show_email'],
        bio = map['bio'],
        email = map['email'],
        fcm_token = map['fcm_token'],
        avatar_path = map['avatar_path'];
}

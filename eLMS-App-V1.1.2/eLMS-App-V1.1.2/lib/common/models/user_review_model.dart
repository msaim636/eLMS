import 'dart:convert';
import 'package:elms/common/models/blueprints.dart';
import 'package:elms/utils/extensions/data_type_extensions.dart';

class UserModel {
  final int id;
  final String name;
  final String avatar;
  final String email;

  UserModel({
    required this.id,
    required this.name,
    required this.avatar,
    required this.email,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map.require<int>('id'),
      name: map.require<String>('name'),
      avatar: map.require<String>('avatar'),
      email: map.require<String>('email'),
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'avatar': avatar, 'email': email};
  }
}

class MyReviewModel extends Model {
  final int id;
  final num rating;
  final String review;
  final String createdAt;
  final String? timestamp;
  final String? timeAgo;
  final bool? canEdit;

  MyReviewModel({
    required this.id,
    required this.rating,
    required this.review,
    required this.createdAt,
    required this.timestamp,
    required this.timeAgo,
    required this.canEdit,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'rating': rating,
      'review': review,
      'created_at': createdAt,
      'timestamp': timestamp,
      'time_ago': timeAgo,
      'can_edit': canEdit,
    };
  }

  factory MyReviewModel.fromMap(Map<String, dynamic> map) {
    return MyReviewModel(
      id: map.require<int>('id'),
      rating: map.require<num>('rating').toDouble(),
      review: map.require<String>('review'),
      createdAt: map.require<String>('created_at'),
      timestamp: map.require<String?>('timestamp'),
      timeAgo: map.require<String?>('time_ago'),
      canEdit: map.require<bool?>('can_edit'),
    );
  }

  factory MyReviewModel.fromJson(String source) =>
      MyReviewModel.fromMap(json.decode(source));
}

class UserReviewModel extends Model {
  final int id;
  final num rating;
  final String review;
  final UserModel user;
  final String createdAt;
  final String timestamp;
  final String timeAgo;

  UserReviewModel({
    required this.id,
    required this.rating,
    required this.review,
    required this.user,
    required this.createdAt,
    required this.timestamp,
    required this.timeAgo,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'rating': rating,
      'review': review,
      'user': user.toJson(),
      'created_at': createdAt,
      'timestamp': timestamp,
      'time_ago': timeAgo,
    };
  }

  factory UserReviewModel.fromMap(Map<String, dynamic> map) {
    return UserReviewModel(
      id: map.require<int>('id'),
      rating: map.require<num>('rating').toDouble(),
      review: map.require<String>('review'),
      user: UserModel.fromMap(map.require<Map<String, dynamic>>('user')),
      createdAt: map.require<String>('created_at'),
      timestamp: map.require<String>('timestamp'),
      timeAgo: map.require<String>('time_ago'),
    );
  }

  factory UserReviewModel.fromJson(String source) =>
      UserReviewModel.fromMap(json.decode(source));
}

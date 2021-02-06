import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:disfigstyle/types/app_rights.dart';
import 'package:disfigstyle/types/app_stats.dart';
import 'package:disfigstyle/types/app_urls.dart';
import 'package:disfigstyle/types/partial_user.dart';
import 'package:disfigstyle/types/app_keys.dart';
import 'package:flutter/material.dart';

class UserApp {
  DateTime createdAt;
  String description;
  final String id;
  final AppKeys keys;
  String name;
  final String plan;
  final AppRights rights;
  final AppStats stats;
  DateTime updatedAt;
  final PartialUser user;
  final AppUrls urls;

  UserApp({
    this.createdAt,
    this.description = '',
    @required this.id,
    this.keys,
    this.name = '',
    this.plan = 'free',
    this.rights,
    this.stats,
    this.updatedAt,
    this.urls,
    this.user,
  });

  factory UserApp.fromJSON(Map<String, dynamic> data) {
    return UserApp(
      createdAt: (data['createdAt'] as Timestamp)?.toDate(),
      description: data['description'] ?? '',
      id: data['id'],
      keys: AppKeys.fromJSON(data['keys']),
      name: data['name'],
      plan: data['plan'],
      rights: AppRights.fromJSON(data['rights']),
      stats: AppStats.fromJSON(data['stats']),
      updatedAt: (data['createdAt'] as Timestamp)?.toDate(),
      urls: AppUrls.fromJSON(data['urls']),
      user: PartialUser.fromJSON(data['user']),
    );
  }
}

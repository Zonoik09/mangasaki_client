import 'package:flutter/material.dart';

class FriendManager extends ChangeNotifier {
  static final FriendManager _instance = FriendManager._internal();

  factory FriendManager() => _instance;

  FriendManager._internal();

  List<Map<String, dynamic>> _allFriends = [];

  List<Map<String, dynamic>> get allFriends => _allFriends;

  void updateFriends(Map<String, dynamic> data) {
    final online = List<Map<String, dynamic>>.from(data['online']);
    final offline = List<Map<String, dynamic>>.from(data['offline']);
    _allFriends = [
      ...online.map((f) => {
        'id': f['id'],
        'name': f['nickname'],
        'online': true,
        'friendship_id': f["friendship_id"]
      }),
      ...offline.map((f) => {
        'id': f['id'],
        'name': f['nickname'],
        'online': false,
        'friendship_id': f["friendship_id"]
      }),
    ];

    notifyListeners();
  }
}

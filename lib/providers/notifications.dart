import 'package:flashbacks/models/user.dart';
import 'package:flashbacks/services/api/client.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NotificationsModel extends ChangeNotifier {
  Future<Iterable<FriendRequest>> _futureFriendRequests = Future.value([]);

  Future<Iterable<FriendRequest>> get friendRequests => _futureFriendRequests;

  Future loadFriendRequests(ApiClient apiClient) async {
    _futureFriendRequests = apiClient.authUser.requests();
    notifyListeners();
  }

  Future<bool> newNotifications() async {
    bool output = false;

    await _futureFriendRequests.then((friendRequests) {
      if (friendRequests.isNotEmpty) output = true;
    });

    return output;
  }

  static NotificationsModel fromContext(BuildContext context, [bool listen=false]) {
    return Provider.of<NotificationsModel>(context, listen: listen);
  }
}
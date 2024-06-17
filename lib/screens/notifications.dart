import 'package:flashbacks/providers/api.dart';
import 'package:flashbacks/providers/notifications.dart';
import 'package:flashbacks/services/api_client.dart';
import 'package:flashbacks/utils/widget.dart';
import 'package:flashbacks/widgets/notifications.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late Future<ApiClient> _apiClient;

  @override
  void initState() {
    super.initState();
    _apiClient = ApiModel.fromContext(context).api;
    _apiClient.then((api) =>
        NotificationsModel.fromContext(context).loadFriendRequests(api));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Notifications", style: TextStyle(fontSize: 28)),
        leading: IconButton(icon: const Icon(Symbols.arrow_back), onPressed: () => context.go("/home")),
      ),
      body:
        Padding(
          padding: const EdgeInsets.all(20),
          child: getFutureBuilder(NotificationsModel.fromContext(context).friendRequests, (frs) =>
              Column(children: frs.map((item) => FriendRequestNotification(friendRequest: item)).toList()),
          ),
        ),
    );
  }
}

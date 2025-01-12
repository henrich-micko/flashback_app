// ignore_for_file: curly_braces_in_flow_control_structures

import 'package:flashbacks/models/user.dart';
import 'package:flashbacks/providers/api.dart';
import 'package:flashbacks/services/api/client.dart';
import 'package:flashbacks/utils/widget.dart';
import 'package:flashbacks/widgets/general.dart';
import 'package:flashbacks/widgets/user.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';

class MeScreen extends StatefulWidget {
  const MeScreen({super.key});

  @override
  State<MeScreen> createState() => _MeScreenState();
}

class _MeScreenState extends State<MeScreen> {
  late ApiClient _apiClient;
  late Future<User> _futureUser;
  late Future<Iterable<User>> _futureFriends;

  @override
  void initState() {
    super.initState();

    _apiClient = ApiModel.fromContext(context).api;
    _futureUser = _apiClient.user.me();
    _futureFriends = _apiClient.user.friend.my();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go("/home"),
          ),
        actions: [
          IconButton(onPressed: showOptionsBottomSheet, icon: Icon(Icons.more_vert))
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20),
            child: _buildHeader(),
          ),
          const Gap(20),
          buildSectionHeader("My Friends", []),
          const Gap(5),
          Padding(
            padding: const EdgeInsets.only(right: 20, left: 20),
            child: SizedBox(
                width: MediaQuery.of(context).size.width,
                child: getFutureBuilder(_futureFriends, (friends) => UserCollectionRow(
                  collection: friends,
                  onItemTap: (item) => context.go("/user/${item.id}", extra: "/user/me"),
                ))
            ),
          )
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return getFutureBuilder(
        _futureUser,
            (user) => SizedBox(
            height: 100,
            child: Row(
              children: [
                UserProfilePicture(profilePictureUrl: user.profileUrl, size: 45),

                const Gap(30),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(user.username,
                        style: const TextStyle(
                            color: Colors.white, fontSize: 30)),
                    Text(
                        user.quickDetail,
                        style: const TextStyle(
                            color: Colors.white60, fontSize: 16)),
                    const Gap(2.5),
                  ],
                ),
              ],
            )));
  }

  void showOptionsBottomSheet() {
    double width = MediaQuery.of(context).size.width;

    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) => SizedBox(
          height: 150,
          width: width,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Wrap(
              alignment: WrapAlignment.center,
              direction: Axis.vertical,
              spacing: 30,
              children: [
                SheetAction(title: "Share", icon: Icons.share, onTap: () => {}),
                SheetAction(title: "Logout", icon: Icons.logout, onTap: () {
                  ApiModel.fromContext(context).logout();
                  context.go("/home");
                }),
              ],
            ),
          ),
        )
    );
  }
}
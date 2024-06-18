// ignore_for_file: curly_braces_in_flow_control_structures

import 'package:flashbacks/models/user.dart';
import 'package:flashbacks/providers/api.dart';
import 'package:flashbacks/services/api_client.dart';
import 'package:flashbacks/utils/widget.dart';
import 'package:flashbacks/widgets/user.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

class UserScreen extends StatefulWidget {
  final int userId;
  final String? goBack;
  const UserScreen({super.key, required this.userId, this.goBack});

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  late Future<ApiClient> _futureApiClient;
  late Future<UserPov> _futureUser;

  @override
  void initState() {
    super.initState();
    _futureApiClient = ApiModel.fromContext(context).api;
    _futureUser = _futureApiClient.then((api) => api.user.get(widget.userId));
  }

  void handleActionButtonClick() {
    _futureUser.then((user) =>
      _futureApiClient.then((api) {
        if (user.friendshipStatus == FriendshipStatus.friend) api.user.friend.deleteRequestOrFriendship(user.id);
        else if (user.friendshipStatus == FriendshipStatus.requestToMe) api.user.friend.acceptRequest(user.id);
        else if (user.friendshipStatus == FriendshipStatus.requestFromMe) api.user.friend.deleteRequestOrFriendship(user.id);
        else if (user.friendshipStatus == FriendshipStatus.none) api.user.friend.sendRequest(user.id);

        setState(() {
          _futureUser = _futureApiClient.then((api) => api.user.get(widget.userId));
        });
      })
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              // TODO: FIX THIS HORRIBLE APROACH (navigator.pop doesnt work)
              onPressed: () => context.go(widget.goBack == null ? "/user/search" : widget.goBack!),
        )),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _buildHeader(),
              const Gap(30),
              _buildActionButton()
            ],
          ),
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

  Widget _buildActionButton() {
    double width = MediaQuery.of(context).size.width;

    return getFutureBuilder(_futureUser, (user) =>
      SizedBox(
        width: width,
        height: 50,
        child: OutlinedButton(
          style: OutlinedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            side: const BorderSide(width: 2, color: Colors.white60),
          ),
          onPressed: handleActionButtonClick,
          child: Text(
              user.friendshipStatus == FriendshipStatus.friend ? "Remove from friends" :
                  user.friendshipStatus == FriendshipStatus.requestFromMe ? "Requested" :
                      user.friendshipStatus == FriendshipStatus.requestToMe ? "Accept request" :
                          "Send friend request",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.normal)),
        ),
    ));
  }
}
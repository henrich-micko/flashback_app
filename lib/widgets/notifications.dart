import 'package:flashbacks/models/user.dart';
import 'package:flashbacks/utils/time.dart';
import 'package:flashbacks/widgets/user.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

class FriendRequestNotification extends StatelessWidget {
  final FriendRequest friendRequest;
  final Function()? onTap;

  const FriendRequestNotification({super.key, required this.friendRequest, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          if (onTap != null) onTap!();
          else context.go("/user/${friendRequest.fromUser.id}", extra: "/notifications");
        },
        child: Container(
            color: Colors.transparent,
            width: 360,
            height: 70,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    UserProfilePicture(
                        profilePictureUrl: friendRequest.fromUser.profileUrl),
                    buildProfileInfo(),
                  ],
                ),
              ],
            )));
  }

  Widget buildProfileInfo() {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, left: 15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: [
              const Text("Friend request from ",
                  style: TextStyle(color: Colors.white54, fontSize: 20.0)),
              Text(friendRequest.fromUser.username,
                  style: const TextStyle(color: Colors.white, fontSize: 20.0)),
            ],
          ),
          Text(dateFormat.format(friendRequest.date),
               style: const TextStyle(color: Colors.white54, fontSize: 15))
        ],
      ),
    );
  }
}

class NotificationChip extends StatelessWidget {
  final IconData icon;
  final int value;

  const NotificationChip({super.key, required this.icon, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey),
        const Gap(4),
        Text(value.toString(), style: const TextStyle(fontSize: 18, color: Colors.grey))
      ],
    );
  }
}

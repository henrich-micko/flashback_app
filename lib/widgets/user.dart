import 'package:flashbacks/models/user.dart';
import 'package:flashbacks/providers/api.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

class UserProfilePicture extends StatelessWidget {
  final String profilePictureUrl;
  final double? size;

  const UserProfilePicture(
      {super.key, required this.profilePictureUrl, this.size});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      backgroundImage: NetworkImage(ApiModel.fromContext(context)
          .api
          .apiBaseUrl
          .resolve(profilePictureUrl)
          .toString()),
      radius: size ?? 30,
    );
  }
}

class UserProfilePictureWithUsername extends UserProfilePicture {
  final String username;

  const UserProfilePictureWithUsername(
      {super.key, required super.profilePictureUrl, required this.username});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        super.build(context),
        const Gap(5),
        Text(username, style: const TextStyle(color: Colors.white38)),
      ],
    );
  }
}

class UserCollectionRow<T extends User> extends StatelessWidget {
  final Iterable<T> collection;
  final Function(T item)? onItemTap;

  const UserCollectionRow(
      {super.key, required this.collection, this.onItemTap});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Wrap(
          alignment: WrapAlignment.start,
          spacing: 25,
          children: collection
              .map((item) => GestureDetector(
                    onTap: () => {if (onItemTap != null) onItemTap!(item)},
                    child: UserProfilePictureWithUsername(
                        profilePictureUrl: item.profileUrl,
                        username: item.username),
                  ))
              .toList(),
        ));
  }
}

class UserCollectionColumn<T extends User> extends StatelessWidget {
  final Iterable<T> collection;
  final Function(T item)? onItemTap;

  const UserCollectionColumn(
      {super.key, required this.collection, this.onItemTap});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Wrap(
          direction: Axis.vertical,
          alignment: WrapAlignment.start,
          spacing: 10,
          children: collection
              .map((item) => UserCard(
                  user: item,
                  onTap: () {
                    if (onItemTap != null) onItemTap!(item);
                  }))
              .toList(),
        ));
  }
}

class UserCard extends StatelessWidget {
  final User user;
  final Function()? onTap;

  const UserCard({super.key, required this.user, this.onTap});

  void handleClick() {
    if (onTap != null) onTap!();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: handleClick,
        child: Container(
            color: Colors.transparent,
            width: 360,
            height: 70,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    UserProfilePicture(profilePictureUrl: user.profileUrl),
                    buildProfileInfo()
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
          Text(user.username,
              style: const TextStyle(color: Colors.white, fontSize: 20.0)),
          Text(user.quickDetail,
              style: const TextStyle(color: Colors.white54, fontSize: 15.0)),
        ],
      ),
    );
  }
}

class UserAsSelector extends StatefulWidget {
  final UserContextual user;
  final bool? defaultValue;
  final Function(bool value)? onChanged;

  const UserAsSelector(
      {super.key, required this.user, this.defaultValue, this.onChanged});

  @override
  State<UserAsSelector> createState() => _UserAsSelector();
}

class _UserAsSelector extends State<UserAsSelector> {
  late bool isSelected;

  @override
  void initState() {
    super.initState();
    isSelected = widget.defaultValue ?? false;
  }

  void handleClick() {
    setState(() => isSelected = !isSelected);
    if (widget.onChanged != null) widget.onChanged!(isSelected);
  }

  String _getMutualFriendLabel() {
    if (widget.user.mutualFriends.isEmpty) return "This user is stranger";
    return "Friend with ${widget.user.mutualFriends.first.username}"
        "${widget.user.mutualFriends.length == 1 ? "" : "and ${widget.user.mutualFriends.length - 1} more"}";
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: handleClick,
        child: Container(
            color: Colors.transparent,
            width: 360,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    UserProfilePicture(
                        profilePictureUrl: widget.user.profileUrl, size: 25),
                    buildProfileInfo()
                  ],
                ),
                isSelected ? const Icon(Symbols.check) : Container(),
              ],
            )));
  }

  Widget buildProfileInfo() {
    return Padding(
      padding: const EdgeInsets.only(left: 15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Text(widget.user.username,
              style: const TextStyle(color: Colors.white, fontSize: 20.0)),
          Text(_getMutualFriendLabel(),
              style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}

class UserStack extends StatelessWidget {
  final List<String> usersProfilePicUrls;
  final double size;

  const UserStack(
      {super.key, required this.usersProfilePicUrls, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: size * 2 + 4,
      width: (size * 2 - 4) * usersProfilePicUrls.length,
      alignment: Alignment.center,
      child: Stack(
          clipBehavior: Clip.none,
          alignment: AlignmentDirectional.bottomEnd,
          children: usersProfilePicUrls
              .asMap()
              .entries
              .map((item) => Positioned(
                    left: item.key * size * 1.5,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: Colors.black,
                            width: 1.0), // Border color and width
                      ),
                      child: UserProfilePicture(
                        profilePictureUrl: item.value,
                        size: size,
                      ),
                    ),
                  ))
              .toList()),
    );
  }
}

enum UserContextualCardLabel {
  status,
  mutualFriends,
}

class UserContextualCard extends StatelessWidget {
  final MiniUserContextual user;
  final Function()? onTap;
  final Widget? actionWidget;
  final UserContextualCardLabel label;

  const UserContextualCard(
      {super.key, required this.user, this.onTap, this.actionWidget, this.label = UserContextualCardLabel.status});

  void _handleTap() {
    if (onTap != null) onTap!();
  }

  String _getMutualFriendLabel() {
    if (user.mutualFriends.isEmpty) return "You have no mutual friends";
    return "Friend with ${user.mutualFriends.first.username}"
        "${user.mutualFriends.length == 1 ? "" : "and ${user.mutualFriends.length - 1} more"}";
  }

  String _getStatusLabel() {
    if (user.friendshipStatus == FriendshipStatus.friend) return "🎎 You are friends";
    if (user.friendshipStatus == FriendshipStatus.requestToMe) return "✨ Wants to be your friend";
    return "You are not related"; // say it nicer
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: _handleTap,
        child: Container(
            color: Colors.transparent,
            width: double.infinity,
            height: 70,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    UserProfilePicture(
                        profilePictureUrl: user.profileUrl, size: 25),
                    buildProfileInfo()
                  ],
                ),
                if (actionWidget != null) actionWidget!,
              ],
            )));
  }

  Widget buildProfileInfo() {
    return Padding(
      padding: const EdgeInsets.only(left: 15.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(user.username,
              style: const TextStyle(color: Colors.white, fontSize: 20.0)),

          if (label == UserContextualCardLabel.status)
            Text(_getStatusLabel(),
                style: const TextStyle(color: Colors.grey)),

          if (label == UserContextualCardLabel.mutualFriends)
            Text(_getMutualFriendLabel(),
                style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}

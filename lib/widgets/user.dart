import 'package:flashbacks/models/user.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

class UserProfilePicture extends StatelessWidget {
  final String profilePictureUrl;
  final double? size;

  const UserProfilePicture({super.key, required this.profilePictureUrl, this.size});

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(10); // Image border
    final size = Size.fromRadius(this.size ?? 30);

    return Container(
      padding: const EdgeInsets.all(0), // Border width
      decoration:
          BoxDecoration(color: Colors.white, borderRadius: borderRadius),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: SizedBox.fromSize(
          size: size, // Image radius
          child: Image.network(profilePictureUrl, fit: BoxFit.cover),
        ),
      ),
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

class UserCollectionRow<T extends BasicUser> extends StatelessWidget {
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

class UserCollectionColumn<T extends BasicUser> extends StatelessWidget {
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
              .map((item) =>
                UserCard(user: item, onTap: () { if (onItemTap != null) onItemTap!(item); })
              ).toList(),
        ));
  }
}

class UserCard extends StatelessWidget {
  final BasicUser user;
  final Function()? onTap;

  const UserCard(
      {super.key, required this.user, this.onTap});

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
                    UserProfilePicture(
                        profilePictureUrl: user.profileUrl),
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
  final BasicUser user;
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
                    UserProfilePicture(
                        profilePictureUrl: widget.user.profileUrl),
                    buildProfileInfo()
                  ],
                ),
                isSelected ? const Icon(Symbols.check) : Container(),
              ],
            )));
  }

  Widget buildProfileInfo() {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, left: 15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(widget.user.username,
              style: const TextStyle(color: Colors.white, fontSize: 20.0)),
          Text(widget.user.quickDetail,
              style: const TextStyle(color: Colors.white54, fontSize: 15.0)),
        ],
      ),
    );
  }
}
import 'package:flashbacks/models/event.dart';
import 'package:flashbacks/models/user.dart';
import 'package:flashbacks/providers/api.dart';
import 'package:flashbacks/services/api/user.dart';
import 'package:flashbacks/utils/widget.dart';
import 'package:flashbacks/var.dart';
import 'package:flashbacks/widgets/event/viewer.dart';
import 'package:flashbacks/widgets/general.dart';
import 'package:flashbacks/widgets/user.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

class UserDetailScreen extends StatefulWidget {
  final int userId;

  const UserDetailScreen({
    super.key,
    required this.userId,
  });

  @override
  State<UserDetailScreen> createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends State<UserDetailScreen> {
  late UserDetailApiClient _userApiClient;
  late Future<UserContextual> _user;
  Iterable<EventViewer> _viewers = [];

  @override
  void initState() {
    super.initState();

    _userApiClient = ApiModel.fromContext(context).api.user.detail(widget.userId);
    _user = _userApiClient.get();
    _user.then((user) => _loadViewers(user.friendshipStatus));
  }

  // load viewers to the
  void _setUser(Future<UserContextual> user) {
    user.then((user) => _loadViewers(user.friendshipStatus));
    setState(() { _user = user; });
  }

  void _loadViewers(FriendshipStatus status) {
    if (status != FriendshipStatus.friend)
      setState(() {
        _viewers = [];
      });
    _userApiClient.viewers().then((viewers) => setState(() {
      _viewers = viewers;
    }));
  }

  void _sendFriendRequest() {
    _setUser(_userApiClient.friend.sendRequest());
  }

  void _closeFriendRequest() {
    _setUser(_userApiClient.friend.deleteRequestOrFriendship());
  }

  void _acceptFriendRequest() {
    _setUser(_userApiClient.friend.acceptRequest());
  }

  void _declineFriendRequest() {
    _setUser(_userApiClient.friend.deleteRequestOrFriendship());
  }

  void _handleUnfriend() {
    context.pop();
    _setUser(_userApiClient.friend.deleteRequestOrFriendship());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        forceMaterialTransparency: true,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0.0,
        leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop()),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Column(
            children: [
              _buildProfileSection(),
              const Gap(7),
              _buildEventViewersSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileSection() {
    return getFutureBuilder(
        _user,
        (user) => Padding(
          padding: const EdgeInsets.only(left: 20, right: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(user.username,
                          style: const TextStyle(fontSize: 30)),
                      _buildMutualFriends(user.mutualFriends),
                      const Gap(2.5),
                      _buildProfileCountInfo(user.eventsCount,
                          user.friendsCount, user.flashbacksCount),
                      if (user.about != null)
                        Text(user.about!,
                            style: const TextStyle(fontSize: 15, color: Colors.white))
                    ],
                  ),
                  UserProfilePicture(
                      profilePictureUrl: user.profileUrl, size: 45),
                ],
              ),

              const Gap(7),
              if (user.friendshipStatus == FriendshipStatus.requestToMe)
                const Text("✨ This user wants to be your friend", style: TextStyle(fontSize: 15)),

              const Gap(10),
              if (user.friendshipStatus == FriendshipStatus.none ||
                  user.friendshipStatus == FriendshipStatus.requestFromMe)
                _buildFriendRequestButton(user.friendshipStatus == FriendshipStatus.requestFromMe),

              if (user.friendshipStatus == FriendshipStatus.requestToMe)
                _buildAcceptFriendRequestButton(),

              if (user.friendshipStatus == FriendshipStatus.friend)
                _buildUnfriendButton(),
            ],
          ),
        ));
  }

  Widget _buildMutualFriends(List<MiniUser> mutualFriends) {
    return SizedBox(
      height: 25,
      child: Row(
        children: mutualFriends.isNotEmpty
            ? [
                const Text("Mutual friends",
                    style: TextStyle(color: Colors.grey, fontSize: 15)),
                const Gap(4),
                UserStack(
                    usersProfilePicUrls:
                        mutualFriends.map((user) => user.profileUrl).toList(),
                    size: 7.5)
              ]
            : [
                const Text("You have no mutual friends",
                    style: TextStyle(color: Colors.grey, fontSize: 15))
              ],
      ),
    );
  }

  Widget _buildProfileCountInfo(
      int eventsCount, int friendsCount, int flashbacksCount) {
    const valueTextStyle = TextStyle(fontSize: 15, color: Colors.white);
    const labelTextStyle = TextStyle(fontSize: 15, color: Colors.grey);

    return Row(
      children: [
        Text(friendsCount.toString(), style: valueTextStyle),
        const Gap(2.5),
        Text("Friend${friendsCount == 1 ? "" : "s"}", style: labelTextStyle),
        const Gap(5),
        Text(eventsCount.toString(), style: valueTextStyle),
        const Gap(2.5),
        Text("Event${eventsCount == 1 ? "" : "s"}", style: labelTextStyle),
        const Gap(5),
        Text(flashbacksCount.toString(), style: valueTextStyle),
        const Gap(2.5),
        Text("Flashback${flashbacksCount == 1 ? "" : "s"}",
            style: labelTextStyle),
      ],
    );
  }

  Widget _buildFriendRequestButton(bool isRequested) {
    final buttonLabel = !isRequested ? "Send friend request" : "Cancel friend request";

    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
          onPressed: () => isRequested ? _closeFriendRequest() : _sendFriendRequest(),
          style: OutlinedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(11),
            ),
            side: const BorderSide(
              color: Colors.grey,
              width: 1,
            ),
          ),
          child: Text(
              buttonLabel,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w400)
          )
      ),
    );
  }

  Widget _buildUnfriendButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
          onPressed: _showUnfriendSubmit,
          style: OutlinedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(11),
            ),
            side: const BorderSide(
              color: Colors.grey,
              width: 1,
            ),
          ),
          child: const Text(
              "Remove as friend",
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400)
          )
      ),
    );
  }

  Widget _buildAcceptFriendRequestButton() {
    return SizedBox(
      width: double.infinity,
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 3),
              child: OutlinedButton(
                  onPressed: _acceptFriendRequest,
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(11),
                    ),
                    side: const BorderSide(
                      color: Colors.grey,
                      width: 1,
                    ),
                  ),
                  child: const Text(
                      "Accept",
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400)
                  )
              ),
            ),
          ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 3),
              child: OutlinedButton(
                  onPressed: _declineFriendRequest,
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(11),
                    ),
                    side: const BorderSide(
                      color: Colors.grey,
                      width: 1,
                    ),
                  ),
                  child: const Text(
                      "Decline",
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400)
                  )
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventViewersSection() {
    if (_viewers.isEmpty) return Container();
    return Padding(
      padding: const EdgeInsets.only(left: 15, right: 10),
      child: EventViewerCardCollection(eventViewers: [_viewers.first]),
    );
  }

  void _showUnfriendSubmit() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: scaffoldBackgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(11),
          ),
          title: const Text("Confirm Action"),
          content: const Text("Do you really want to remove this person as a friend?"),
          actions: [
            TextButton(
              onPressed: _handleUnfriend,
              child: const Text("Delete", style: TextStyle(color: Colors.red)),
            ),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(11),
                ),
                side: const BorderSide(
                  color: Colors.grey,
                  width: 1,
                ),
              ),
              onPressed: () {
                context.pop();
              },
              child: const Text("Cancel"),
            ),
          ],
        );
      },
    );
  }
}

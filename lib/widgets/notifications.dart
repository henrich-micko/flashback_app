import 'package:flashbacks/models/event.dart';
import 'package:flashbacks/models/notifications.dart';
import 'package:flashbacks/providers/api.dart';
import 'package:flashbacks/services/api/auth.dart';
import 'package:flashbacks/services/api/event.dart';
import 'package:flashbacks/services/api/user.dart';
import 'package:flashbacks/utils/time.dart';
import 'package:flashbacks/utils/widget.dart';
import 'package:flashbacks/var.dart';
import 'package:flashbacks/widgets/user.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';


class FriendRequestNotificationCard extends StatelessWidget {
  final FriendRequestNotification notification;
  final Function() onTap;
  final Function() onAccept;
  final Function() onDecline;

  const FriendRequestNotificationCard({
    super.key,
    required this.notification,
    required this.onTap,
    required this.onAccept,
    required this.onDecline
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.only(left: 7.5),
          child: Container(
              color: Colors.transparent,
              width: double.infinity,
              height: 70,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [

                  Row(
                    children: [
                      UserProfilePicture(profilePictureUrl: notification.fromUser.profileUrl, size: 22),
                      buildProfileInfo()
                    ],
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const VerticalDivider(indent: 20, endIndent: 20),
                      IconButton(icon: const Icon(Symbols.check), onPressed: onAccept),
                      IconButton(icon: const Icon(Symbols.close), onPressed: onDecline),
                    ],
                  ),
                ],
              )
          ),
        )
    );
  }

  Widget buildProfileInfo() {
    return Padding(
      padding: const EdgeInsets.only(left: 15.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(notification.fromUser.username,
              style: const TextStyle(color: Colors.white, fontSize: 18.0)),
          const Text("Wants to be your friend ✨", style: TextStyle(color: Colors.grey, fontSize: 14)),
        ],
      ),
    );
  }
}


class EventInviteNotificationCard extends StatefulWidget {
  final EventInviteNotification notification;
  final Function() onTap;
  final Function() onAccept;
  final Function() onDecline;

  const EventInviteNotificationCard({
    super.key,
    required this.notification,
    required this.onTap,
    required this.onAccept,
    required this.onDecline
  });

  @override
  State<EventInviteNotificationCard> createState() => _EventInviteNotificationCardState();
}

class _EventInviteNotificationCardState extends State<EventInviteNotificationCard> {
  bool _isExpanded = false;
  late Future<Iterable<EventMember>> _members;

  @override
  void initState() {
    super.initState();

    _members = ApiModel.fromContext(context)
        .api.event.detail(widget.notification.event.id).member.all();
  }

  void _onTap() {
    setState(() {
      _isExpanded = _isExpanded ? false : true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: _onTap,
        child: AnimatedSize(
        alignment: Alignment.topCenter,
        duration: const Duration(milliseconds: 150),
          child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(11),
              ),
              child: Padding(
                padding: const EdgeInsets.only(left: 7.5, bottom: 7.5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [

                        Row(
                          children: [
                            SizedBox(
                            width: 35,
                              child: Center(
                                  child: Text(widget.notification.event.emoji.code, style: const TextStyle(fontSize: 35))),
                            ),
                            buildProfileInfo()
                          ],
                        ),
                        IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              const VerticalDivider(indent: 7.5, endIndent: 7.5, width: 15),
                              IconButton(icon: const Icon(Symbols.check), onPressed: widget.onAccept),
                              IconButton(icon: const Icon(Symbols.close), onPressed: widget.onDecline),
                            ],
                          ),
                        ),
                      ],
                    ),

                    if (_isExpanded)
                      _buildExpandedSection(),
                  ],
                ),
              )
          ),
        )
    );
  }

  Widget _buildExpandedSection() {
    return Padding(
      padding: const EdgeInsets.only(top: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("When? ${humanizeUpcomingDate(widget.notification.event.startAt)} at ${timeFormat.format(widget.notification.event.startAt)} ", style: const TextStyle(color: Colors.grey, fontSize: 16)),

          getFutureBuilder(_members, (members) =>
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("With who?", style: TextStyle(color: Colors.grey, fontSize: 16)),
                const Gap(5),
                UserStack(
                    usersProfilePicUrls: List.from(
                        members.map((item) => item.user.profileUrl)
                    ),
                    size: 8
                )
              ],
            ))
        ],
      ),
    );
  }

  Widget buildProfileInfo() {
    return Padding(
      padding: const EdgeInsets.only(left: 15.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(widget.notification.event.title,
              style: const TextStyle(color: Colors.white, fontSize: 18.0)),
          Text("${widget.notification.invitedBy.username} invited you ✉️", style: const TextStyle(color: Colors.grey, fontSize: 14)),
        ],
      ),
    );
  }
}

class NotificationsManager extends StatefulWidget {
  final Function() onEmpty;

  const NotificationsManager({super.key, required this.onEmpty});

  @override
  State<NotificationsManager> createState() => _NotificationsManagerState();
}

class _NotificationsManagerState extends State<NotificationsManager> {
  late AuthUserApiClient _authApiClient;
  late UserApiClient _userApiClient;
  late EventApiClient _eventApiClient;

  late Future<Iterable<BaseNotification>> _notifications;
  
  @override
  void initState() {
    super.initState();
  
    _authApiClient = ApiModel.fromContext(context).api.authUser;
    _userApiClient = ApiModel.fromContext(context).api.user;
    _eventApiClient = ApiModel.fromContext(context).api.event;

    _notifications = _authApiClient.notifications();
    _notifications.then(Logger().i);
  }

  void _updateData() {
    final newNotifications = _authApiClient.notifications();
    newNotifications.then((items) {
      if (items.isEmpty)
        widget.onEmpty();
    });

    setState(() {
      _notifications = newNotifications;
    });
  }

  // event handlers for friend request notifications
  
  void _onFriendRequestAccept(FriendRequestNotification item) {
    _userApiClient.detail(item.fromUser.id).friend.acceptRequest().then((_) {
      _updateData();
    });
  }
  
  void _onFriendRequestDecline(FriendRequestNotification item) {
    _userApiClient.detail(item.fromUser.id).friend.deleteRequestOrFriendship().then((_) {
      _updateData();
    });
  }
  
  void _onFriendRequestTap(FriendRequestNotification item) {
    context.push("/user/${item.fromUser.id}/");
  }
  
  // event handlers for event invite notifications
  
  void _onAcceptEventInvite(EventInviteNotification item) {
    _eventApiClient.detail(item.event.id).member.acceptInvite().then((_) {
      _updateData();
    });
  }
  
  void _onDeclineEventInvite(EventInviteNotification item) {
    _eventApiClient.detail(item.event.id).member.declineInvite().then((_) {
      _updateData();
    });
  }
  
  void _onEventInviteTap(EventInviteNotification item) {

  }
  
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return SizedBox(
      width: size.width,
      child: getFutureBuilder(_notifications, (notifications) =>
        Column(
          children: notifications.map((item) => _buildNotification(item)).toList()
      )),
    );
  }
  
  Widget _buildNotification(BaseNotification item) {
    if (item is FriendRequestNotification)
      return FriendRequestNotificationCard(
        notification: item,
        onTap: () => _onFriendRequestTap(item),
        onAccept: () => _onFriendRequestAccept(item),
        onDecline: () => _onFriendRequestDecline(item),
      );
    if (item is EventInviteNotification)
      return EventInviteNotificationCard(
        notification: item,
        onTap: () => _onEventInviteTap(item),
        onAccept: () => _onAcceptEventInvite(item),
        onDecline: () => _onDeclineEventInvite(item),
      );
    return Container();
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


class NewNotifications extends StatelessWidget {
  final Function()? onTap;

  const NewNotifications({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 100,
      child: GestureDetector(
        onTap: () {
          if (onTap != null) onTap!();
        },
        child: const Card.outlined(
          color: Colors.transparent,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text("📮 New notifications",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w400)),
              Text("Tap to solve them!",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w300))
            ],
          ),
        ),
      ),
    );
  }
}
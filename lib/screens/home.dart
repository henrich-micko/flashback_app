import "package:flashbacks/models/notifications.dart";
import "package:flashbacks/providers/api.dart";
import "package:flashbacks/services/api/client.dart";
import "package:flashbacks/utils/widget.dart";
import "package:flashbacks/widgets/event/items.dart";
import "package:flashbacks/widgets/event/viewer.dart";
import "package:flashbacks/widgets/notifications.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import 'package:flashbacks/models/event.dart';
import "package:material_symbols_icons/material_symbols_icons.dart";

class HomeScreen extends StatefulWidget {
  final Function() goLeft;
  final Function() goRight;

  const HomeScreen({super.key, required this.goLeft, required this.goRight});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late ApiClient _apiClient;
  late Future<Iterable<Event>> _events;
  late Future<Iterable<EventViewer>> _eventViewers;
  late ValueNotifier<bool> _notificationExistsNotifier;

  @override
  void initState() {
    super.initState();

    final apiModel = ApiModel.fromContext(context);

    _apiClient = apiModel.api;
    _events = _apiClient.event.all();
    _eventViewers = _apiClient.event.toView();
    _notificationExistsNotifier = ValueNotifier(apiModel.notificationsExists);

    // Listen for changes in notifications
    apiModel.addListener(() {
      _notificationExistsNotifier.value = apiModel.notificationsExists;
    });
  }

  Future _handleRefresh({StateSetter? customSetState}) async {
    final setState_ = customSetState ?? setState;

    setState_(() {
      _events = _apiClient.event.all();
      _eventViewers = _apiClient.event.toView();
    });
  }

  Widget _buildUpcomingEventSection() {
    return Column(
      children: [
        buildSectionHeader("My events", [
          IconButton(
              icon: const Icon(Symbols.arrow_forward),
              onPressed: widget.goRight)
        ]),
        getFutureBuilder<Iterable<Event>>(
            _events,
            (data) => EventCardRow(
                  events: data
                      .where((item) => item.status != EventStatus.closed)
                      .toList(),
                )),
      ],
    );
  }

  void _handleFriendNotificationTap(FriendRequestNotification notification) {
    context.push("/user/${notification.fromUser.id}/");
    Navigator.pop(context);
  }

  void _handleFriendNotificationAccept(
      FriendRequestNotification notification, StateSetter setState_) {
    _apiClient.user
        .detail(notification.fromUser.id)
        .friend
        .acceptRequest()
        .then((_) {
      _handleRefresh(customSetState: setState_);
    });
  }

  void _handleFriendNotificationDecline(
      FriendRequestNotification notification, StateSetter setState_) {
    _apiClient.user
        .detail(notification.fromUser.id)
        .friend
        .deleteRequestOrFriendship()
        .then((_) {
      _handleRefresh(customSetState: setState_);
    });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: const Color(0xFFFF7A7A),
      onRefresh: () => _handleRefresh(),
      child: Scaffold(
        appBar: AppBar(
          forceMaterialTransparency: true,
          surfaceTintColor: Colors.transparent,
          scrolledUnderElevation: 0.0,
          title: const Text("Flashbacks",
              style: TextStyle(fontSize: 30, color: Color(0xFFFF7A7A))),
          actions: [
            IconButton(icon: const Icon(Icons.search), onPressed: widget.goLeft),
            IconButton(
              icon: const Icon(Icons.person),
              onPressed: () => context.push("/user/current"),
            ),
          ],
        ),
        body: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            scrollDirection: Axis.vertical,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                if (ApiModel.fromContext(context, listen: true)
                    .notificationsExists)
                  Padding(
                      padding:
                          const EdgeInsets.only(left: 10, right: 10, top: 10),
                      child: NewNotifications(
                          onTap: () => showModalBottomSheet(
                              context: context,
                              builder: (context) =>
                                  _showNotificationsBottomSheet()))),
                _buildUpcomingEventSection(),
                Padding(
                  padding: const EdgeInsets.only(left: 10, right: 10),
                  child: getFutureBuilder(
                    _eventViewers,
                    (viewers) => EventViewerCardCollection(eventViewers: viewers),
                  ),
                ),
              ],
            ),
          ),
        ),
    );
  }

  Widget _showNotificationsBottomSheet() {
    return Builder(builder: (BuildContext context) {
      return Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          color: Colors.black,
          border: Border(
            top: BorderSide(color: Colors.grey, width: 1),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: 10, bottom: 15),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 15),
                child: Text("Notifications", style: TextStyle(fontSize: 17, color: Colors.grey)),
              ),
              Padding(
                  padding: const EdgeInsets.only(left: 7.5, right: 7.5, top: 10),
                  child: AnimatedSize(
                      alignment: Alignment.topCenter,
                      duration: const Duration(milliseconds: 150),
                      child: NotificationsManager(onEmpty: () {
                        context.pop();
                        _handleRefresh();
                        ApiModel.fromContext(context).reload();
                      })))
            ],
          ),
        ),
      );
    });
  }
}

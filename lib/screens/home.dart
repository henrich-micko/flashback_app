import "package:flashbacks/providers/api.dart";
import "package:flashbacks/providers/notifications.dart";
import "package:flashbacks/services/api_client.dart";
import "package:flashbacks/utils/permissions.dart";
import "package:flashbacks/utils/widget.dart";
import "package:flashbacks/widgets/event.dart";
import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:go_router/go_router.dart";
import 'package:flashbacks/models/event.dart';
import "package:material_symbols_icons/material_symbols_icons.dart";

List getFirstN(List array, int n) {
  if (array.length < n) return array;
  return array.sublist(0, n-1);
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<ApiClient> futureApiClient;
  late Future<Iterable<Event>> futureEvents;
  bool isPreviewOpened = false;

  @override
  void initState() {
    super.initState();
    futureApiClient = ApiModel.fromContext(context).api;
    futureEvents = futureApiClient.then((api) => api.event.all());

    futureApiClient.then((api) =>
      NotificationsModel.fromContext(context).loadFriendRequests(api)
    );
  }

  Future handleRefresh() async {
    futureEvents = futureApiClient.then((api) => api.event.all());
  }

  void handleEventTap(Event event) {
    if (event.status == EventStatus.activated) context.go("/event/${event.id}/flashback/create/");
    else context.go("/event/${event.id}");
  }

  Widget _buildFlashbacksSection() {
    return Column(
      children: [
        buildSectionHeader("Recent", [
          IconButton(
              onPressed: () => setState(() {
                isPreviewOpened = !isPreviewOpened;
              }),
              icon: Icon(!isPreviewOpened ? Symbols.arrow_drop_down : Symbols.arrow_drop_up))
        ]),

        getFutureBuilder<Iterable<Event>>(
            futureEvents, (data) =>
              Padding(
                padding: const EdgeInsets.only(left: 15, right: 15, top: 10),
                child: AnimatedSize(
                  duration: const Duration(milliseconds: 200),
                  child: Column(
                    children: getFirstN(data.where((item) => item.status == EventStatus.closed).toList(), 2).map((item) =>
                        Column(
                          children: [
                            EventCard(event: item, light: true, onTap: () => showFlashbacksBottomSheet(item.id)),
                            const Gap(10)
                          ],
                        ),
                    ).toList(),
                  ),
                ),
              )
        ),
      ],
    );
  }

  Widget _buildEventSection() {
    return Column(
      children: [
        const Gap(25),
        buildSectionHeader("My Events", [
          IconButton(
              icon: const Icon(Symbols.add),
              onPressed: () => context.go("/event/create/"))
        ]),
        Padding(
          padding: const EdgeInsets.only(right: 20, left: 20),
          child: getFutureBuilder<Iterable<Event>>(
              futureEvents, (data) =>
              EventCardColumn(
                  events: data.where((item) => item.status != EventStatus.closed),
                  onTap: handleEventTap
              )
          ),
        ),
      ],
    );
  }

  void showFlashbacksBottomSheet(int eventId) {
    context.go("/event/$eventId/flashback/");
  }

  @override
  Widget build(BuildContext context) {
    return IsAuthenticated(
      child: Scaffold(
          appBar: AppBar(
            forceMaterialTransparency: true,
            surfaceTintColor: Colors.transparent,
            scrolledUnderElevation: 0.0,
            centerTitle: true,
            title: const Text("Flashbacks", style: TextStyle(fontSize: 30)),
            leading: IconButton(
                icon: const Icon(Icons.search), onPressed: () => context.go("/user/search")),
            actions: [
              getFutureBuilder(NotificationsModel.fromContext(context).newNotifications(), (nn) =>
                IconButton(icon: Icon(Icons.favorite_border_rounded, color: nn ? Colors.red : Colors.white70), onPressed: () => context.go("/notifications")),
                IconButton(icon: const Icon(Icons.favorite_border_rounded), onPressed: () => context.go("/notifications"))
              ),

              IconButton(icon: const Icon(Icons.person), onPressed: () => context.go("/user/me")),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: () => handleRefresh(),
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Gap(10),
                  _buildFlashbacksSection(),

                  const Gap(25),
                  _buildEventSection()
                ],
              ),
            ),
          )),
    );
  }
}

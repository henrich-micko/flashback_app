import 'package:flashbacks/models/event.dart';
import 'package:flashbacks/models/user.dart';
import 'package:flashbacks/providers/api.dart';
import 'package:flashbacks/services/api/event.dart';
import 'package:flashbacks/services/api/user.dart';
import 'package:flashbacks/utils/time.dart';
import 'package:flashbacks/utils/widget.dart';
import 'package:flashbacks/widgets/event/item.dart';
import 'package:flashbacks/widgets/event/options.dart';
import 'package:flashbacks/widgets/event/viewer.dart';
import 'package:flashbacks/widgets/user.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';


class CurrUserDetailScreen extends StatefulWidget {
  const CurrUserDetailScreen({super.key});

  @override
  State<CurrUserDetailScreen> createState() => _CurrUserDetailScreen();
}

class _CurrUserDetailScreen extends State<CurrUserDetailScreen> with TickerProviderStateMixin {
  late AuthUserApiClient _userApiClient;
  late EventApiClient _eventApiClient;
  late TabController _tabController;

  late Future<AuthMiniUser> _user;
  late Future<Iterable<EventViewer>> _viewers;
  late Future<Iterable<UserContextual>> _friends;
  late Future<Iterable<Event>> _events;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() => setState(() {}));

    final apiModel = ApiModel.fromContext(context);

    _userApiClient = apiModel.api.authUser;
    _eventApiClient = apiModel.api.event;

    _user = _userApiClient.meComplex();
    _viewers = _eventApiClient.toView(isMember: true);
    _friends = _userApiClient.friends();
    _events = _eventApiClient.all();
  }

  Future _refresh() async {
    setState(() {
      _user = _userApiClient.meComplex();
      _viewers = _eventApiClient.toView(isMember: true);
      _friends = _userApiClient.friends();
      _events = _eventApiClient.all();
    });
  }

  void _navigateToEdit() {
    context.pop();
    context.push("/user/current/edit");
  }

  void _logout() {
    ApiModel.fromContext(context).logout();
    context.pop();
    context.push("/auth");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        color: const Color(0xFFFF7A7A),
        onRefresh: _refresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
              children: [
                AppBar(
                  forceMaterialTransparency: true,
                  surfaceTintColor: Colors.transparent,
                  scrolledUnderElevation: 0.0,
                  leading: IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => context.pop()),
                  actions: [
                    IconButton(
                        onPressed: _showOptionsBottomSheet,
                        icon: const Icon(Symbols.more_vert)
                    )
                  ],
                ),

                const Gap(10),
                _buildProfileSection(),
                _buildTabBar(),

                if (_tabController.index == 1)
                  _buildFlashbacksSection(),
                if (_tabController.index == 0)
                  _buildFriendsSection(),
                if (_tabController.index == 2)
                  _buildEventSections(),
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
                      const Gap(2.5),
                      Text("📮 ${user.email}",
                          style: const TextStyle(fontSize: 15, color: Colors.grey)),
                      const Gap(2.5),
                      Text("🚀 ${humanizePastDateTIme(user.dateJoined, pre: "Joined")}",
                          style: const TextStyle(fontSize: 15, color: Colors.grey)),
                      const Gap(2.5),
                      if (user.about != null)
                        Text(user.about!,
                            style: const TextStyle(fontSize: 15, color: Colors.white)),
                    ],
                  ),
                  UserProfilePicture(
                      profilePictureUrl: user.profileUrl, size: 45),
                ],
              ),
              const Gap(10),
            ],
          ),
        ));
  }

  Widget _buildTabBar() {
    return getFutureBuilder(_user, (user) =>
      TabBar(
        controller: _tabController,
        tabs: [
          Tab(text: "${user.friendsCount} Friend${user.friendsCount == 1 ? "" : "s"}"),
          Tab(text: "${user.flashbacksCount} Flashback${user.flashbacksCount == 1 ? "" : "s"}"),
          Tab(text: "${user.eventsCount} Event${user.eventsCount == 1 ? "" : "s"}"),
        ]),
    );
  }

  Widget _buildFlashbacksSection() {
    return getFutureBuilder(
        _viewers,
            (viewers) => EventViewerCardCollection(eventViewers: viewers));
  }

  Widget _buildFriendsSection() {
    return Padding(
      padding: const EdgeInsets.only(left: 15, top: 10, right: 15),
      child: getFutureBuilder(_friends, (friends) => Column(
      children: friends.map((user) => UserContextualCard(
          user: user, onTap: () => context.push("/user/${user.id}/"), label: UserContextualCardLabel.mutualFriends)).toList(),
    )));
  }

  Widget _buildEventSections() {
    return Padding(
      padding: const EdgeInsets.only(left: 0, top: 10, right: 15),
      child: getFutureBuilder(_events, (events) => Column(
        children: events.map((event) => EventContainer(event: event)).toList(),
      )),
    );
  }

  void _showOptionsBottomSheet() {
    showModalBottomSheet(context: context,
        builder: (BuildContext context) {
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
                    child: Text("Options", style: TextStyle(fontSize: 17, color: Colors.grey)),
                  ),
                  OptionGroupItem(
                    label: "Edit Profile",
                    fontSize: 18,
                    onTap: _navigateToEdit,
                    icon: Symbols.arrow_forward,
                  ),

                  const Gap(10),

                  const Padding(
                    padding: EdgeInsets.only(left: 15),
                    child: Text("Actions", style: TextStyle(fontSize: 17, color: Colors.grey)),
                  ),
                  OptionGroupItem(
                    fontSize: 18,
                    label: "Logout",
                    onTap: _showLogoutSubmit,
                    icon: Symbols.logout,
                  ),
                  OptionGroupItem(
                    fontSize: 18,
                    label: "Delete account",
                    onTap: () => context.push("/event/${widget.key}/members/"),
                    icon: Symbols.delete,
                  ),
                ],
              ),
            ),
          );
        });
  }

  void _showLogoutSubmit() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(11),
            side: const BorderSide(color: Colors.grey, width: 1),
          ),
          title: const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Leaving?"),
              Icon(Symbols.logout)
            ],
          ),
          content: const Text("Are you sure you want to log out? You can log back in anytime 😔"), // something cool about not logging out git?
          actions: [
            TextButton(
              onPressed: () => context.pop(),
              child: const Text("Cancel", style: TextStyle(color: Colors.white)),
            ),

            TextButton(
              onPressed: _logout,
              child: const Text("Logout", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}

import 'package:flashbacks/models/event.dart';
import 'package:flashbacks/models/user.dart';
import 'package:flashbacks/providers/api.dart';
import 'package:flashbacks/services/api/event.dart';
import 'package:flashbacks/services/api/user.dart';
import 'package:flashbacks/widgets/event/item.dart';
import 'package:flashbacks/widgets/event/viewer.dart';
import 'package:flashbacks/widgets/user.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';


enum SearchOption {
  users,
  events,
  flashbacks
}

class SearchScreen extends StatefulWidget {
  final Function() goRight;

  const SearchScreen({super.key, required this.goRight});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  late EventApiClient _eventApiClient;
  late UserApiClient _userApiClient;
  late AuthUserApiClient _authUserApiClient;

  List<MiniUserContextual> _usersResults = [];
  List<Event> _eventResults = [];
  List<EventViewer> _eventViewersResults = [];

  SearchOption _searchOption = SearchOption.users;

  @override
  void initState() {
    super.initState();

    final apiModel = ApiModel.fromContext(context);

    _eventApiClient = apiModel.api.event;
    _userApiClient = apiModel.api.user;
    _authUserApiClient = apiModel.api.authUser;

    _loadFriendsAsResults();
  }

  @override
  void dispose() {
    super.dispose();
    _searchController.dispose();
  }

  void _loadFriendsAsResults() {
    _authUserApiClient.friends().then((items) => setState(() =>
      _usersResults = items.toList()
    ));
  }

  void _searchItems(String value) {
    if (value.isEmpty) {
      _clearItems();
      return;
    }
    _userApiClient.search(_searchController.text).then((items) => setState(() =>
      _usersResults = items.toList()
    ));
    _eventApiClient.search(_searchController.text).then((items) => setState(() =>
      _eventResults = items.toList()
    ));

    _eventApiClient.toView(search: _searchController.text).then((items) => setState(() =>
      _eventViewersResults = items.toList()
    ));
  }

  void _clearItems() {
    _loadFriendsAsResults();

    setState(() {
      _eventViewersResults = [];
      _eventResults = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        forceMaterialTransparency: true,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0.0,
        title: _buildMessageInput(),
        leading: null,
        actions: [
          IconButton(
              icon: const Icon(Icons.arrow_forward_rounded),
              onPressed: widget.goRight),
        ],
      ),
      body: Column(
          children: [
            _buildFilters(),
            Expanded(child: _buildResults()),
          ],
        ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey, width: 0.5),
        borderRadius: const BorderRadius.all(Radius.circular(11)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: _searchItems,
              onSubmitted: (_) => {},
              style: const TextStyle(color: Colors.white70, fontSize: 17),
              decoration: const InputDecoration(
                fillColor: Colors.transparent,
                hintText: "What are you looking for?",
                filled: true,
                hintStyle: TextStyle(
                    color: Colors.grey,
                    fontSize: 15,
                    fontWeight: FontWeight.w400),
                border: InputBorder.none,
              ),
            ),
          ),
          IconButton(
            onPressed: () => {},
            icon: const Icon(Symbols.search),
            color: Colors.white,
          )
        ],
      ),
    );
  }

  Widget _buildFilters() {
    const borderSide = BorderSide(color: Colors.grey, width: 0.5);
    const activeBorderSide = BorderSide(color: Colors.white, width: 1);

    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          GestureDetector(
              onTap: () => setState(() => _searchOption = SearchOption.users),
              child: Chip(
                  backgroundColor: Colors.black,
                  label: const Text("Users"),
                  side: _searchOption == SearchOption.users ? activeBorderSide : borderSide
              )
          ),

          Padding(
            padding: const EdgeInsets.only(left: 7),
            child: GestureDetector(
                onTap: () => setState(() => _searchOption = SearchOption.events),
                child: Chip(
                    backgroundColor: Colors.black,
                    label: const Text("Events"),
                    side: _searchOption == SearchOption.events ? activeBorderSide : borderSide
                )
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(left: 7),
            child: GestureDetector(
                onTap: () => setState(() => _searchOption = SearchOption.flashbacks),
                child: Chip(
                    backgroundColor: Colors.black,
                    label: const Text("Flashbacks"),
                    side: _searchOption == SearchOption.flashbacks ? activeBorderSide : borderSide
                )
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResults() {
    switch (_searchOption) {
      case (SearchOption.users):
        return _buildUserResults();
      case (SearchOption.events):
        return _buildEventResults();
      case (SearchOption.flashbacks):
        return _buildEventViewerResults();
    }
  }

  Widget _buildUserResults() {
    return Padding(
      padding: const EdgeInsets.only(left: 16, top: 5, right: 16),
      child: ListView.builder(
         itemCount: _usersResults.length,
          itemBuilder: (context, index) {
            final user = _usersResults[index];
            return UserContextualCard(
                user: user, onTap: () => context.push("/user/${user.id}/"));
            }
          ),
    );
  }

  Widget _buildEventResults() {
    return ListView.builder(
        itemCount: _eventResults.length,
        itemBuilder: (context, index) =>
            EventContainer(event: _eventResults[index])
    );
  }

  Widget _buildEventViewerResults() {
    return Padding(
      padding: const EdgeInsets.only(left: 14, right: 14),
      child: ListView.builder(
          itemCount: _eventViewersResults.length,
          itemBuilder: (context, index) =>
              EventViewerCard(
                  eventViewer: _eventViewersResults[index],
                  mediaSourceServer: _eventApiClient.apiBaseUrl
              )
      ),
    );
  }
}

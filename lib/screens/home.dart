import "package:flashbacks/providers/api.dart";
import "package:flashbacks/services/api/client.dart";
import "package:flashbacks/utils/permissions.dart";
import "package:flashbacks/utils/widget.dart";
import "package:flashbacks/widgets/event/items.dart";
import "package:flashbacks/widgets/event/viewer.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import 'package:flashbacks/models/event.dart';
import "package:material_symbols_icons/material_symbols_icons.dart";


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late ApiClient _apiClient;
  late Future<Iterable<Event>> _events;

  @override
  void initState() {
    super.initState();
    _apiClient = ApiModel.fromContext(context).api;
    _events = _apiClient.event.all();
  }

  Future _handleRefresh() async {
    setState(() =>
      _events = _apiClient.event.all()
    );
  }

  Widget _buildUpcomingEventSection() {
    return Column(
      children: [
        buildSectionHeader("My events", [
          IconButton(
              icon: const Icon(Symbols.arrow_forward),
              onPressed: () => context.go("/event/list/"))
        ]),
        getFutureBuilder<Iterable<Event>>(
            _events, (data) =>
            EventCardRow(
                events: data.where((item) => item.status != EventStatus.closed).toList(),
            )
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return IsAuthenticated(
      child: Scaffold(
          appBar: AppBar(
            forceMaterialTransparency: true,
            surfaceTintColor: Colors.transparent,
            scrolledUnderElevation: 0.0,
            title: const Text("Flashbacks", style: TextStyle(fontSize: 30)),
            actions: [
              IconButton(icon: const Icon(Icons.search), onPressed: () => context.go("/user/search")),
              IconButton(icon: const Icon(Icons.person), onPressed: () => ApiModel.fromContext(context).logout()),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: () => _handleRefresh(),
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _buildUpcomingEventSection(),
                  EventViewerCardCollection(),
                ],
              ),
            ),
          )),
    );
  }
}

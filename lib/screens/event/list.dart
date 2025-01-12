import 'package:flashbacks/models/event.dart';
import 'package:flashbacks/providers/api.dart';
import 'package:flashbacks/services/api/event.dart';
import 'package:flashbacks/utils/widget.dart';
import 'package:flashbacks/widgets/event/items.dart';
import 'package:flashbacks/widgets/placeholder.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';


class EventListScreen extends StatefulWidget {
  const EventListScreen({super.key});

  @override
  State<EventListScreen> createState() => _State();
}

class _State extends State<EventListScreen> with TickerProviderStateMixin {
  late EventApiClient _eventApiClient;
  late Future<Iterable<Event>> _events;
  EventStatus _filterStatus = EventStatus.opened;

  @override
  void initState() {
    super.initState();

    _eventApiClient = ApiModel.fromContext(context).api.event;
    _loadEvents();
  }

  void _switchFilterStatus() {
    final status = _filterStatus == EventStatus.opened ? EventStatus.closed : EventStatus.opened;
    setState(() => _filterStatus = status);
    _loadEvents();
  }

  void _loadEvents() {
    _events = _eventApiClient.filter({"status": _filterStatus.index.toString()});
  }
  
  void _handleTap(Event event) {
    context.go("event/${event.id}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          forceMaterialTransparency: true,
          surfaceTintColor: Colors.transparent,
          scrolledUnderElevation: 0.0,
          title: const Text("My events", style: TextStyle(fontSize: 25)),
          leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.go("/home")),
          actions: [
            IconButton(onPressed: () => context.go("/event/create"), icon: const Icon(Symbols.qr_code_scanner), color: Colors.grey),
            IconButton(onPressed: () => context.go("/event/create"), icon: const Icon(Icons.add), color: Colors.grey),
          ],
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Padding(
          padding: const EdgeInsets.only(left: 12, right: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildEventFilterButton(),
              getFutureBuilder(
                  _events, (events) {
                      if (events.isEmpty) return const Padding(
                        padding: EdgeInsets.only(top: 100),
                        child: NoEventsPlaceHolder(),
                      );
                      return EventColumn(collection: events.toList(), onItemTap: _handleTap);
                    },
                ),
            ],
          ),
        )),
    );
  }

  Widget _buildEventFilterButton() {
    final mode = _filterStatus == EventStatus.opened ? "Closed" : "Opened";

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: _switchFilterStatus,
          child: Text("$mode events",
              style: const TextStyle(fontSize: 15, color: Colors.grey)),
        ),
      ],
    );
  }
}
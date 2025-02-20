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
  final Function() goLeft;

  const EventListScreen({super.key, required this.goLeft});

  @override
  State<EventListScreen> createState() => _State();
}

class _State extends State<EventListScreen> with TickerProviderStateMixin {
  late EventApiClient _eventApiClient;
  
  late Future<Iterable<Event>> _openedEvents;
  late Future<Iterable<Event>> _closedEvents;
  EventStatus _filterStatus = EventStatus.opened;
  
  final _pageController = PageController();
  
  @override
  void initState() {
    super.initState();

    _eventApiClient = ApiModel.fromContext(context).api.event;
    _loadEvents();
  }

  void _switchFilterStatus() {
    final status = _filterStatus == EventStatus.opened
        ? EventStatus.closed
        : EventStatus.opened;
    setState(() => _filterStatus = status);
    _pageController.animateToPage(
        _filterStatus == EventStatus.opened ? 0 : 1,
        duration: const Duration(milliseconds: 475),
        curve: Curves.easeInOutQuart
    );
  }

  void _loadEvents() {
    _openedEvents =
        _eventApiClient.filter({"status": EventStatus.opened.index.toString()});
    _closedEvents =
        _eventApiClient.filter({"status": EventStatus.closed.index.toString()});
  }

  void _handleTap(Event event) {
    context.push("/event/${event.id}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        forceMaterialTransparency: true,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0.0,
        title: const Text("My events", style: TextStyle(fontSize: 25)),
        leading: IconButton(
            icon: const Icon(Icons.arrow_back), onPressed: widget.goLeft),
        actions: [
          IconButton(
              onPressed: () => context.push("/event/create"),
              icon: const Icon(Symbols.qr_code_scanner),
              color: Colors.grey),
          IconButton(
              onPressed: () => context.push("/event/create"),
              icon: const Icon(Icons.add),
              color: Colors.grey),
        ],
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _buildEventFilterButton(),

            if (_filterStatus == EventStatus.opened)
              _buildOpenedEventsPage(),
            if (_filterStatus == EventStatus.closed)
              _buildClosedEventsPage(),
          ],
        ),
      )
    );
  }

  Widget _buildEventFilterButton() {
    final mode = _filterStatus == EventStatus.opened ? "closed" : "opened";

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: _switchFilterStatus,
          child: Text("View $mode events ",
              style: const TextStyle(fontSize: 15, color: Colors.grey)),
        ),
      ],
    );
  }

  Widget _buildOpenedEventsPage() {
    return getFutureBuilder(
      _openedEvents,
      (events) {
        if (events.isEmpty)
          return NoEventsPlaceHolder(mode: NoEventPlaceHolderMode.future);
        return EventColumn(collection: events.toList(), onItemTap: _handleTap);
      },
    );
  }

  Widget _buildClosedEventsPage() {
    return getFutureBuilder(
      _closedEvents,
          (events) {
        if (events.isEmpty)
          return NoEventsPlaceHolder(mode: NoEventPlaceHolderMode.past);
        return EventColumn(collection: events.toList(), onItemTap: _handleTap);
      },
    );
  }
}

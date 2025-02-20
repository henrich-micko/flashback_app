import 'package:flashbacks/providers/api.dart';
import 'package:flashbacks/services/api/event.dart';
import 'package:flashbacks/var.dart';
import 'package:flashbacks/widgets/event/options.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';


class EventOptionsScreen extends StatefulWidget {
  final int eventPk;
  const EventOptionsScreen({super.key, required this.eventPk});

  @override
  State<EventOptionsScreen> createState() => _EventOptionsScreenState();
}

class _EventOptionsScreenState extends State<EventOptionsScreen> {
  late final EventApiDetailClient _eventApiClient;

  @override
  void initState() {
    super.initState();

    _eventApiClient = ApiModel.fromContext(context).api.event.detail(widget.eventPk);
  }

  void _handleCloseEvent() {
    _eventApiClient.close().then((_) => context.pop());
  }

  void _handleDeleteEvent() {
    _eventApiClient.delete().then((_) => context.push("/"));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        forceMaterialTransparency: true,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0.0,
        title: const Text("Options"),
        leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop()),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(left: 5, top: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(bottom: 5, left: 10),
                child: Text("Host actions", style: TextStyle(fontSize: 20, color: Colors.grey)),
              ),

              OptionGroup(children: [
                OptionGroupItem(
                    label: "Settings",
                    onTap: () => context.push("/event/${widget.eventPk}/settings/"),
                    icon: Icons.arrow_forward,
                ),
                OptionGroupItem(
                  label: "Members",
                  onTap: () => context.push("/event/${widget.eventPk}/members/"),
                  icon: Icons.arrow_forward,
                ),
                OptionGroupItem(
                  label: "Posters",
                  onTap: () => context.push("/event/${widget.eventPk}/posters/"),
                  icon: Icons.arrow_forward,
                )
              ]),

              const Padding(
                padding: EdgeInsets.only(top: 20, bottom: 5, left: 10),
                child: Text("Danger zone", style: TextStyle(fontSize: 20, color: Colors.grey)),
              ),

              OptionGroup(isDanger: true, children: [
                OptionGroupItem(
                    label: "Close event early",
                    onTap: _handleCloseEvent,
                    icon: Icons.close,
                ),
                OptionGroupItem(
                  label: "Delete event",
                  onTap: _showDeleteEventDialog,
                  icon: Symbols.delete,
                )
              ]),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteEventDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: scaffoldBackgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(11),
          ),
          title: const Text("Confirm Action"),
          content: const Text("Do you really want to delete this event and all the data?"),
          actions: [
            TextButton(
              onPressed: () {
                context.pop();
                _handleDeleteEvent();
              },
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

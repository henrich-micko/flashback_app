import 'dart:async';
import 'package:flashbacks/models/event.dart';
import 'package:flashbacks/models/user.dart';
import 'package:flashbacks/providers/api.dart';
import 'package:flashbacks/services/api_client.dart';
import 'package:flashbacks/utils/time.dart';
import 'package:flashbacks/utils/widget.dart';
import 'package:flashbacks/widgets/emoji.dart';
import 'package:flashbacks/widgets/event.dart';
import 'package:flashbacks/widgets/general.dart';
import 'package:flashbacks/widgets/user.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

class EventDetailScreen extends StatefulWidget {
  final int eventId;

  EventDetailScreen({super.key, required this.eventId});

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  late Future<ApiClient> futureApiClient;
  late Future<Event> futureEvent;
  late Future<Iterable<EventMember>> futureEventMembers;
  late BasicUser me;

  @override
  void initState() {
    super.initState();
    futureApiClient = ApiModel.fromContext(context).api;
    futureEvent = futureApiClient.then((api) => api.event.get(widget.eventId));
    futureEventMembers = futureApiClient.then((api) => api.event.member.all(widget.eventId));
  }

  void refreshMembers() {
    setState(() {
      futureEventMembers = futureApiClient.then((api) => api.event.member.all(widget.eventId));
    });
  }

  void handleDelete() {
    futureApiClient.then((api) => api.event.delete(widget.eventId));
    context.go("/home");
  }

  void handleClose() {
    futureApiClient.then((api) => api.event.close(widget.eventId));
    Navigator.pop(context);
  }

  void handleDeleteUserSheetAction(int userId) {
    futureApiClient.then((api) => api.event.member.delete(widget.eventId, userId).then(
        (_) => refreshMembers()
    ));

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.go("/home")),
          actions: [
            IconButton(onPressed: showOptionsBottomSheet, icon: const Icon(Icons.more_vert))
          ],
        ),
        body: Column(
          children: [
            buildHeader(),
            buildMembers(),
          ],
        ));
  }

  Widget buildHeader() {
    return getFutureBuilder(
        futureEvent,
        (event) => Padding(
              padding: const EdgeInsets.only(
                  left: 20, right: 20, top: 20, bottom: 20),
              child: SizedBox(
                  height: 100,
                  child: Row(
                    children: [
                      EmojiBox(emoji: event.emoji, width: 100, height: 100),
                      const Gap(30),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(event.title,
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 30)),
                          Text(
                              "${dateFormat.format(event.startAt)} -> ${dateFormat.format(event.endAt)}",
                              style: const TextStyle(
                                  color: Colors.white60, fontSize: 16)),
                          const Gap(2.5),
                          const Text("You are host of this event.",
                              style: TextStyle(
                                  color: Colors.white60, fontSize: 15)),
                        ],
                      ),
                    ],
                  )),
            ));
  }

  Widget buildMembers() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildSectionHeader("Event members", [
          IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: showEditMembersBottomSheet)
        ]),
        Padding(
          padding:
              const EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 20),
          child: getFutureBuilder<Iterable<EventMember>>(
            futureEventMembers,
            (members) => UserCollectionRow<BasicUser>(
                onItemTap: (item) => showUserBottomSheet(item.id),
                collection: members.map((member) => member.user).where((user) => user.id != ApiModel.fromContext(context).me!.id)
            ),
          ),
        ),
      ],
    );
  }

  void showUserBottomSheet(int userId) {
    double width = MediaQuery.of(context).size.width;

    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) => SizedBox(
              height: 220,
              width: width,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Wrap(
                  alignment: WrapAlignment.center,
                  direction: Axis.vertical,
                  spacing: 30,
                  children: [
                    const SheetAction(
                        title: "Open profile", icon: Symbols.open_in_new),
                    const SheetAction(title: "Share", icon: Symbols.share),
                    SheetAction(
                        title: "Delete",
                        icon: Symbols.delete,
                        onTap: () => handleDeleteUserSheetAction(userId)
                    ),
                  ],
                ),
              ),
            ));
  }

  void showEditMembersBottomSheet() {
    double width = MediaQuery.of(context).size.width;

    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) => SizedBox(
            height: 500,
            width: width,
            child: EditEventMembers(eventId: widget.eventId, onChange: refreshMembers),
        )
    );
  }

  void showOptionsBottomSheet() {
    double width = MediaQuery.of(context).size.width;

    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) => SizedBox(
          height: 200,
          width: width,
          child: Padding(
        padding: EdgeInsets.all(20),
      child: Wrap(
        alignment: WrapAlignment.center,
        direction: Axis.vertical,
        spacing: 30,
        children: [
          SheetAction(title: "Share", icon: Symbols.share),
          SheetAction(title: "Close early", icon: Symbols.close, onTap: handleClose),
          SheetAction(title: "Delete", icon: Symbols.delete, onTap: handleDelete),
        ],
      ),
    ),
        )
    );
  }
}

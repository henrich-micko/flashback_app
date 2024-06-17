import "package:flashbacks/models/event.dart";
import "package:flashbacks/models/user.dart";
import "package:flashbacks/providers/api.dart";
import "package:flashbacks/services/api_client.dart";
import "package:flashbacks/utils/time.dart";
import "package:flashbacks/utils/widget.dart";
import "package:flashbacks/widgets/user.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";

class EventCard extends StatelessWidget {
  final double size = 100;
  final double lightSize = 70;

  final Event event;
  final Function()? onTap;
  final bool light;

  const EventCard({
    super.key,
    required this.event,
    this.onTap,
    this.light = false
  });

  @override
  Widget build(BuildContext context) {
    final double cardWidth = MediaQuery.of(context).size.width;

    return GestureDetector(
      onTap: () {
        if (onTap != null) onTap!();
        else context.goNamed("event-detail", pathParameters: {"eventId": event.id.toString()});
      },
      child: Container(
        width: cardWidth,
        height: light ? lightSize : size,
        decoration: BoxDecoration(
            color: Colors.white10,
            borderRadius: BorderRadius.circular(10),
            border: event.status == EventStatus.activated ? Border.all(
              width: 2,
              color: Colors.red,
            ) : null,
        ),
        child: Row(
          children: <Widget>[
            buildEventProfile(),
            buildEventInfo(),
          ],
        ),
      ),
    );
  }

  Widget buildEventProfile() {
    return Container(
      decoration: BoxDecoration(
          border: Border.all(
            width: 1,
            color: Colors.black12,
          ),
          color: Colors.black26,
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(10), bottomLeft: Radius.circular(10))),
      width: light ? lightSize : size,
      height: light ? lightSize : size,
      child: Center(
          child: Text(event.emoji.code, style: TextStyle(fontSize: light ? lightSize/2 : size/2))),
    );
  }

  Widget buildEventInfo() {
    return Padding(
      padding: const EdgeInsets.only(top: 6.0, left: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(event.title, style: const TextStyle(color: Colors.white, fontSize: 22.0)),
          Text(event.quickDetail, style: const TextStyle(color: Colors.white38, fontSize: 12.0)),
          !light ? Text(dateFormat.format(event.startAt), style: const TextStyle(color: Colors.white38, fontSize: 12.0)) : Container(),
        ],
      ),
    );
  }
}

class EventCardColumn extends StatelessWidget {
  final Iterable<Event> events;
  final Function(Event event)? onTap;

  const EventCardColumn({super.key, required this.events, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Center(
        child: Column(
          children: events.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 15),
            child: EventCard(event: item, onTap: () {
              if (onTap != null) onTap!(item);
            }),
          )).toList(),
        ),
      ),
    );
  }
}

class EditEventMembers extends StatefulWidget {
  final int eventId;
  final Function()? onChange;

  EditEventMembers({super.key, required this.eventId, this.onChange});

  @override
  State<EditEventMembers> createState() => _EditEventMembersState();
}

class _EditEventMembersState extends State<EditEventMembers> {
  late Future<Iterable<PossibleEventMember>> futurePossibleMembers;
  late Future<ApiClient> futureApiClient;

  @override
  void initState() {
    super.initState();
    futureApiClient = ApiModel.fromContext(context).api;
    futurePossibleMembers = futureApiClient.then((api) => api.event.member.possible(widget.eventId));
  }

  void handleUserStatusChange(BasicUser user, bool status) {
    Future response = futureApiClient.then((api) =>
      status ? api.event.member.add(widget.eventId, user.id)
             : api.event.member.delete(widget.eventId, user.id)
    );
    if (widget.onChange != null) response.then((value) => widget.onChange!());
  }

  @override
  Widget build(BuildContext context) {
    return getFutureBuilder(futurePossibleMembers, (members) =>
        SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              children: members.map((pm) =>
                  Column(children: [
                    UserAsSelector(
                        user: pm.user,
                        defaultValue: pm.isMember,
                        onChanged: (value) => handleUserStatusChange(pm.user, value)
                    ),
                    const Divider()
                  ]),
              ).toList(),
            ),
          ),
        )
    );
  }
}

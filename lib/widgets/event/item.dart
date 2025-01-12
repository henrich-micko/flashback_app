import "package:flashbacks/models/event.dart";
import "package:flashbacks/utils/time.dart";
import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:go_router/go_router.dart";
import "package:material_symbols_icons/material_symbols_icons.dart";


class EventContainer extends StatelessWidget {
  final Event event;
  final Function()? onTap;
  final bool? light;

  const EventContainer(
      {super.key, required this.event, this.onTap, this.light});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width * 0.95;

    return SizedBox(
      width: width,
      child: GestureDetector(
        onTap: () => context.go("/event/${event.id}/"),
        child: Padding(
          padding: const EdgeInsets.only(right: 15),
          child: Row(
            children: [
              Expanded(flex: 1, child: _buildEmojiSection()),
              Expanded(flex: 2, child: _buildMiddleSection()),
              Expanded(flex: 1, child: _buildRightSection()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmojiSection() {
    return SizedBox(
      width: 100,
      child: Center(
          child: Text(event.emoji.code, style: const TextStyle(fontSize: 55))),
    );
  }

  // Event title and start at timing
  Widget _buildMiddleSection() {
    return Padding(
      padding: const EdgeInsets.only(left: 15, right: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(event.title,
              style: const TextStyle(color: Colors.white, fontSize: 22)),
          Text("${humanizeUpcomingDate(event.startAt)} at ${timeFormat.format(event.startAt)}",
            style: const TextStyle(color: Colors.grey, fontSize: 15)),
        ],
      ),
    );
  }

  // friends members and notifications
  Widget _buildRightSection() {
    return const SizedBox(
      width: 50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Icon(Symbols.notifications_active),
        ],
      ),
    );
  }
}


class EventCard extends StatelessWidget {
  final Event event;
  final Function()? onTap;
  final bool light;

  const EventCard(
      {super.key, required this.event, this.onTap, this.light = false});

  @override
  Widget build(BuildContext context) {
    return Card.outlined(
        color: Colors.transparent,
        child: EventContainer(event: event, onTap: onTap, light: light));
  }
}


class EventListTile extends StatelessWidget {
  final Event event;
  final Widget? leading;

  const EventListTile({super.key, required this.event, this.leading});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(event.title, style: const TextStyle(fontSize: 20)),
      subtitle: Text(event.quickDetail, style: const TextStyle(fontSize: 15)),
      leading: Text(event.emoji.code, style: const TextStyle(fontSize: 30)),
      trailing: const Icon(Icons.bar_chart),
    );
  }
}


class EventWithNews extends StatefulWidget {
  final Event event;
  const EventWithNews({super.key, required this.event});

  @override
  State<EventWithNews> createState() => _EventWithNewsState();
}

class _EventWithNewsState extends State<EventWithNews> {
  String _humanizeStartAt() {
    switch (widget.event.status) {
      case (EventStatus.opened): return humanizeUpcomingDate(widget.event.startAt);
      case (EventStatus.closed): return humanizePastDateTIme(widget.event.startAt, pre: "Closed");
      case (EventStatus.activated): return "Active!";
    }
  }


  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: MediaQuery.of(context).size.width,
        height: 80,
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildLeftSection(),
                // const NotificationChip(icon: Symbols.message, value: 4),
              ],
            ),

            const Divider()
          ],
        )
    );
  }

  // emoji with title and time
  Widget _buildLeftSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // emoji
        Text(widget.event.emoji.code, style: const TextStyle(fontSize: 45), textAlign: TextAlign.start),
        const Gap(10),
        // The other stuff
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Gap(5),
            Text(widget.event.title, style: const TextStyle(fontSize: 20), textAlign: TextAlign.start),
            Text(_humanizeStartAt(), style: const TextStyle(color: Colors.grey)),
        ]),
      ],
    );
  }
}
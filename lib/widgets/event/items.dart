import "package:flashbacks/models/event.dart";
import "package:flashbacks/widgets/event/item.dart";
import "package:flashbacks/widgets/event/holder.dart";
import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:go_router/go_router.dart";
import "package:smooth_page_indicator/smooth_page_indicator.dart";

class EventColumn extends StatelessWidget {
  final List<Event> collection;
  final Function(Event item)? onItemTap;

  const EventColumn({super.key, required this.collection, this.onItemTap});

  void _handleGoToClosed() {}

  @override
  Widget build(BuildContext context) {
    return Column(
        children: collection
            .map((item) => Column(
                  children: [
                    EventContainer(event: item),
                    const Divider(),
                  ],
                ))
            .toList());
  }
}

class EventCardRow extends StatelessWidget {
  final List<Event> events;
  final controller = PageController(viewportFraction: 1, keepPage: true);

  EventCardRow({super.key, required this.events});

  @override
  Widget build(BuildContext context) {
    final eventsWidgets = events.map((item) => EventCard(event: item)).toList();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          SizedBox(
            height: 100,
            width: MediaQuery.of(context).size.width * 0.95,
            child: eventsWidgets.length > 1
                ? PageView.builder(
                    controller: controller,
                    itemBuilder: (_, index) {
                      return eventsWidgets[index % eventsWidgets.length];
                    },
                  )
                : eventsWidgets.length == 1
                    ? eventsWidgets.first
                    : NoEventHolder(onTap: () => context.go("/event/create")),
          ),
          const Gap(10),
          eventsWidgets.length > 1
              ? SmoothPageIndicator(
                  controller: controller,
                  count: eventsWidgets.length,
                  effect: const ScrollingDotsEffect(
                      dotWidth: 6,
                      dotHeight: 6,
                      dotColor: Colors.white60,
                      activeDotColor: Colors.white),
                )
              : Container(),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flashbacks/widgets/event/members.dart';
import 'package:go_router/go_router.dart';


class EditEventMembersScreen extends StatelessWidget {
  final int eventId;
  const EditEventMembersScreen({super.key, required this.eventId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        forceMaterialTransparency: true,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0.0,
        title: const Text("Members"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: EventMemberManager(eventId: eventId),
    );
  }
}
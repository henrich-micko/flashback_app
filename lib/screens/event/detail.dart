import 'dart:async';
import 'package:flashbacks/models/chat.dart';
import 'package:flashbacks/models/event.dart';
import 'package:flashbacks/models/user.dart';
import 'package:flashbacks/providers/api.dart';
import 'package:flashbacks/services/api/event.dart';
import 'package:flashbacks/utils/time.dart';
import 'package:flashbacks/utils/widget.dart';
import 'package:flashbacks/widgets/emoji.dart';
import 'package:flashbacks/widgets/event/chat/message.dart';
import 'package:flashbacks/widgets/event/members.dart';
import 'package:flashbacks/widgets/event/votes/alert.dart';
import 'package:flashbacks/widgets/general.dart';
import 'package:flashbacks/widgets/user.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:pagination_view/pagination_view.dart';


class EventDetailScreen extends StatefulWidget {
  final int eventId;

  const EventDetailScreen({super.key, required this.eventId});

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;

  late EventApiDetailClient _eventApiClient;
  late Future<Event> _event;
  late Future<Iterable<EventMember>> _eventMembers;
  late List<List<Message>> _messages;
  String? _nextMessageSource;

  late User me;

  @override
  void initState() {
    super.initState();

    _eventApiClient = ApiModel.fromContext(context).api.event.detail(widget.eventId);
    _event = _eventApiClient.get();
    _eventMembers = _eventApiClient.member.all();
    _messages = [];
    _loadMessages();

    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _loadMessages() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1)); // TODO: remove
    _eventApiClient.chat.all(path: _nextMessageSource).then((messages) {
      setState(() {
        _messages.addAll(_processMessages(messages.results));
        _nextMessageSource = messages.next;
        _isLoading = false;
      });
    });
  }

  void _scrollListener() async {
    if (!context.mounted) return;

    // Check if the scroll position is at the Bottom
    Logger().i(_scrollController.position.minScrollExtent);
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      Logger().i("pressed!");
      _loadMessages();
    }
  }

  List<List<Message>> _processMessages(List<Message> messages) {
    List<List<Message>> output = [];

    int? currUserId;

    for (Message message in messages.reversed) { // TODO handle reversed on backend
      if (currUserId == null) {
        output.add([message]);
        currUserId = message.user?.id; // TODO check the ? behavior
        continue;
      }

      if (message.user != null && message.user!.id == currUserId) {
        output[output.length-1].add(message);
        currUserId = message.user!.id;
        continue;
      }

      output.add([message]);
    }
    return output.reversed.toList();
  }
  
  void _refreshMembers() {
    setState(() => _eventMembers = _eventApiClient.member.all());
  }

  void _handleDelete() {
    _eventApiClient.delete();
    context.go("/home");
  }

  void _handleClose() {
    _eventApiClient.close();
    Navigator.pop(context);
  }

  void _handleDeleteUserSheetAction(int userId) {
    _eventApiClient.member.delete(userId).then((_) => _refreshMembers());
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          forceMaterialTransparency: true,
          surfaceTintColor: Colors.transparent,
          scrolledUnderElevation: 0.0,
          title: getFutureBuilder(_event, (event) => Text("${event.emoji.code} ${event.title}")),
          leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.go("/home")),
          actions: [
            IconButton(onPressed: _showOptionsBottomSheet, icon: const Icon(Icons.more_vert))
          ],
        ),
        body: SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Scrollbar(
              child: ListView.builder(
                reverse: true,
                controller: _scrollController,
                itemCount: _messages.length + (_isLoading ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index < _messages.length)
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: MessageBubble(messages: _messages[index]),
                    );
                  return const Center(
                    child:
                    Padding(
                      padding: EdgeInsets.only(top: 10, bottom: 25),
                      child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator()),
                    ),
                  );
                }
              ),
            ),
          ),
        )
    );
  }

  void _showUserBottomSheet(int userId) {
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
                        onTap: () => _handleDeleteUserSheetAction(userId)
                    ),
                  ],
                ),
              ),
            ));
  }

  void _showEditMembersBottomSheet() {
    double width = MediaQuery.of(context).size.width;

    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) => SizedBox(
            height: 500,
            width: width,
            child: EditEventMembers(eventId: widget.eventId, onChange: _refreshMembers),
        )
    );
  }

  void _showOptionsBottomSheet() {
    double width = MediaQuery.of(context).size.width;

    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) => SizedBox(
          height: 200,
          width: width,
          child: Padding(
        padding: const EdgeInsets.all(20),
      child: Wrap(
        alignment: WrapAlignment.center,
        direction: Axis.vertical,
        spacing: 30,
        children: [
          const SheetAction(title: "Share", icon: Symbols.share),
          SheetAction(title: "Close early", icon: Symbols.close, onTap: _handleClose),
          SheetAction(title: "Delete", icon: Symbols.delete, onTap: _handleDelete),
        ],
      ),
    ),
        )
    );
  }
}

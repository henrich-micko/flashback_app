import 'package:flashbacks/models/event.dart';
import 'package:flashbacks/providers/api.dart';
import 'package:flashbacks/services/api/event.dart';
import 'package:flashbacks/utils/api/client.dart';
import 'package:flashbacks/utils/widget.dart';
import 'package:flashbacks/widgets/event/fields/datetime.dart';
import 'package:flashbacks/widgets/event/fields/emoji.dart';
import 'package:flashbacks/widgets/event/fields/mode.dart';
import 'package:flashbacks/widgets/event/fields/title.dart';
import 'package:flutter/material.dart';
import 'package:flutter_emoji/flutter_emoji.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';

class EventSettingsScreen extends StatefulWidget {
  final int eventId;

  const EventSettingsScreen({super.key, required this.eventId});

  @override
  State<EventSettingsScreen> createState() => _EventSettingsScreenState();
}

class _EventSettingsScreenState extends State<EventSettingsScreen> {
  late EventApiDetailClient _eventApiClient;
  late EventMemberApiClient _eventMemberApiClient;

  late Future<Event> _event;
  late Future<EventMember> _eventAuthUserMember;

  String _eventTitle = "";
  Emoji _eventEmoji = EmojiParser().getName(Event.defaultEmojiCode);
  DateTime? _eventStartAt;
  DateTime? _eventEndAt;
  EventViewersMode _eventViewersMode = EventViewersMode.allFriends;
  double _eventMFL = 0.30;

  @override
  void initState() {
    super.initState();

    final apiModel = ApiModel.fromContext(context);

    _eventApiClient = apiModel.api.event.detail(widget.eventId);
    _eventMemberApiClient = _eventApiClient.member;

    _event = _eventApiClient.get();
    _event.then(_onEventLoad);
    _eventAuthUserMember = _eventMemberApiClient.get(apiModel.currUser!.id);
    _eventAuthUserMember.then((member) => Logger().i(member));
  }

  void _onEventLoad(Event event) {
    setState(() {
      _eventTitle = event.title;
      _eventEmoji = event.emoji;
      _eventStartAt = event.startAt;
      _eventEndAt = event.endAt;
      _eventViewersMode = event.eventViewersMode;
      _eventMFL =
          event.mutualFriendsLimit == null ? 0.30 : event.mutualFriendsLimit!;
    });
  }

  JsonData _settingsToJson() {
    JsonData data = {
      "title": _eventTitle,
      "emoji": _eventEmoji.name,
      "start_at": _eventStartAt.toString(),
      "end_at": _eventEndAt.toString(),
      "mutual_friends_limit": _eventMFL,
    };

    if (_eventViewersMode == EventViewersMode.mutualFriends)
      data["mutual_friends_limit"] = _eventMFL;
    return data;
  }

  void _handleSubmit() {
    _eventApiClient
        .patch(_settingsToJson())
        .then((_) => context.pop());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        forceMaterialTransparency: true,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0.0,
        title: getFutureBuilder(_event, (event) => const Text("Settings")),
        leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop()),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 5),
            child: TextButton(
                onPressed: _handleSubmit,
                child: const Text(
                  "Save",
                  style: TextStyle(fontSize: 15, color: Colors.grey),
                )),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(left: 15, right: 15, top: 5),
          child: Column(
            children: [
              getFutureBuilder(_eventAuthUserMember, (member) {
                Logger().i(member.role);
                if (member.role == EventMemberRole.host)
                  return _buildHostSettings();
                return Container();
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHostSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TitleFieldCard(
            defaultTitle: _eventTitle,
            onChange: (value) => setState(() => _eventTitle = value)),
        const Gap(10),
        EmojiCardField(
            defaultEmoji: _eventEmoji,
            onChange: (value) => setState(() => _eventEmoji = value)),
        const Gap(10),
        DateTimeFieldCard(
            initStartAt: _eventStartAt,
            initEndAt: _eventEndAt,
            onChange: (startAt, endAt) {
              setState(() {
                _eventStartAt = startAt;
                _eventEndAt = endAt;
              });
            }),
        const Gap(10),
        EventViewersModeFieldCard(
            eventViewersMode: _eventViewersMode,
            mutualFriendsLimit: _eventMFL,
            onOptionChange: (value) =>
                setState(() => _eventViewersMode = value),
            onMFLChange: (value) => setState(() => _eventMFL = value)),
      ],
    );
  }
}

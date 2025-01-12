import "package:flashbacks/models/event.dart";
import "package:flashbacks/providers/api.dart";
import "package:flashbacks/services/api/event.dart";
import "package:flashbacks/utils/api/client.dart";
import "package:flashbacks/utils/errors.dart";
import "package:flashbacks/widgets/event/fields/datetime.dart";
import "package:flashbacks/widgets/event/fields/emoji.dart";
import "package:flashbacks/widgets/event/fields/mode.dart";
import "package:flashbacks/widgets/event/fields/title.dart";
import "package:flashbacks/widgets/event/members.dart";
import "package:flutter/material.dart";
import "package:flutter_emoji/flutter_emoji.dart";
import "package:gap/gap.dart";
import "package:go_router/go_router.dart";
import "package:material_symbols_icons/material_symbols_icons.dart";
import "package:material_symbols_icons/symbols.dart";


class CreateEventScreen extends StatefulWidget {
  final _emojiParser = EmojiParser();

  CreateEventScreen({super.key});

  @override
  State<CreateEventScreen> createState() => _CreateEventScreen();
}

class _CreateEventScreen extends State<CreateEventScreen> {
  late Emoji _emoji;
  String? _title;
  DateTime? _startAt;
  DateTime? _endAt;
  late EventApiClient _eventApiClient;

  final FieldError _titleFieldError = FieldError();
  final FieldError _timeFieldError = FieldError();

  @override
  void initState() {
    super.initState();

    _emoji = widget._emojiParser.get(Event.defaultEmojiCode);
    _eventApiClient = ApiModel.fromContext(context).api.event;
    _startAt = DateTime.now().add(const Duration(minutes: 15));
    _endAt = _startAt!.add(const Duration(hours: 8));
  }

  void _handleSubmit() {
    if (_title == null || _title == "") {
      setState(() => _titleFieldError.isActive = true);
      return;
    }

    // start and end shouldnt be null cause thei are set at initState

    _eventApiClient
        .create(_emoji.name, _title!, _startAt!, _endAt!)
        .then((event) => context.go("/event/create/${event.id}/advanced-settings"))
        .catchError((error) => _handleError(error));
  }

  void _handleError(Map<String, dynamic> errorData) {
    if (!errorData.containsKey("timing"))
      return;
    setState(() =>
      _timeFieldError.errorMessage = cleanErrorMessage(
          errorData["timing"].toString()
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            forceMaterialTransparency: true,
            surfaceTintColor: Colors.transparent,
            scrolledUnderElevation: 0.0,
            centerTitle: true,
            title: const Text("Create new event",
                style: TextStyle(fontSize: 25, color: Colors.white)),
            leading: IconButton(
                icon: const Icon(Symbols.close),
                onPressed: () => context.go("/home")),
            actions: [
              IconButton(
                  icon: const Icon(Symbols.navigate_next),
                  onPressed: _handleSubmit),
            ]),


        body: SingleChildScrollView(
            child: Padding(
                padding: const EdgeInsets.only(right: 15, left: 15, top: 20),
                child: Column(
                  children: [
                    TitleFieldCard(onChange: (value) => setState(() {
                      _title = value;
                      if (_titleFieldError.isActive && value != "")
                        _titleFieldError.isActive = false;
                    }), fieldError: _titleFieldError),

                    const Gap(20),
                    EmojiCardField(defaultEmoji: _emoji, onChange: (emoji) => setState(() {
                      _emoji = emoji;
                    })),

                    const Gap(20),
                    DateTimeFieldCard(onChange: (startAt, endAt) => setState(() {
                      _startAt = startAt;
                      _endAt = endAt;
                    }), fieldError: _timeFieldError),
                  ],
                )
            )
        )
    );
  }
}


class CreateEventAdvancedSettings extends StatefulWidget {
  final int eventId;

  const CreateEventAdvancedSettings({super.key, required this.eventId});

  @override
  State<CreateEventAdvancedSettings> createState() => _CreateEventAdvancedSettingsState();
}

class _CreateEventAdvancedSettingsState extends State<CreateEventAdvancedSettings> {
  late EventApiDetailClient _eventApiClient;

  EventViewersMode _eventViewersMode = EventViewersMode.onlyMembers;
  double _mutualFriendsLimit = 0.30;

  @override
  void initState() {
    super.initState();
    _eventApiClient = ApiModel.fromContext(context).api.event.detail(widget.eventId);
  }

  void _handleSubmit() {
    JsonData patchData = {"viewers_mode": _eventViewersMode.index};
    if (_eventViewersMode == EventViewersMode.mutualFriends)
      patchData["mutual_friends_limit"] = _mutualFriendsLimit;
    _eventApiClient.patch(patchData).then((item) => context.go("/event/create/${widget.eventId}/edit-people/"));
  }

  void _handleCancel() {
    _eventApiClient.delete().then((_) => context.go("/home"));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            forceMaterialTransparency: true,
            surfaceTintColor: Colors.transparent,
            scrolledUnderElevation: 0.0,
            centerTitle: true,
            title: const Text("Create new event",
                style: TextStyle(fontSize: 25, color: Colors.white)),
            leading: IconButton(
                icon: const Icon(Symbols.close),
                onPressed: _handleCancel),
            actions: [
              IconButton(
                  icon: const Icon(Symbols.navigate_next),
                  onPressed: _handleSubmit),
            ]),

        body: SingleChildScrollView(
            child: Padding(
                padding: const EdgeInsets.only(right: 15, left: 15, top: 20),
                child: Column(
                  children: [
                    EventViewersModeFieldCard(
                      eventViewersMode: _eventViewersMode,
                      mutualFriendsLimit: _mutualFriendsLimit,
                      onMFLChange: (value) => setState(() => _mutualFriendsLimit = value),
                      onOptionChange: (value) => setState(() => _eventViewersMode = value),
                    ),
                  ],
                )
            )
        )
    );
  }
}


class CreateEventAddPeopleScreen extends StatefulWidget {
  final int eventPk;
  const CreateEventAddPeopleScreen({super.key, required this.eventPk});

  @override
  State<CreateEventAddPeopleScreen> createState() => _CreateEventAddPeopleScreenState();
}

class _CreateEventAddPeopleScreenState extends State<CreateEventAddPeopleScreen> {
  late EventApiDetailClient _eventApiClient;

  @override
  void initState() {
    super.initState();
    _eventApiClient = ApiModel.fromContext(context).api.event.detail(widget.eventPk);
  }

  void _handleCancel() {
    _eventApiClient.delete().then((_) => context.go("/home"));
  }

  void _handleSubmit() {
    context.go("/home");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            forceMaterialTransparency: true,
            surfaceTintColor: Colors.transparent,
            scrolledUnderElevation: 0.0,
            centerTitle: true,
            title: const Text("Create new event",
                style: TextStyle(fontSize: 25, color: Colors.white)),
            leading: IconButton(
                icon: const Icon(Symbols.close),
                onPressed: _handleCancel),
            actions: [
              IconButton(
                  icon: const Icon(Symbols.navigate_next),
                  onPressed: _handleSubmit),
            ]),

        body: SingleChildScrollView(
            child: Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(left: 15),
                      child: Text("Select event members", style: TextStyle(color: Colors.grey, fontSize: 18)),
                    ),
                    EditEventMembers(eventId: widget.eventPk),
                  ],
                )
            )
        )
    );
  }
}
import "package:flashbacks/models/event.dart";
import "package:flashbacks/models/user.dart";
import "package:flashbacks/providers/api.dart";
import "package:flashbacks/services/api_client.dart";
import "package:flashbacks/utils/widget.dart";
import "package:flashbacks/widgets/event.dart";
import "package:flashbacks/widgets/time.dart";
import "package:flashbacks/widgets/emoji.dart";
import "package:flashbacks/widgets/user.dart";
import "package:flutter/material.dart";
import "package:flutter_emoji/flutter_emoji.dart";
import "package:gap/gap.dart";
import "package:go_router/go_router.dart";


class CreateEventScreen extends StatefulWidget {
  final _emojiParser = EmojiParser();

  CreateEventScreen({super.key});

  @override
  State<CreateEventScreen> createState() => _CreateEventScreen();
}

class _CreateEventScreen extends State<CreateEventScreen> {
  late Emoji _emoji;
  final _titleController = TextEditingController();
  DateTime? _startAt;
  DateTime? _endAt;
  late Future<ApiClient> _futureApiClient;

  @override
  void initState() {
    super.initState();

    _emoji = widget._emojiParser.get(Event.defaultEmojiCode);
    _futureApiClient = ApiModel.fromContext(context).api;
  }

  void handleCreate() {
    if (_startAt == null || _endAt == null)
      return;

    _futureApiClient.then((api) =>
      api.event.create(_emoji.name, _titleController.text, _startAt!, _endAt!, [])
    ).then((event) => context.go("/event/${event.id}/edit-people"));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text("Create new event",
              style: TextStyle(fontSize: 25, color: Colors.white)),
          leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.go("/home")),
          actions: [
            TextButton(
                onPressed: handleCreate,
                child: const Text("Next", style: TextStyle(fontSize: 16, color: Colors.white60)))
          ]
        ),
        body: SingleChildScrollView(
            child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  children: [
                    const Gap(30),
                    EmojiField(
                        defaultEmoji: _emoji,
                        onChange: (Emoji value) =>
                            setState(() => _emoji = value)),
                    const Gap(30),
                    SizedBox(
                      height: 60,
                      child: TextField(
                        controller: _titleController,
                        onChanged: (String value) => setState(() {
                          _titleController.text = value;
                        }),
                        style: const TextStyle(color: Colors.white70),
                        decoration: InputDecoration(
                          fillColor: Colors.black12,
                          hintText: 'Title',
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const Gap(30),
                    DateTimeField(
                      defaultDate: _startAt,
                      onChange: (DateTime value) =>
                          setState(() =>
                            _startAt = value
                          ),
                      helper: "Starting at",
                    ),
                    const Gap(30),
                    DateTimeField(
                      defaultDate: _endAt,
                      onChange: (DateTime value) =>
                          setState(() => _endAt = value),
                      helper: "Ending at",
                    ),
                  ],
                ))));
  }
}

class AddPeopleToEventScreen extends StatefulWidget {
  final int eventId;

  const AddPeopleToEventScreen({super.key, required this.eventId});

  @override
  State<AddPeopleToEventScreen> createState() => _AddPeopleToEventScreen();
}

class _AddPeopleToEventScreen extends State<AddPeopleToEventScreen> {
  late Future<ApiClient> _futureApiClient;

  @override
  void initState() {
    super.initState();
    _futureApiClient = ApiModel.fromContext(context).api;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          forceMaterialTransparency: true,
          surfaceTintColor: Colors.transparent,
          scrolledUnderElevation: 0.0,
          centerTitle: true,
          title: const Text("Add your friends",
              style: TextStyle(fontSize: 25, color: Colors.white)),
          leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () =>
                  context.go("/event/create")),
          actions: [
            TextButton(
                onPressed: () => context.go("/home"),
                child: const Text("Create",
                    style: TextStyle(fontSize: 16, color: Colors.white24)))
          ],
        ),
        body: EditEventMembers(eventId: widget.eventId)
    );
  }
}
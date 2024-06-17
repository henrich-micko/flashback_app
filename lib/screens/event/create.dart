import "package:flashbacks/models/event.dart";
import "package:flashbacks/models/user.dart";
import "package:flashbacks/providers/api.dart";
import "package:flashbacks/services/api_client.dart";
import "package:flashbacks/utils/widget.dart";
import "package:flashbacks/widgets/time.dart";
import "package:flashbacks/widgets/emoji.dart";
import "package:flashbacks/widgets/user.dart";
import "package:flutter/material.dart";
import "package:flutter_emoji/flutter_emoji.dart";
import "package:gap/gap.dart";
import "package:go_router/go_router.dart";

class CreateEventData {
  Emoji? emoji;
  String? title;
  DateTime? startAt;
  DateTime? endAt;
  List<int> users = []; // id of users

  bool isValid() {
    return emoji != null && title != null && startAt != null && endAt != null;
  }
}

class CreateEventScreen extends StatefulWidget {
  final CreateEventData? createEventData;
  final emojiParser = EmojiParser();

  CreateEventScreen({super.key, this.createEventData});

  @override
  State<CreateEventScreen> createState() => _CreateEventScreen();
}

class _CreateEventScreen extends State<CreateEventScreen> {
  late CreateEventData createEventData;
  TextEditingController titleController = TextEditingController();

  @override
  void initState() {
    super.initState();

    createEventData = widget.createEventData ?? CreateEventData();
    createEventData.emoji ??= widget.emojiParser.get(Event.defaultEmojiCode);
    titleController.text = createEventData.title ?? "";
  }

  String? get eventTitle => createEventData.title;

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
          actions: createEventData.title != null &&
                  createEventData.startAt != null &&
                  createEventData.endAt != null
              ? [
                  TextButton(
                      onPressed: () => context.go("/event/create/people",
                          extra: createEventData),
                      child: const Text("Next",
                          style: TextStyle(fontSize: 16, color: Colors.white60)))
                ]
              : [],
        ),
        body: SingleChildScrollView(
            child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  children: [
                    const Gap(30),
                    EmojiField(
                        defaultEmoji: createEventData.emoji!,
                        onChange: (Emoji value) =>
                            setState(() => createEventData.emoji = value)),
                    const Gap(30),
                    SizedBox(
                      height: 60,
                      child: TextField(
                        controller: titleController,
                        onChanged: (String value) => setState(() {
                          titleController.text = value;
                          createEventData.title = value;
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
                      defaultDate: createEventData.startAt,
                      onChange: (DateTime value) =>
                          setState(() =>
                            createEventData.startAt = value
                          ),
                      helper: "Starting at",
                    ),
                    const Gap(30),
                    DateTimeField(
                      defaultDate: createEventData.endAt,
                      onChange: (DateTime value) =>
                          setState(() => createEventData.endAt = value),
                      helper: "Ending at",
                    ),
                  ],
                ))));
  }
}

class AddPeopleToEventScreen extends StatefulWidget {
  final CreateEventData createEventData;

  const AddPeopleToEventScreen({super.key, required this.createEventData});

  @override
  State<AddPeopleToEventScreen> createState() => _AddPeopleToEventScreen();
}

class _AddPeopleToEventScreen extends State<AddPeopleToEventScreen> {
  late Future<ApiClient> apiClient;
  late Future<Iterable<BasicUser>> futureUsers;
  late CreateEventData createEventData;

  @override
  void initState() {
    super.initState();
    apiClient = ApiModel.fromContext(context).api;
    createEventData = widget.createEventData..users = [];
    futureUsers = apiClient.then((api) => api.user.friend.my());
  }

  void handleUserStatusChanged(int userId, bool value) {
    value ? addUser(userId) : removeUser(userId);
  }

  void handleCreateEvent() {
    if (!createEventData.isValid()) {
      return; // check for null values
    }

    apiClient.then((api) => api.event.create(
        createEventData.emoji!.name,
        createEventData.title as String,
        createEventData.startAt as DateTime,
        createEventData.endAt as DateTime,
        createEventData.users
    ));

    context.go("/home");
  }

  void addUser(int userId) {
    if (createEventData.users.contains(userId)) return;
    setState(() => createEventData.users.add(userId));
  }

  void removeUser(int userId) {
    setState(() => createEventData.users.remove(userId));
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
                  context.go("/event/create", extra: createEventData)),
          actions: [
            TextButton(
                onPressed: handleCreateEvent,
                child: const Text("Create",
                    style: TextStyle(fontSize: 16, color: Colors.white24)))
          ],
        ),
        body: SingleChildScrollView(
            child: Padding(
                padding: const EdgeInsets.only(left: 15, right: 15, top: 30, bottom: 20),
                child: getFutureBuilder(
                    futureUsers,
                    (data) => Column(
                          children: data
                              .map((item) => Column(
                                children: [
                                  UserAsSelector(
                                      user: item,
                                      defaultValue: false,
                                      onChanged: (value) =>
                                          handleUserStatusChanged(item.id, value)),
                                  const Divider(),
                                ],
                              ))
                              .toList(),
                        )))));
  }
}
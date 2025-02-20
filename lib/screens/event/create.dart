import 'package:flutter/material.dart';
import 'package:flashbacks/models/event.dart';
import 'package:flashbacks/providers/api.dart';
import 'package:flashbacks/services/api/event.dart';
import 'package:flashbacks/utils/api/client.dart';
import 'package:flashbacks/utils/errors.dart';
import 'package:flashbacks/widgets/event/fields/datetime.dart';
import 'package:flashbacks/widgets/event/fields/emoji.dart';
import 'package:flashbacks/widgets/event/fields/mode.dart';
import 'package:flashbacks/widgets/event/fields/title.dart';
import 'package:flashbacks/widgets/event/members.dart';
import 'package:flashbacks/widgets/fields/switch.dart';
import 'package:flutter_emoji/flutter_emoji.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:material_symbols_icons/symbols.dart';

class CreateEventScreen extends StatefulWidget {
  final _emojiParser = EmojiParser();

  CreateEventScreen({super.key});

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  int? _eventId;

  late PageController _pageController;
  late Emoji _emoji;
  String? _title;
  DateTime? _startAt;
  DateTime? _endAt;
  late EventApiClient _eventApiClient;
  EventApiDetailClient? _eventDetailApiClient;

  final FieldError _titleFieldError = FieldError();
  final FieldError _timeFieldError = FieldError();

  EventViewersMode _eventViewersMode = EventViewersMode.onlyMembers;
  double _mutualFriendsLimit = 0.30;
  bool _allowNsfw = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
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

    _eventApiClient
        .create(_emoji.name, _title!, _startAt!, _endAt!)
        .then((event) {
          _eventId = event.id;
      _eventDetailApiClient = ApiModel.fromContext(context).api.event.detail(event.id);
      _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    })
        .catchError((error) => _handleError(error));
  }

  void _handleError(Map<String, dynamic> errorData) {
    if (!errorData.containsKey("timing")) return;
    setState(() => _timeFieldError.errorMessage = cleanErrorMessage(errorData["timing"].toString()));
  }

  void _handleAdvancedSettingsSubmit() {
    if (_eventDetailApiClient == null)
      return;

    JsonData patchData = {"viewers_mode": _eventViewersMode.index, "allow_nsfw": _allowNsfw};
    if (_eventViewersMode == EventViewersMode.mutualFriends) patchData["mutual_friends_limit"] = _mutualFriendsLimit;
    _eventDetailApiClient!.patch(patchData).then((_) => _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut));
  }

  void _handleCancel() {
    if (_eventDetailApiClient == null) {
      context.pop();
      return;
    }
    _eventDetailApiClient!.delete().then((_) => context.pop());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        forceMaterialTransparency: true,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0.0,
        centerTitle: true,
        title: const Text("Create new event", style: TextStyle(fontSize: 25, color: Colors.white)),
        leading: IconButton(icon: const Icon(Symbols.close), onPressed: _handleCancel),
        actions: [
          IconButton(icon: const Icon(Symbols.navigate_next), onPressed: () {
            if (_pageController.page == 0) {
              _handleSubmit();
            } else if (_pageController.page == 1) {
              _handleAdvancedSettingsSubmit();
            } else {
              context.pop();
            }
          }),
        ],
      ),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _buildBasicInfoPage(),
          _buildAdvancedSettingsPage(),
          _buildAddPeoplePage(),
        ],
      ),
    );
  }

  Widget _buildBasicInfoPage() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(right: 15, left: 15, top: 20),
        child: Column(
          children: [
            TitleFieldCard(onChange: (value) => setState(() {
              _title = value;
              if (_titleFieldError.isActive && value != "") _titleFieldError.isActive = false;
            }), fieldError: _titleFieldError),
            const Gap(20),
            EmojiCardField(defaultEmoji: _emoji, onChange: (emoji) => setState(() => _emoji = emoji)),
            const Gap(20),
            DateTimeFieldCard(onChange: (startAt, endAt) => setState(() {
              _startAt = startAt;
              _endAt = endAt;
            }), fieldError: _timeFieldError),
          ],
        ),
      ),
    );
  }

  Widget _buildAdvancedSettingsPage() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(right: 15, left: 15, top: 20),
        child: Column(
          children: [
            AnimatedSize(
              alignment: Alignment.topCenter,
              duration: const Duration(milliseconds: 150),
              child: EventViewersModeFieldCard(
                eventViewersMode: _eventViewersMode,
                mutualFriendsLimit: _mutualFriendsLimit,
                onMFLChange: (value) => setState(() => _mutualFriendsLimit = value),
                onOptionChange: (value) => setState(() => _eventViewersMode = value),
              ),
            ),
            const Gap(10),
            SwitchCardField(
              label: "Allow 18+ content",
              value: _allowNsfw,
              onChange: (value) => setState(() => _allowNsfw = value),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddPeoplePage() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Builder(builder: (context) {
          if (_eventId != null) {
            return EventMemberManager(eventId: _eventId!);
          }
          return Container();
        }),
      ),
    );
  }
}
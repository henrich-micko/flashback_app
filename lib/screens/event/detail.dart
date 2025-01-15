import 'dart:async';
import 'package:flashbacks/models/chat.dart';
import 'package:flashbacks/models/event.dart';
import 'package:flashbacks/models/user.dart';
import 'package:flashbacks/providers/api.dart';
import 'package:flashbacks/services/api/event.dart';
import 'package:flashbacks/services/websockets/chat.dart';
import 'package:flashbacks/utils/widget.dart';
import 'package:flashbacks/widgets/event/chat/message.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';


class EventDetailScreen extends StatefulWidget {
  final int eventId;

  const EventDetailScreen({super.key, required this.eventId});

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _messageEditingController = TextEditingController();

  late EventApiDetailClient _eventApiClient;
  late ChatWebSocketService _chatWebSocketService;

  late User? _authUser;
  late Future<Event> _event;
  late List<Message> _messages;
  String? _nextMessageSource;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    final apiModel = ApiModel.fromContext(context);

    _authUser = apiModel.currUser;
    _eventApiClient = apiModel.api.event.detail(widget.eventId);

    _chatWebSocketService = _eventApiClient.getChatWebSocket(_onMessage);
    _chatWebSocketService.connect();

    _event = _eventApiClient.get();
    _messages = [];

    _loadMessages();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _chatWebSocketService.close();
    super.dispose();
  }

  void _loadMessages() async {
    if (_nextMessageSource == null && _messages.isNotEmpty) {
      return;
    }

    setState(() => _isLoading = true);
    // await Future.delayed(const Duration(seconds: 0)); // for testing only
    _eventApiClient.chat.all(path: _nextMessageSource).then((messages) {
      setState(() {
        _messages.addAll(messages.results);
        _nextMessageSource = messages.next;
        _isLoading = false;
      });
    });
  }

  void _onMessage(Message message) {
    setState(() => _messages.insert(0, message));
  }

  void _sendMessage(String messageContent) {
    _chatWebSocketService.sendMessage(messageContent);
  }

  void _handleSendMessage() {
    final messageContent = _messageEditingController.text;
    if (messageContent == "") return;
    _sendMessage(messageContent.trim());
    setState(() => _messageEditingController.clear());
  }

  bool _isFirstOfStack(Message message, int index) =>
    index == 0 || message.user.id != _messages[index - 1].user.id;

  bool _isLastOfStack(Message message, int index) =>
    index == _messages.length - 1 || message.user.id != _messages[index + 1].user.id;

  void _scrollListener() async {
    if (!context.mounted) return;

    // Check if the scroll position is at the Bottom
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _loadMessages();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          forceMaterialTransparency: true,
          surfaceTintColor: Colors.transparent,
          scrolledUnderElevation: 0.0,
          title: getFutureBuilder(
              _event, (event) => Text("${event.emoji.code} ${event.title}")),
          leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.go("/home")),
          actions: [
            IconButton(
                onPressed: () => {},
                icon: const Icon(Icons.more_vert))
          ],
        ),
        body: SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Scrollbar(
                child: Column(
              children: [
                Expanded(child: _buildMessagesSection()),
                _buildMessageInput(),
              ],
            )),
          ),
        ));
  }

  Widget _buildMessageInput() {
    return Padding(
      padding: const EdgeInsets.only(top: 30),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey, width: 0.5),
          borderRadius: const BorderRadius.all(Radius.circular(11)),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageEditingController,
                style: const TextStyle(color: Colors.white70, fontSize: 17),
                decoration: const InputDecoration(
                  fillColor: Colors.black12,
                  hintText: "Type your message",
                  filled: true,
                  hintStyle: TextStyle(
                      color: Colors.grey,
                      fontSize: 15,
                      fontWeight: FontWeight.w400),
                  border: InputBorder.none,
                ),
              ),
            ),

            IconButton(
              onPressed: _handleSendMessage,
              icon: const Icon(Symbols.send),
              color: _messageEditingController.text.isEmpty ? Colors.grey : Colors.white,
            )
          ],
        ),
      ),
    );
  }

  Widget _buildMessagesSection() {
    return ListView.builder(
        reverse: true,
        controller: _scrollController,
        itemCount: _messages.length + (_isLoading ? 1 : 0),
        itemBuilder: (context, index) {
          if (index < _messages.length) return _buildMessageBubble(index);
          return const Center(
            child: Padding(
              padding: EdgeInsets.only(top: 10, bottom: 25),
              child: SizedBox(
                  width: 20, height: 20, child: CircularProgressIndicator()),
            ),
          );
        });
  }

  Widget _buildMessageBubble(int index) {
    final message = _messages[index];
    return MessageBubble(
      message: message,
      isFirstOfStack: _isFirstOfStack(message, index),
      isLastOfStack: _isLastOfStack(message, index),
      fromAuthUser: _authUser != null && message.user.id == _authUser!.id,
    );
  }
}

import 'dart:async';
import 'dart:ui';
import 'package:flashbacks/models/chat.dart';
import 'package:flashbacks/models/event.dart';
import 'package:flashbacks/models/user.dart';
import 'package:flashbacks/providers/api.dart';
import 'package:flashbacks/services/api/event.dart';
import 'package:flashbacks/services/websockets/client.dart';
import 'package:flashbacks/utils/utils.dart';
import 'package:flashbacks/utils/widget.dart';
import 'package:flashbacks/widgets/event/chat/message.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:sortedmap/sortedmap.dart';


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
  late ClientWebSocketService _websocket;

  late MiniUser? _authUser;
  late Future<Event> _event;

  final SortedMap<int, Message> _messages = SortedMap(const Ordering.byKey());
  MessageParent? _messageParent;

  String? _nextMessageSource;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    final apiModel = ApiModel.fromContext(context);

    _authUser = apiModel.currUser;
    _eventApiClient = apiModel.api.event.detail(widget.eventId);
    _websocket = apiModel.api.websocket;
    _websocket.onMessage = _onMessage;

    _event = _eventApiClient.get();

    _loadMessages();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _websocket.onMessage = null;
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
        for (Message message in messages.results)
          _messages[message.pk] = message;
        _isLoading = false;
      });
    });
  }

  Message _getMessageByIndex(int index) {
    final pk = _messages.keys.elementAt(_messages.length-index-1);
    return _messages[pk]!;
  }

  void _onMessage(Message message) {
    setState(() => _messages[message.pk] = message);
  }

  void _sendMessage(String messageContent) {
    Logger().i(_messageParent);
    _websocket.sendMessage(
        widget.eventId, messageContent, parent: _messageParent
    );
  }

  void _handleSendMessage() {
    final messageContent = _messageEditingController.text;
    if (messageContent == "") return;
    _sendMessage(messageContent.trim());
    setState(() {
      _messageEditingController.clear();
      _messageParent = null;
    });
  }

  void _handleLikeUnlikeMessage(int messageId) {
    _websocket.likeUnlike(messageId);
  }

  void _handleLongPressMessage(int messageId) {
    if (!_messages.containsKey(messageId)) return;
    setState(() =>
      _messageParent = _messages[messageId]!.toMessageParent()
    );
  }

  void _handleCloseMessageParent() {
    setState(() => _messageParent = null);
  }

  bool _isFirstOfStack(Message message) {
    try {
      return message.user.id != _messages[_messages.firstKeyAfter(message.pk)]!.user.id;
    } catch (e) {
      return false;
    }
  }

  bool _isLastOfStack(Message message){
    try {
      return message.user.id != _messages[_messages.lastKeyBefore(message.pk)]!.user.id;
    } catch (e) {
      return false;
    }
  }

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
              onPressed: () => context.pop()),
          actions: [
            getFutureBuilder(_event, (event) {
              if (event.status != EventStatus.activated)
                return Container();
              return IconButton(
                padding: EdgeInsets.zero,
                onPressed: () => context.push("/event/${widget.eventId}/flashback/create/"),
                icon: const Icon(Symbols.camera),
                color: _messageEditingController.text.isEmpty ? Colors.grey : Colors.white,
              );
            }),
            IconButton(
                onPressed: () => context.push("/event/${widget.eventId}/info/"),
                icon: const Icon(Symbols.info)),
            IconButton(
                onPressed: () => context.push("/event/${widget.eventId}/options/"),
                icon: const Icon(Symbols.more_vert))
          ],
        ),
        body: SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Scrollbar(
              child: Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: _buildMessagesSection(),
                ),
              ),
              _buildMessageInput(),
            ],
          )),
        ));
  }

  Widget _buildMessageInput() {
    return Padding(
      padding: const EdgeInsets.only(top: 30),
      child: Container(
        decoration: BoxDecoration(
          color: _messageParent == null ? Colors.transparent : Colors.black,
          borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(11),
              topRight: Radius.circular(11)
          ),
          border: _messageParent == null ? null : Border.all(color: Colors.grey, width: 0.4),
        ),
        child: Column(
          children: [
            _buildMessageParent(),
            Padding(
              padding: const EdgeInsets.only(left: 8, right: 8, bottom: 8),
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
                        onSubmitted: (_) => _handleSendMessage(),
                        style: const TextStyle(color: Colors.white70, fontSize: 17),
                        decoration: const InputDecoration(
                          fillColor: Colors.transparent,
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

                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            onPressed: _handleSendMessage,
                            icon: const Icon(Symbols.send),
                            color: _messageEditingController.text.isEmpty ? Colors.grey : Colors.white,
                          ),
                        ],
                      )
                  ],
                ),
              ),
            ),
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
    final Message message = _getMessageByIndex(index);

    return MessageBubble(
      message: message,
      onDoubleTap: _handleLikeUnlikeMessage,
      onLongPress: _handleLongPressMessage,
      isFirstOfStack: _isFirstOfStack(message),
      isLastOfStack: _isLastOfStack(message),
      fromAuthUser: _authUser != null && message.user.id == _authUser!.id,
    );
  }

  Widget _buildMessageParent() {
    if (_messageParent == null)
      return Container();

    return Padding(
      padding: const EdgeInsets.only(left: 14, top: 9, right: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Respond to ${_messageParent!.user.username}",
                style: const TextStyle(fontSize: 13, color: Colors.grey, height: 1),
                textAlign: TextAlign.start,
              ),
              Row(
                children: [
                  Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()..scale(-1.0, 1.0),
                      child:
                      const Icon(Symbols.reply, color: Colors.grey, size: 22)),
                  Container(
                    margin: const EdgeInsets.all(1),
                    child: Padding(
                      padding: const EdgeInsets.only(
                          left: 7, right: 7, top: 5, bottom: 5),
                      child: Text(
                          _messageParent!.content.isEmpty
                              ? "wsew?"
                              : truncateWithEllipsis(_messageParent!.content, 30),
                          textAlign: TextAlign.start,
                          style: const TextStyle(fontSize: 16, color: Colors.grey)),
                    ),
                  ),
                ],
              ),
            ],
          ),

          GestureDetector(
              onTap: _handleCloseMessageParent,
              child: const Icon(Symbols.close_rounded, color: Colors.grey, size: 17),
          )
        ]
      ),
    );
  }
}

import 'package:flashbacks/models/chat.dart';
import 'package:flashbacks/utils/time.dart';
import 'package:flashbacks/utils/utils.dart';
import 'package:flashbacks/widgets/user.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:logger/logger.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

class MessageBubble extends StatelessWidget {
  final Message message;

  // par for visuals
  final bool isLastOfStack;
  final bool isFirstOfStack;
  final bool fromAuthUser;

  final Function(int messageId) onDoubleTap;
  final Function(int messageId) onLongPress;

  const MessageBubble({
    super.key,
    required this.message,
    required this.onDoubleTap,
    required this.onLongPress,

    this.isLastOfStack = false,
    this.isFirstOfStack = false,
    this.fromAuthUser = false,
  });

  List<Widget> _reversable(List<Widget> widgets) {
    return fromAuthUser ? widgets.reversed.toList() : widgets;
  }

  @override
  Widget build(BuildContext context) {
    if (message.parent != null) {
      Logger().i(message.pk.toString() + " "+  message.parent!.pk.toString() + message.content + message.parent!.content);
    }

    final double messageMaxWidth = MediaQuery.of(context).size.width * 0.7;
    return Container(
      margin: isLastOfStack || message.parent != null
          ? const EdgeInsets.only(top: 20)
          : null,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment:
            fromAuthUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: _reversable([
          if (!fromAuthUser) _buildProfilePicture(),
          const Gap(5),
          _buildMessageBubble(message, messageMaxWidth),
        ]),
      ),
    );
  }

  Widget _buildProfilePicture() {
    return SizedBox(
      width: 35,
      height: 35,
      child: isFirstOfStack
          ? Center(
              child: UserProfilePicture(
                  size: 17.5, profilePictureUrl: message.user.profileUrl),
            )
          : null,
    );
  }

  Widget _buildMessageBubble(Message message, double maxWidth) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
      if (!fromAuthUser && isLastOfStack && message.parent == null)
        Padding(
          padding: const EdgeInsets.only(left: 12),
          child: Text(message.user.username,
              style: const TextStyle(fontSize: 15, color: Colors.grey)),
        ),
      if (message.parent != null) _buildParent(),
      Row(
        children: _reversable(
          [
            GestureDetector(
              onLongPress: () => onLongPress(message.pk),
              onDoubleTap: () => onDoubleTap(message.pk),
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: maxWidth, // 70% of the screen width
                ),
                margin: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey, width: 0.5),
                  borderRadius: const BorderRadius.all(Radius.circular(11)),
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.only(left: 9, right: 9, top: 5, bottom: 5),
                  child: Text(
                      message.content.isEmpty
                          ? "WOW SO EMPTY WHAT?"
                          : message.content,
                      textAlign: TextAlign.start,
                      style: const TextStyle(fontSize: 16)),
                ),
              ),
            ),
            const Gap(5),
            Text(timeFormat.format(message.timestamp),
                style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    ]);
  }

  Widget _buildParent() {
    return Padding(
      padding: EdgeInsets.only(left: fromAuthUser ? 41 : 7, top: !isLastOfStack ? 7 : 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "${message.user.username} responded to ${message.parent!.user.username}",
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
                      message.parent!.content.isEmpty
                          ? "wsew?"
                          : truncateWithEllipsis(message.parent!.content, 25),
                      textAlign: TextAlign.start,
                      style: const TextStyle(fontSize: 16, color: Colors.grey)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

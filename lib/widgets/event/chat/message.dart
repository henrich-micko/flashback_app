import 'package:flashbacks/models/chat.dart';
import 'package:flashbacks/widgets/user.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class MessageBubble extends StatelessWidget {
  final List<Message> messages;
  const MessageBubble({super.key, required this.messages});

  @override
  Widget build(BuildContext context) {
    final double messageMaxWidth = MediaQuery.of(context).size.width * 0.7;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        UserProfilePicture(
            size: 17, profilePictureUrl: messages.first.user!.profileUrl),
        const Gap(10),
        Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: messages
                .map((message) => _buildMessageBubble(message, messageMaxWidth))
                .toList()),
      ],
    );
  }

  Widget _buildMessageBubble(Message message, double maxWidth) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: maxWidth, // 70% of the screen width
      ),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey, width: 0.5),
        borderRadius: const BorderRadius.all(Radius.circular(11)),
      ),
      margin: const EdgeInsets.only(bottom: 5),
      child: Padding(
        padding: const EdgeInsets.only(left: 7, right: 7, top: 5, bottom: 5),
        child: Text(message.content,
            textAlign: TextAlign.start, style: const TextStyle(fontSize: 16)),
      ),
    );
  }
}

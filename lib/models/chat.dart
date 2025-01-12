import 'package:flashbacks/models/user.dart';
import 'package:flashbacks/utils/models.dart';


class MessageParent extends BaseModel {
  final int pk;
  final String content;

  MessageParent({
    required this.pk,
    required this.content,
  });

  factory MessageParent.fromJson(Map<String, dynamic> json) {
    return MessageParent(
      pk: json["pk"],
      content: json["content"]
    );
  }
}

class Message extends BaseModel {
  final int pk;
  final MiniUser? user;
  final String content;
  final DateTime timestamp;
  final MessageParent? parent;

  bool isFirstOfDay = false;

  Message({
    required this.pk,
    required this.user,
    required this.content,
    required this.timestamp,
    required this.parent,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      pk: json["pk"],
      user: json["user"] != null ? MiniUser.fromJson(json["user"]) : null,
      content: json["content"],
      timestamp: DateTime.parse(json["timestamp"]),
      parent: json["parent"] != null ? MessageParent.fromJson(json["parent"]) : null,
    );
  }
}
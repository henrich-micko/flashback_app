import 'package:flashbacks/models/user.dart';
import 'package:flutter_emoji/flutter_emoji.dart';

enum EventStatus {
  opened,
  activated,
  closed,
}

class Event {
  final int id;
  final Emoji emoji;
  final String title;
  final DateTime startAt;
  final DateTime endAt;
  final EventStatus status;
  final String quickDetail;

  static const defaultEmojiCode = ":four_leaf_clover:";

  Event({
    required this.id,
    required this.emoji,
    required this.title,
    required this.startAt,
    required this.endAt,
    required this.status,
    required this.quickDetail,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
        id: json["id"],
        emoji: EmojiParser().getName(json["emoji"]),
        title: json["title"],
        startAt: DateTime.parse(json["start_at"]),
        endAt: DateTime.parse(json["end_at"]),
        status: EventStatus.values[json["status"]],
        quickDetail: json["quick_detail"]
    );
  }
}

enum EventMemberRole {
  host,
  guest,
}


class EventMember {
  final int id;
  final int event;
  final BasicUser user;
  final EventMemberRole role;

  EventMember({
    required this.id,
    required this.event,
    required this.user,
    required this.role,
  });

  factory EventMember.fromJson(Map<String, dynamic> json) {
    return EventMember(
      id: json["id"],
      event: int.parse(json["event"].toString()),
      user: BasicUser.fromJson(json["user"]),
      role: EventMemberRole.values[json["role"]],
    );
  }
}


class PossibleEventMember {
  final int event;
  final BasicUser user;
  final bool isMember;

  PossibleEventMember({required this.event, required this.user, required this.isMember});

  factory PossibleEventMember.fromJson(Map<String, dynamic> json) {
    return PossibleEventMember(
      event: json["event"],
      user: BasicUser.fromJson(json["user"]),
      isMember: json["is_member"],
    );
  }
}
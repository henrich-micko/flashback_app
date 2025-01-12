import 'dart:ffi';

import 'package:flashbacks/models/flashback.dart';
import 'package:flashbacks/models/user.dart';
import 'package:flashbacks/services/api/client.dart';
import 'package:flashbacks/utils/models.dart';
import 'package:flutter_emoji/flutter_emoji.dart';



enum EventMemberRole {
  host,
  guest,
}


class EventMember extends BaseModel {
  final int id;
  final int event;
  final User user;
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
      user: User.fromJson(json["user"]),
      role: EventMemberRole.values[json["role"]],
    );
  }
}

enum EventStatus {
  opened,
  activated,
  closed,
}

enum EventViewersMode {
  onlyMembers,
  allFriends,
  mutualFriends,
}

class Event extends BaseModel {
  final int id;
  final Emoji emoji;
  final String title;
  final DateTime startAt;
  final DateTime endAt;
  final EventStatus status;
  final String quickDetail;
  final EventViewersMode eventViewersMode;
  final double? mutualFriendsLimit;

  // optional fields
  List<EventMember>? members;

  static const defaultEmojiCode = ":tada:";

  Event({
    required this.id,
    required this.emoji,
    required this.title,
    required this.startAt,
    required this.endAt,
    required this.status,
    required this.quickDetail,
    required this.eventViewersMode,
    required this.mutualFriendsLimit
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
        id: json["pk"],
        emoji: EmojiParser().getName(json["emoji"]),
        title: json["title"],
        startAt: DateTime.parse(json["start_at"]),
        endAt: DateTime.parse(json["end_at"]),
        status: EventStatus.values[json["status"]],
        quickDetail: json["quick_detail"],
        eventViewersMode: EventViewersMode.values[json["viewers_mode"]],
        mutualFriendsLimit: json["mutual_friends_limit"] == null ? json["mutual_friends_limit"] : double.parse(json["mutual_friends_limit"]),
    );
  }

  void loadMembers(ApiClient apiClient) async {
    apiClient.event.detail(id).member.all().then((members) {
      this.members = members.toList();
    });
  }
}

class PossibleEventMember extends BaseModel {
  final int event;
  final User user;
  final bool isMember;

  PossibleEventMember({required this.event, required this.user, required this.isMember});

  factory PossibleEventMember.fromJson(Map<String, dynamic> json) {
    return PossibleEventMember(
      event: json["event"],
      user: User.fromJson(json["user"]),
      isMember: json["is_member"],
    );
  }
}


class EventPreview extends BaseModel {
  final int pk;
  final EventPreviewFlashback flashback;
  final int order;

  EventPreview({
    required this.pk,
    required this.flashback,
    required this.order
  });

  factory EventPreview.fromJson(Map<String, dynamic> json) {
    return EventPreview(
      pk: json["pk"],
      flashback: EventPreviewFlashback.fromJson(json["flashback"]),
      order: json["order"]
    );
  }
}


class EventViewer extends BaseModel {
  final int pk;
  final Event event;
  final int flashbacksCount;
  final List<EventPreview> preview;
  final bool isMember;

  EventViewer({
    required this.pk,
    required this.event,
    required this.flashbacksCount,
    required this.preview,
    required this.isMember
  });

  factory EventViewer.fromJson(Map<String, dynamic> json) {
    return EventViewer(
      pk: json["pk"],
      event: Event.fromJson(json["event"]),
      flashbacksCount: json["flashbacks_count"],
      preview: List.from(json["preview"].map((p) => EventPreview.fromJson(p))),
      isMember: json["is_member"]
    );
  }
}

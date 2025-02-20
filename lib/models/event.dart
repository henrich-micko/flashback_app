import 'dart:ffi';
import 'dart:ui';

import 'package:flashbacks/models/flashback.dart';
import 'package:flashbacks/models/user.dart';
import 'package:flashbacks/services/api/client.dart';
import 'package:flashbacks/utils/colors.dart';
import 'package:flashbacks/utils/models.dart';
import 'package:flutter_emoji/flutter_emoji.dart';



enum EventMemberRole {
  host,
  guest,
}


class EventMember extends BaseModel {
  final int id;
  final int event;
  final MiniUser user;
  final EventMemberRole role;
  final MiniUser? addedBy;

  EventMember({
    required this.id,
    required this.event,
    required this.user,
    required this.role,
    required this.addedBy
  });

  factory EventMember.fromJson(Map<String, dynamic> json) {
    return EventMember(
      id: json["pk"],
      event: int.parse(json["event"].toString()),
      user: MiniUser.fromJson(json["user"]),
      role: EventMemberRole.values[json["role"]],
      addedBy: json["added_by"] == null ? null : MiniUser.fromJson(json["added_by"]),
    );
  }
}


enum EventInviteStatus {
  pending,
  accept,
  decline,
}

class EventInvite extends BaseModel {
  final int id;
  final int event;
  final MiniUser user;
  final EventInviteStatus status;
  final MiniUser? invitedBy;

  EventInvite({
    required this.id,
    required this.event,
    required this.user,
    required this.status,
    required this.invitedBy
  });

  factory EventInvite.fromJson(Map<String, dynamic> json) {
    return EventInvite(
      id: json["id"],
      event: int.parse(json["event"].toString()),
      user: MiniUser.fromJson(json["user"]),
      status: EventInviteStatus.values[json["status"]],
      invitedBy: MiniUser.fromJson(json["invited_by"]),
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
  final int flashbacksCount;
  final bool allowNsfw;

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
    required this.mutualFriendsLimit,
    required this.flashbacksCount,
    required this.allowNsfw,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
        id: json["pk"],
        emoji: EmojiParser().getName(json["emoji"]),
        title: json["title"],
        startAt: DateTime.parse(json["start_at"]).toLocal(),
        endAt: DateTime.parse(json["end_at"]).toLocal(),
        status: EventStatus.values[json["status"]],
        quickDetail: json["quick_detail"],
        eventViewersMode: EventViewersMode.values[json["viewers_mode"]],
        mutualFriendsLimit: json["mutual_friends_limit"] == null ? json["mutual_friends_limit"] : double.parse(json["mutual_friends_limit"]),
        flashbacksCount: json["flashbacks_count"],
        allowNsfw: json["allow_nsfw"],
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
  final bool isOpened;

  EventViewer({
    required this.pk,
    required this.event,
    required this.flashbacksCount,
    required this.preview,
    required this.isMember,
    required this.isOpened,
  });

  factory EventViewer.fromJson(Map<String, dynamic> json) {
    return EventViewer(
      pk: json["pk"],
      event: Event.fromJson(json["event"]),
      flashbacksCount: json["flashbacks_count"],
      preview: List.from(json["preview"].map((p) => EventPreview.fromJson(p))),
      isMember: json["is_member"],
      isOpened: json["is_opened"]
    );
  }
}

class EventPosterColorPalette extends BaseModel {
  final int pk;
  final Color color;
  final Color lightColor;

  EventPosterColorPalette({
    required this.pk,
    required this.color,
    required this.lightColor
  });

  factory EventPosterColorPalette.fromJson(Map<String, dynamic> json) {
    return EventPosterColorPalette(
      pk: json["id"],
      color: hexToColor(json["color"]),
      lightColor: hexToColor(json["light_color"]),
    );
  }
}

class EventPosterTemplate extends BaseModel {
  final int pk;
  final String title;
  final List<EventPosterColorPalette> colorPalettes;

  EventPosterTemplate({
    required this.pk,
    required this.title,
    required this.colorPalettes
  });

  factory EventPosterTemplate.fromJson(Map<String, dynamic> json) {
    return EventPosterTemplate(
        pk: json["id"],
        title: json["title"],
        colorPalettes: List.from(json["color_palettes"].map((p) => EventPosterColorPalette.fromJson(p)))
    );
  }
}

enum EventPossibleMemberStatus {
  member,
  invited,
  none,
}

class EventPossibleMember extends MiniUser {
  final EventPossibleMemberStatus status;

  EventPossibleMember({
    required super.id,
    required super.username,
    required super.email,
    required super.profileUrl,
    required this.status,
    required super.about
  });

  factory EventPossibleMember.fromJson(Map<String, dynamic> json) {
    return EventPossibleMember(
      id: json["id"],
      username: json["username"],
      email: json["email"],
      profileUrl: json["profile"],
      status: EventPossibleMemberStatus.values[json["status"]],
      about: json["about"],
    );
  }
}


class MiniEvent extends BaseModel {
  final int id;
  final Emoji emoji;
  final String title;
  final DateTime startAt;
  final DateTime endAt;

  // optional fields
  List<EventMember>? members;

  static const defaultEmojiCode = ":tada:";

  MiniEvent({
    required this.id,
    required this.emoji,
    required this.title,
    required this.startAt,
    required this.endAt,
  });

  factory MiniEvent.fromJson(Map<String, dynamic> json) {
    return MiniEvent(
      id: json["pk"],
      emoji: EmojiParser().getName(json["emoji"]),
      title: json["title"],
      startAt: DateTime.parse(json["start_at"]).toLocal(),
      endAt: DateTime.parse(json["end_at"]).toLocal(),
    );
  }
}

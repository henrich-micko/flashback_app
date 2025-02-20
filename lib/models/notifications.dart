import 'package:flashbacks/models/event.dart';
import 'package:flashbacks/models/user.dart';
import 'package:flashbacks/utils/api/client.dart';
import 'package:flashbacks/utils/models.dart';


enum NotificationType {
  friendRequest,
  eventInvitation,
}


class BaseNotification extends BaseModel {
  final NotificationType type;
  final JsonData data;

  BaseNotification({
    required this.type,
    required this.data,
  });

  factory BaseNotification.fromJson(JsonData json) {
    return BaseNotification(
        type: NotificationType.values[json["type"]],
        data: json["data"],
    );
  }

  BaseNotification toSpec() {
    if (type == NotificationType.friendRequest)
      return FriendRequestNotification.fromJson(data);
    if (type == NotificationType.eventInvitation)
      return EventInviteNotification.fromJson(data);
    return this;
  }
}


class FriendRequestNotification extends BaseNotification {
  final MiniUser fromUser;

  FriendRequestNotification({required this.fromUser})
      : super(type: NotificationType.friendRequest, data: {});

  factory FriendRequestNotification.fromJson(JsonData json) {
    return FriendRequestNotification(
      fromUser: MiniUser.fromJson(json["from_user"]),
    );
  }
}

class EventInviteNotification extends BaseNotification {
  final MiniUser invitedBy;
  final MiniEvent event;

  EventInviteNotification({required this.invitedBy, required this.event})
      : super(type: NotificationType.friendRequest, data: {});

  factory EventInviteNotification.fromJson(JsonData json) {
    return EventInviteNotification(
      invitedBy: MiniUser.fromJson(json["invited_by"]),
      event: MiniEvent.fromJson(json["event"]),
    );
  }
}
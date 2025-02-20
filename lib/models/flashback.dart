import 'package:flashbacks/models/user.dart';
import 'package:flashbacks/utils/models.dart';

class BasicFlashback extends BaseModel {
  final int id;
  final String media;
  final MiniUser createdBy;
  final DateTime createdAt;

  BasicFlashback({
    required this.id,
    required this.media,
    required this.createdBy,
    required this.createdAt,
  });

  factory BasicFlashback.fromJson(Map<String, dynamic> json) {
    return BasicFlashback(
        id: json["id"],
        media: json["media"],
        createdBy: MiniUser.fromJson(json["created_by"]),
        createdAt: DateTime.parse(json["created_at"])
    );
  }
}


class EventPreviewFlashback extends BaseModel {
  final int pk;
  final String media;

  EventPreviewFlashback({
    required this.pk,
    required this.media
  });

  factory EventPreviewFlashback.fromJson(Map<String, dynamic> json) {
    return EventPreviewFlashback(
      pk: json["pk"],
      media: json["media"]
    );
  }
}
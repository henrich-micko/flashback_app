import 'package:flashbacks/models/user.dart';

class BasicFlashback {
  final int id;
  final String media;
  final BasicUser createdBy;
  final DateTime createdAt;

  const BasicFlashback({
    required this.id,
    required this.media,
    required this.createdBy,
    required this.createdAt,
  });

  factory BasicFlashback.fromJson(Map<String, dynamic> json) {
    return BasicFlashback(
        id: json["id"],
        media: json["media"],
        createdBy: BasicUser.fromJson(json["created_by"]),  
        createdAt: DateTime.parse(json["created_at"])
    );
  }
}
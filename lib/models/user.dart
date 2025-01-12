class User {
  final int id;
  final String username;
  final String email;
  final String quickDetail;
  final String profileUrl;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.quickDetail,
    required this.profileUrl
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
        id: json["id"],
        username: json["username"],
        email: json["email"],
        quickDetail: json["quick_detail"],
        profileUrl: json["profile_url"]
    );
  }
}

enum FriendshipStatus {
  friend,
  requestToMe,
  requestFromMe,
  none,
}

class UserPov extends User {
  final FriendshipStatus friendshipStatus;

  UserPov({
    required super.id,
    required super.username,
    required super.email,
    required super.quickDetail,
    required super.profileUrl,
    required this.friendshipStatus,
  });

  factory UserPov.fromJson(Map<String, dynamic> json) {
    return UserPov(
        id: json["id"],
        username: json["username"],
        email: json["email"],
        quickDetail: json["quick_detail"],
        profileUrl: json["profile_url"],
        friendshipStatus: FriendshipStatus.values[json["friendship_status"]]
    );
  }
}

enum FriendRequestStatus {
  pending,
  accepted,
  refused
}

class FriendRequest {
  final int id;
  final User toUser;
  final User fromUser;
  final FriendRequestStatus status;
  final DateTime date;

  FriendRequest({
    required this.id,
    required this.toUser,
    required this.fromUser,
    required this.status,
    required this.date,
  });

  factory FriendRequest.fromJson(Map<String, dynamic> json) {
    return FriendRequest(
        id: json["id"],
        toUser: User.fromJson(json["to_user"]),
        fromUser: User.fromJson(json["from_user"]),
        status: FriendRequestStatus.values[json["status"]],
        date: DateTime.parse(json["date"]),
    );
  }
}


class MiniUser {
  final int id;
  final String username;
  final String email;
  final String profileUrl;

  MiniUser({
    required this.id,
    required this.username,
    required this.email,
    required this.profileUrl
  });

  factory MiniUser.fromJson(Map<String, dynamic> json) {
    return MiniUser(
        id: json["id"],
        username: json["username"],
        email: json["email"],
        profileUrl: json["profile_url"]
    );
  }
}

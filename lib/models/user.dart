import 'package:flashbacks/utils/models.dart';


class CreateUserResponse extends BaseModel {
  final int id;
  final String username;
  final String email;
  String profile;
  final String token;

  CreateUserResponse({
    required this.id,
    required this.username,
    required this.email,
    required this.profile,
    required this.token
  });

  factory CreateUserResponse.fromJson(Map<String, dynamic> json) {
    return CreateUserResponse(
        id: json["id"],
        username: json["username"],
        email: json["email"],
        profile: json["profile"],
        token: json["token"]
    );
  }
}

class User extends BaseModel {
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


class MiniUser extends BaseModel {
  final int id;
  final String username;
  final String email;
  final String profileUrl;
  final String? about;

  MiniUser({
    required this.id,
    required this.username,
    required this.email,
    required this.profileUrl,
    required this.about
  });

  factory MiniUser.fromJson(Map<String, dynamic> json) {
    return MiniUser(
        id: json["id"],
        username: json["username"],
        email: json["email"],
        profileUrl: json["profile"],
        about: json["about"],
    );
  }
}

class MiniUserContextual extends MiniUser {
  final FriendshipStatus friendshipStatus;
  final List<MiniUser> mutualFriends;

  MiniUserContextual({
    required super.id,
    required super.email,
    required super.profileUrl,
    required super.username,
    required this.friendshipStatus,
    required this.mutualFriends,
    required super.about,
  });

  factory MiniUserContextual.fromJson(Map<String, dynamic> json) {
    return MiniUserContextual(
      id: json["id"],
      username: json["username"],
      email: json["email"],
      profileUrl: json["profile"],
      friendshipStatus: FriendshipStatus.values[json["friendship_status"]],
      mutualFriends: List.from(json["mutual_friends"].map((p) => MiniUser.fromJson(p))),
      about: json["about"],
    );
  }
}

class UserContextual extends MiniUserContextual {
  int friendsCount;
  int eventsCount;
  int flashbacksCount;

  UserContextual({
    required super.id,
    required super.email,
    required super.profileUrl,
    required super.username,
    required super.friendshipStatus,
    required super.mutualFriends,
    required this.friendsCount,
    required this.eventsCount,
    required this.flashbacksCount,
    required super.about,
  });

  factory UserContextual.fromJson(Map<String, dynamic> json) {
    return UserContextual(
      id: json["id"],
      username: json["username"],
      email: json["email"],
      profileUrl: json["profile"],
      friendshipStatus: FriendshipStatus.values[json["friendship_status"]],
      mutualFriends: List.from(json["mutual_friends"].map((p) => MiniUser.fromJson(p))),
      friendsCount: json["friends_count"],
      eventsCount: json["events_count"],
      flashbacksCount: json["flashbacks_count"],
      about: json["about"],
    );
  }
}

class AnonymousUserData extends BaseModel {
  final int id;
  final String username;
  final String email;
  final String profileUrl;

  AnonymousUserData({
    required this.id,
    required this.username,
    required this.email,
    required this.profileUrl
  });

  factory AnonymousUserData.fromJson(Map<String, dynamic> json) {
    return AnonymousUserData(
        id: json["id"],
        username: json["username"],
        email: json["email"],
        profileUrl: json["profile_url"]
    );
  }

  // THIS IS HORRIBLE I DONT KNOW WHY I DID IT I JUST REALY DONT WANE CHECK ANOTHER NULL
  factory AnonymousUserData.defaultData() {
    return AnonymousUserData(
        id: -1,
        username: "flashbacks_user",
        email: "flashbacks_user@flashbacks.com",
        profileUrl: "https://img.buzzfeed.com/buzzfeed-static/static/2020-03/19/3/campaign_images/756f49d8c6f3/if-you-can-name-at-least-12-the-office-employees--2-604-1584589997-10_dblbig.jpg?resize=1200:*",
    );
  }
}

class AuthMiniUser extends MiniUser {
  int friendsCount;
  int eventsCount;
  int flashbacksCount;
  DateTime dateJoined;

  AuthMiniUser({
    required super.id,
    required super.email,
    required super.profileUrl,
    required super.username,
    required this.friendsCount,
    required this.eventsCount,
    required this.flashbacksCount,
    required this.dateJoined,
    required super.about,
  });

  factory AuthMiniUser.fromJson(Map<String, dynamic> json) {
    return AuthMiniUser(
        id: json["id"],
        username: json["username"],
        email: json["email"],
        profileUrl: json["profile"],
        friendsCount: json["friends_count"],
        eventsCount: json["events_count"],
        flashbacksCount: json["flashbacks_count"],
        dateJoined: DateTime.parse(json["date_joined"]).toLocal(),
        about: json["about"],
    );
  }
}




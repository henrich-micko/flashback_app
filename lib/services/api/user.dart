import 'dart:convert';

import 'package:flashbacks/models/event.dart';
import 'package:flashbacks/models/notifications.dart';
import 'package:flashbacks/utils/api/client.dart';
import 'package:flashbacks/utils/api/mixins.dart';
import 'package:flashbacks/models/user.dart';


class UserDetailApiClient extends BaseApiModelDetailClient<UserContextual> with ApiDetModelGetMixin<UserContextual> {
  late FriendApiClient friend;

  @override
  String modelPath = "api/user/users/{detailPk}/";

  @override
  UserContextual itemFromJson(Map<String, dynamic> json) => UserContextual.fromJson(json);

  UserDetailApiClient({required super.apiBaseUrl, required super.detailPk, required super.authToken}) {
    friend = FriendApiClient(apiBaseUrl: apiBaseUrl, authToken: authToken, userPk: detailPk);
  }

  Future<Iterable<EventViewer>> viewers() {
    return getItems<EventViewer>("${modelPath}viewers/", EventViewer.fromJson);
  }
}


class UserApiClient extends BaseApiModelClient<UserContextual> with
    ApiModelGetMixin<UserContextual>,
    ApiModelFilterMixin<UserContextual>,
    ApiModelDeleteMixin<UserContextual> {

  @override
  String modelPath = "api/user/users/";

  UserApiClient({required super.apiBaseUrl, required super.authToken});

  @override
  UserContextual itemFromJson(Map<String, dynamic> json) => UserContextual.fromJson(json);

  UserDetailApiClient detail(int userPk) =>
      UserDetailApiClient(authToken: authToken, apiBaseUrl: apiBaseUrl, detailPk: userPk);

  Future<Iterable<MiniUserContextual>> search(String q) {
    return getItems<MiniUserContextual>(
        "${modelPath}search/", MiniUserContextual.fromJson, filter: {"q": q}
    );
  }
}


class FriendApiClient extends BaseApiClient {
  final int userPk;
  String path = "api/user/users/{userPk}/friendship/";

  FriendApiClient({required super.apiBaseUrl, required super.authToken, required this.userPk}) {
    path = path.replaceFirst("{userPk}", userPk.toString());
  }

  Future<Iterable<UserContextual>> all() async {
    return getItems<UserContextual>(path, UserContextual.fromJson);
  }

  Future<UserContextual> sendRequest() async {
    return postRequest(path, status: 200).then((data) {
      JsonData jsonData = json.decode(data);
      return UserContextual.fromJson(jsonData);
    });
  }

  Future<UserContextual> acceptRequest() async {
    return putRequest(path, status: 200).then((data) {
      JsonData jsonData = json.decode(data);
      return UserContextual.fromJson(jsonData);
    });
  }

  Future<UserContextual> deleteRequestOrFriendship() async {
    return deleteRequest(path, status: 200).then((data) {
      JsonData jsonData = json.decode(data);
      return UserContextual.fromJson(jsonData);
    });
  }
}


class AuthUserApiClient extends BaseApiClient {
  AuthUserApiClient({required super.apiBaseUrl, required super.authToken});

  Future<MiniUser> me() async {
    return getItem(resolveUrl("api/user/auth_user/me/").toString(), MiniUser.fromJson);
  }

  Future<AuthMiniUser> meComplex() async {
    return getItem(resolveUrl("api/user/auth_user/me_complex/").toString(), AuthMiniUser.fromJson);
  }

  Future<Iterable<FriendRequest>> requests() async {
    return getItems<FriendRequest>(
        resolveUrl("api/user/auth_user/requests/").toString(), FriendRequest.fromJson
    );
  }

  Future<Iterable<UserContextual>> friends() {
    return getItems<UserContextual>(
        resolveUrl("api/user/auth_user/friends/").toString(), UserContextual.fromJson
    );
  }

  Future<bool> notificationsExists() async {
    return getRequest("api/user/auth_user/notifications_exists/", status: 200).then((data) {
      JsonData jsonData = json.decode(data);
      return jsonData["exists"];
    });
  }

  Future<Iterable<BaseNotification>> notifications() async {
    return await getItems<BaseNotification>(
        "api/user/auth_user/notifications/", BaseNotification.fromJson).then((items) =>
        items.map((item) => item.toSpec()).toList()
    );
  }
}


import 'dart:async';
import 'dart:io';

import 'package:flashbacks/models/user.dart';
import 'package:flashbacks/services/api/client.dart';
import 'package:flashbacks/utils/api/client.dart';
import 'package:flashbacks/utils/api/token.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';


class ApiModel extends ChangeNotifier {
  MiniUser? currUser;
  bool notificationsExists = false;

  late ApiClient api;

  ApiModel(String? authToken) {
    setAuthToken(authToken);
  }

  void reload() {
    _loadCurrUser(notifyListeners: false);
    _loadNotificationsExists(notifyListeners: false);
    notifyListeners();
  }

  Future _postAuth({bool notifyListeners=true}) async {
    _loadCurrUser(notifyListeners: notifyListeners);
    _loadNotificationsExists(notifyListeners: notifyListeners);
    api.websocket.connect();
  }

  Future _loadNotificationsExists({bool notifyListeners=true}) async {
    await api.authUser.notificationsExists().then((ne) => notificationsExists = ne);
    if (notifyListeners)
      this.notifyListeners();
  }

  Future _loadCurrUser({bool notifyListeners=true}) async {
    await api.authUser.me().then((user) => currUser = user);
    if (notifyListeners)
      this.notifyListeners();
  }

  void setAuthToken(String? authToken, {bool store = true}) {
    api = ApiClient(authToken: authToken);
    if (store) {
      writeAuthToken(authToken);
      Logger().i(authToken);
    }
    if (authToken != null)
      _postAuth(notifyListeners: true);
  }

  Future login(String username, String password) async {
    bool isAuthSuc = false;
    await api.auth.login(username, password).then((authToken) {
      setAuthToken(authToken, store: true);
      isAuthSuc = true;
    });
    return isAuthSuc ? Future.value(null) : Future.error({});
  }

  Future<CreateUserResponse> register(String email, String username, String password) async {
    CreateUserResponse? cur;
    JsonData error = {};

    await api.auth.register(email, username, password).then((createUserResponse) {
      setAuthToken(createUserResponse.token, store: true);
      cur = createUserResponse;
    }).catchError((e) {
      error = e;
    });

    return cur != null ? Future.value(cur) : Future.error(error);
  }

  Future<bool> authWithGoogle() async {
    bool isAuthSuc = false;
    bool isCreated = false;

    await api.auth.authWithGoogle().then((authWithGoogleResponse) {
      setAuthToken(authWithGoogleResponse.token, store: true);
      isAuthSuc = true;
      isCreated = authWithGoogleResponse.created;
    });

    return isAuthSuc ? Future.value(isCreated) : Future.error({});
  }

  Future<String> updateProfilePicture(File profilePicture) async {
    if (!api.isAuth)
      return Future.error({});
    await api.auth.updateProfilePicture(profilePicture).then((user) {
      currUser = user;
      notifyListeners();
    });
    return Future.value(currUser!.profileUrl);
  }

  Future<String> updateProfile(Map<String, String?> data) async {
    if (!api.isAuth)
      return Future.error({});
    await api.auth.updateProfile(data).then((user) {
      currUser = user;
      notifyListeners();
    });
    return Future.value(currUser!.profileUrl);
  }

  void logout() {
    deleteAuthToken();
    currUser = null;
    api = ApiClient(authToken: null);
    notifyListeners();
  }

  bool get isAuth =>
    api.isAuth;

  static ApiModel fromContext(BuildContext context, {bool listen=false}) {
    return Provider.of<ApiModel>(context, listen: listen);
  }
}
import 'dart:async';

import 'package:flashbacks/models/user.dart';
import 'package:flashbacks/services/api/client.dart';
import 'package:flashbacks/utils/api/token.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class ApiModel extends ChangeNotifier {
  User? currUser;
  late ApiClient api;

  ApiModel(String? authToken) {
    setAuthToken(authToken);
  }

  void setAuthToken(String? authToken, {bool store = true}) {
    api = ApiClient(authToken: authToken);
    if (store) {
      writeAuthToken(authToken);
    }
  }

  Future login(String username, String password) async {
    bool isAuthSuc = false;
    await api.user.login(username, password).then((authToken) {
      setAuthToken(authToken, store: true);
      isAuthSuc = true;
    });

    if (isAuthSuc) {
      await api.user.me().then((user) => currUser = user);
    }

    notifyListeners();
    return isAuthSuc ? Future.value(null) : Future.error({});
  }

  Future register(String email, String username, String password) async {
    bool isAuthSuc = false;
    await api.user.register(email, username, password).then((authToken) {
      setAuthToken(authToken, store: true);
      isAuthSuc = true;
    });

    if (isAuthSuc) {
      await api.user.me().then((user) => currUser = user);
    }

    notifyListeners();
    return isAuthSuc ? Future.value(null) : Future.error({});
  }

  Future authWithGoogle() async {
    bool isAuthSuc = false;
    await api.user.authWithGoogle().then((authToken) {
      setAuthToken(authToken, store: true);
      isAuthSuc = true;
    });

    if (isAuthSuc) {
      await api.user.me().then((user) => currUser = user);
    }

    notifyListeners();
    return isAuthSuc ? Future.value(null) : Future.error({});
  }

  void logout() {
    deleteAuthToken();
    currUser = null;
    api = ApiClient(authToken: null);
    notifyListeners();
  }

  bool get isAuth =>
    api.isAuth;

  static ApiModel fromContext(BuildContext context, [bool listen=false]) {
    return Provider.of<ApiModel>(context, listen: listen);
  }
}
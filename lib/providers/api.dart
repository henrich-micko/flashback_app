import 'dart:async';

import 'package:flashbacks/models/user.dart';
import 'package:flashbacks/services/api_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';

class ApiModel extends ChangeNotifier {
  BasicUser? me;
  late Future<ApiClient> api = _getApiClient();
  static const storage = FlutterSecureStorage();
  static const tokenStorageKey = "Token";

  ApiModel() {
    api.then((api) => api.user.me().then((me) => this.me = me));
  }

  static Future<ApiClient> _getApiClient() async {
    late Future<ApiClient> apiClient;

    await storage.read(key: tokenStorageKey).then((token) {
      apiClient = Future<ApiClient>.value(ApiClient());
      apiClient.then((api) => api.authToken = token);
    });

    return apiClient;
  }

  Future login(String username, String password) async {
    bool isAuthSuc = false;

    await api.then((api) async {
      // login through api and save token
      await api.user.login(username, password).then((token) {
        if (token != null) {
          isAuthSuc = true;
          api.authToken = token;
          storage.write(key: tokenStorageKey, value: token);
        }
      });
    });

    if (isAuthSuc) {
      await api.then((api) => api.user.me().then((me) => this.me = me));
    }

    notifyListeners();
    return isAuthSuc ? Future.value(null) : Future.error({});
  }

  Future register(String email, String username, String password) async {
    bool isAuthSuc = false;

    await api.then((api) async {
      // login through api and save token
      await api.user.register(email, username, password).then((token) {
        if (token != null) {
          isAuthSuc = true;
          api.authToken = token;
          storage.write(key: tokenStorageKey, value: token);
        }
      });
    });

    if (isAuthSuc) {
      await api.then((api) => api.user.me().then((me) => this.me = me));
    }

    notifyListeners();
    return isAuthSuc ? Future.value(null) : Future.error({});
  }

  void logout() {
    storage.delete(key: tokenStorageKey);
    api.then((api) => api.authToken = null);
    me = null;
    notifyListeners();
  }

  Future<bool> get isAuth async {
    return Future(() => api.then((api) => api.authToken != null));
  }

  static ApiModel fromContext(BuildContext context, [bool listen=false]) {
    return Provider.of<ApiModel>(context, listen: listen);
  }

  static void apiFromContext(BuildContext context, Function(ApiClient) api) {
    ApiModel.fromContext(context, false).api.then(api);
  }
}
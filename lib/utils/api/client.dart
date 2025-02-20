import 'package:flashbacks/utils/api/pagination.dart';
import 'package:flashbacks/utils/api/token.dart';
import 'package:flashbacks/utils/models.dart';
import 'dart:convert';
import 'package:flashbacks/utils/api/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;


// types def
typedef ItemFromJson<T> = T Function(Map<String, dynamic> json); // Function to generate item from json
typedef JsonData = Map<String, dynamic>;
typedef GetData = Map<String, String>;


abstract class BaseApiClient {
  @protected
  Token? authToken;
  final Uri apiBaseUrl;

  BaseApiClient({required this.apiBaseUrl, required this.authToken});

  bool get isAuth
    => authToken != null;

  @protected
  Map<String, String> getHeaders() {
    var headers = {
      "Accept": "application/json", 'Content-Type':
      'application/json; charset=UTF-8'
    };

    if (authToken != null) headers["Authorization"] = "Token $authToken";
    return headers;
  }

  @protected
  Uri resolveUrl(String path) {
    return apiBaseUrl.resolve(path);
  }

  @protected
  Future<Iterable<T>> getItems<T>(String path, ItemFromJson<T> itemFromJson, {GetData filter = const {}}) async {
    return getRequest(path, data: filter).then((data) {
      List<dynamic> items = json.decode(data);
      return items.map((item) => itemFromJson(item));
    });
  }

  // get items wrapped in cursor pagination
  @protected
  Future<Pagination<T>> getItemsPagination<T>(String path, ItemFromJson<T> itemFromJson, {GetData filter = const {}}) async {
    return getRequest(path, data: filter).then((data) {
      JsonData resp = json.decode(data);
      return Pagination.fromJson<T>(resp, itemFromJson);
    });
  }

  @protected
  Future<T> getItem<T>(String path, ItemFromJson<T> itemFromJson) async {
    return getRequest(path).then((data) {
      Map<String, dynamic> item = json.decode(data);
      return itemFromJson(item);
    });
  }

  @protected
  Future deleteItem(String path) async {
    return deleteRequest(path);
  }

  @protected
  Future<T> patchItem<T>(String path, JsonData data, ItemFromJson<T> itemFromJson) async {
    return patchRequest(path, data: data).then((data) {
      Map<String, dynamic> item = json.decode(data);
      return itemFromJson(item);
    });
  }

  @protected
  Future<String> getRequest(String path, {GetData data = const {}, int status=200}) async {
    final response = await http.get(
        resolveUrl(path).resolve(generateGetParamsString(data)), headers: getHeaders()
    );
    if (response.statusCode != status)
      return Future.error(
          response.statusCode != 204 ? json.decode(response.body) : response.body
      );
    return response.body;
  }

  @protected
  Future<String> deleteRequest(String path, {int status=204}) async {
    final response = await http.delete(resolveUrl(path), headers: getHeaders());
    if (response.statusCode != status)
      return Future.error(response.statusCode != 204 ? json.decode(response.body) : response.body);
    return response.body;
  }

  @protected
  Future<String> postRequest(String path, {JsonData data = const {}, int status=201}) async {
    final response = await http.post(resolveUrl(path), headers: getHeaders(), body: jsonEncode(data));
    if (response.statusCode != status)
      return Future.error(response.statusCode != 204 ? json.decode(response.body) : response.body);
    return response.body;
  }

  @protected
  Future<String> patchRequest(String path, {JsonData data = const {}, int status=200}) async {
    final response = await http.patch(resolveUrl(path), headers: getHeaders(), body: jsonEncode(data));
    if (response.statusCode != status)
      return Future.error(response.statusCode != 204 ? json.decode(response.body) : response.body);
    return response.body;
  }

  @protected
  Future<String> putRequest(String path, {JsonData data = const {}, int status=200}) async {
    final response = await http.put(resolveUrl(path), headers: getHeaders(), body: jsonEncode(data));
    if (response.statusCode != status)
      return Future.error(response.statusCode != 204 ? json.decode(response.body) : response.body);
    return response.body;
  }
}


abstract class BaseApiModelClient<T extends BaseModel> extends BaseApiClient {
  abstract String modelPath;
  T itemFromJson(Map<String, dynamic> json);

  BaseApiModelClient({required super.apiBaseUrl, required super.authToken});

  get modelUrl => resolveUrl(modelPath);

  String modelUrlWith(String path) {
    if (path.startsWith("/"))
      path = path.replaceFirst("/", "");
    return "$modelUrl$path";
  }
}


abstract class BaseApiModelDetailClient<T extends BaseModel> extends BaseApiModelClient<T> {
  final int detailPk;

  BaseApiModelDetailClient({required super.apiBaseUrl, required super.authToken, required this.detailPk}) {
    if (modelPath.contains("{detailPk}")) {
      modelPath = modelPath.replaceFirst("{detailPk}", detailPk.toString());
    } else {
      modelPath = Uri.parse(modelPath).resolve(detailPk.toString()).toString();
    }
  }
}


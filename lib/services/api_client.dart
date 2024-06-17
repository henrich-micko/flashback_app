import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flashbacks/models/event.dart';
import 'package:flashbacks/models/flashback.dart';
import 'package:flashbacks/models/user.dart';
import 'package:flashbacks/utils/api.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logger/logger.dart';

class ApiClient extends ApiApplicationClient {
  late EventApiClient event;
  late UserApiClient user;

  ApiClient() : super(apiBaseUrl: dotenv.get("API_BASE_URL", fallback: "http://0.0.0.0:8000/api")) {
    event = EventApiClient(apiBaseUrl: apiBaseUrl);
    user = UserApiClient(apiBaseUrl: apiBaseUrl);
  }

  @override
  set authToken(String? token) {
    super.authToken = token;
    event.authToken = token;
    user.authToken = token;
  }

  String getUrl(String url) {
    final base = apiBaseUrl.replaceFirst("api", "");
    return "$base$url";
  }
}

class EventApiClient extends ApiApplicationClient {
  late EventMemberApiClient member;
  late EventFlashbackApiClient flashback;

  EventApiClient({required super.apiBaseUrl}) {
    member = EventMemberApiClient(apiBaseUrl: apiBaseUrl);
    flashback = EventFlashbackApiClient(apiBaseUrl: apiBaseUrl);
  }

  @override
  set authToken(String? token) {
    super.authToken = token;
    member.authToken = token;
    flashback.authToken = token;
  }

  Future<Iterable<Event>> all() async {
    final response = await http.get(Uri.parse("$apiBaseUrl/event/"), headers: getHeaders());
    preventValidResponse(response, 200);
    final List<dynamic> data = json.decode(response.body);
    return data.map((item) => Event.fromJson(item));
  }

  Future<Event> get(int pk) async {
    final response = await http.get(Uri.parse("$apiBaseUrl/event/$pk/"), headers: getHeaders());
    preventValidResponse(response, 200);
    final Map<String, dynamic> data = json.decode(response.body);
    return Event.fromJson(data);
  }

  Future<Event> close(int pk) async {
    final response = await http.post(Uri.parse("$apiBaseUrl/event/$pk/close/"), headers: getHeaders());
    preventValidResponse(response, 200);
    final Map<String, dynamic> data = json.decode(response.body);
    return Event.fromJson(data);
  }

  Future delete(int pk) async {
    final response = await http.delete(Uri.parse("$apiBaseUrl/event/$pk/"), headers: getHeaders());
    preventValidResponse(response, 204);
  }

  Future<Event> create(String emojiName, String title, DateTime startAt, DateTime endAt, List<int> users) async {
    final response = await http.post(
        Uri.parse("$apiBaseUrl/event/"),
        headers: getHeaders(),
        body: jsonEncode({
          "emoji": emojiName,
          "title": title,
          "start_at": startAt.toString(),
          "end_at": endAt.toString()
        })
    );

    preventValidResponse(response, 201);
    final Map<String, dynamic> data = json.decode(response.body);
    final event = Event.fromJson(data);

    // Add members to event
    for (int userId in users) {
     await member.add(event.id, userId);
    }

    return event;
  }
}

class EventFlashbackApiClient extends ApiApplicationClient {
  EventFlashbackApiClient({required super.apiBaseUrl});

  Future<BasicFlashback> create(int eventId, File media) async {
    String fileName = media.path.split("/").last;

    FormData formData = FormData.fromMap({
      "media": await MultipartFile.fromFile(media.path, filename: fileName),
    });

    final response = await Dio().post("$apiBaseUrl/event/$eventId/flashback/", data: formData, options: Options(headers: getHeaders()));
    Logger().d(response.data);
    final Map<String, dynamic> data = json.decode(response.data);

    if (response.statusCode != 201) {
      return Future.error(data);
    }

    return BasicFlashback.fromJson(data);
  }

  Future<Iterable<BasicFlashback>> all(int eventPk) async {
    final response = await http.get(Uri.parse("$apiBaseUrl/event/$eventPk/flashback/"), headers: getHeaders());
    preventValidResponse(response, 200);
    final List<dynamic> data = json.decode(response.body);
    Logger().d(data);
    return data.map((item) => BasicFlashback.fromJson(item));
  }
}

class EventMemberApiClient extends ApiApplicationClient {
  EventMemberApiClient({required super.apiBaseUrl});

  Future<Iterable<EventMember>> all(int eventPk) async {
    final response = await http.get(Uri.parse("$apiBaseUrl/event/$eventPk/member/"), headers: getHeaders());
    preventValidResponse(response, 200);
    final List<dynamic> data = json.decode(response.body);
    return data.map((item) => EventMember.fromJson(item));
  }

  Future<EventMember> get(int eventPk, int userPk) async {
    final response = await http.get(Uri.parse("$apiBaseUrl/event/$eventPk/member/$userPk"), headers: getHeaders());
    preventValidResponse(response, 200);
    return EventMember.fromJson(json.decode(response.body));
  }

  Future delete(int eventPk, int userPk) async {
    final response = await http.delete(Uri.parse("$apiBaseUrl/event/$eventPk/member/$userPk/"), headers: getHeaders());
    preventValidResponse(response, 204);
  }

  Future<Iterable<EventMember>> add(int eventPk, int userPk) async {
    final response = await http.post(Uri.parse("$apiBaseUrl/event/$eventPk/member/$userPk/add/"), headers: getHeaders());
    preventValidResponse(response, 201);
    final List<dynamic> data = json.decode(response.body);
    return data.map((item) => EventMember.fromJson(item));
  }

  Future<Iterable<PossibleEventMember>> possible(int eventPk) async {
    final response = await http.get(Uri.parse("$apiBaseUrl/event/$eventPk/member/possible/"), headers: getHeaders());
    preventValidResponse(response, 200);
    final List<dynamic> data = json.decode(response.body);
    return data.map((item) => PossibleEventMember.fromJson(item));
  }
}

class UserApiClient extends ApiApplicationClient {
  late FriendApiClient friend;

  UserApiClient({required super.apiBaseUrl}) {
    friend = FriendApiClient(apiBaseUrl: apiBaseUrl);
  }

  @override
  set authToken(String? token) {
    super.authToken = token;
    friend.authToken = token;
  }

  Future<BasicUser> me() async {
    final response = await http.get(Uri.parse("$apiBaseUrl/user/me"), headers: getHeaders());
    preventValidResponse(response, 200);
    final Map<String, dynamic> data = json.decode(response.body);
    return BasicUser.fromJson(data);
  }

  Future<Iterable<FriendRequest>> requests() async {
    final response = await http.get(Uri.parse("$apiBaseUrl/user/requests"), headers: getHeaders());
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((item) => FriendRequest.fromJson(item));
    }
    return Future.error({});
  }

  Future<UserPov> get(int userId) async {
    final response = await http.get(Uri.parse("$apiBaseUrl/user/$userId"), headers: getHeaders());
    preventValidResponse(response, 200);
    final Map<String, dynamic> data = json.decode(response.body);
    return UserPov.fromJson(data);
  }

  Future<Iterable<UserPov>> all() async {
    final response = await http.get(Uri.parse("$apiBaseUrl/user/"), headers: getHeaders());
    preventValidResponse(response, 200);
    final List<dynamic> data = json.decode(response.body);
    return data.map((item) => UserPov.fromJson(item));
  }

  Future<Iterable<BasicUser>> search(String value) async {
    final response = await http.get(Uri.parse("$apiBaseUrl/user/search?value=$value"), headers: getHeaders());
    preventValidResponse(response, 200);
    final List<dynamic> data = json.decode(response.body);
    return data.map((item) => BasicUser.fromJson(item));
  }

  Future<String?> login(String username, String password) async {
    final response = await http.post(
        Uri.parse("$apiBaseUrl/user/login/"),
        headers: getHeaders(),
        body: jsonEncode({
          "username": username,
          "password": password,
        })
    );

    Map<String, dynamic> data = jsonDecode(response.body);
    if (response.statusCode != 200) return Future.error(response.body);
    return data["token"];
  }

  Future<String?> register(String email, String username, String password) async {
    final response = await http.post(
        Uri.parse("$apiBaseUrl/user/"),
        headers: getHeaders(),
        body: jsonEncode({
          "email": email,
          "username": username,
          "password": password,
        })
    );

    Map<String, dynamic> data = jsonDecode(response.body);
    if (response.statusCode != 201) return Future.error(response.body);
    return data["token"];
  }
}

class FriendApiClient extends ApiApplicationClient {
  FriendApiClient({required super.apiBaseUrl});

  Future<Iterable<UserPov>> all(int userId) async {
    final response = await http.get(Uri.parse("$apiBaseUrl/user/friend/$userId"), headers: getHeaders());
    preventValidResponse(response, 200);
    final List<dynamic> data = json.decode(response.body);
    return data.map((item) => UserPov.fromJson(item));
  }

  Future<Iterable<UserPov>> my() async {
    final response = await http.get(Uri.parse("$apiBaseUrl/user/my_friends/"), headers: getHeaders());
    preventValidResponse(response, 200);
    final List<dynamic> data = json.decode(response.body);
    return data.map((item) => UserPov.fromJson(item));
  }

  Future sendRequest(int toUser) async {
    final response = await http.post(Uri.parse("$apiBaseUrl/user/$toUser/friend/"), headers: getHeaders());
    if (response.statusCode == 200 || response.statusCode == 201) return Future.value();
    return Future.error({});
  }

  Future acceptRequest(int toUser) async {
    final response = await http.put(Uri.parse("$apiBaseUrl/user/$toUser/friend/"), headers: getHeaders());
    if (response.statusCode == 200) return Future.value();
    return Future.error({});
  }

  Future deleteRequestOrFriendship(int toUser) async {
    final response = await http.delete(Uri.parse("$apiBaseUrl/user/$toUser/friend/"), headers: getHeaders());
    if (response.statusCode == 204) return Future.value();
    return Future.error({});
  }
}
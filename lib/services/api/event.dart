import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flashbacks/models/chat.dart';
import 'package:flashbacks/models/event.dart';
import 'package:flashbacks/models/flashback.dart';
import 'package:flashbacks/models/user.dart';
import 'package:flashbacks/utils/api/client.dart';
import 'package:flashbacks/utils/api/mixins.dart';
import 'dart:io';

import 'package:flashbacks/utils/api/pagination.dart';


class EventApiDetailClient extends BaseApiModelDetailClient<Event> with ApiDetModelDeleteMixin<Event>,
                                                                        ApiDetModelGetMixin<Event>,
                                                                        ApiDetModelPatchMixin<Event> {
  late EventFlashbackApiClient flashback;
  late EventMemberApiClient member;
  late EventChatApiClient chat;

  @override
  String modelPath = "api/event/{detailPk}/";

  @override
  Event itemFromJson(Map<String, dynamic> json) => Event.fromJson(json);

  EventApiDetailClient({required super.apiBaseUrl, required super.detailPk, required super.authToken}) {
    flashback = EventFlashbackApiClient(apiBaseUrl: apiBaseUrl, eventPk: detailPk, authToken: authToken);
    member = EventMemberApiClient(apiBaseUrl: apiBaseUrl, eventPk: detailPk, authToken: authToken);
    chat = EventChatApiClient(apiBaseUrl: apiBaseUrl, eventPk: detailPk, authToken: authToken);
  }

  Future<Event> close() async {
    final response = await postRequest("${modelPath}close/");
    final Map<String, dynamic> data = json.decode(response);
    return itemFromJson(data);
  }

  Future<Iterable<EventMember>> getFriendsMembers() {
    return getItems<EventMember>("${modelPath}get_friends_members/", EventMember.fromJson);
  }
}


class EventApiClient extends BaseApiModelClient<Event> with ApiModelAllMixin<Event>,
                                                            ApiModelGetMixin<Event>,
                                                            ApiModelFilterMixin<Event>,
                                                            ApiModelDeleteMixin<Event> {

  EventApiClient({required super.apiBaseUrl, required super.authToken});

  @override
  String modelPath = "api/event/";

  @override
  Event itemFromJson(Map<String, dynamic> json) => Event.fromJson(json);

  EventApiDetailClient detail(int detailPk)
    => EventApiDetailClient(apiBaseUrl: apiBaseUrl, detailPk: detailPk, authToken: authToken);

  Future<Event> create(String emojiName, String title, DateTime startAt, DateTime endAt) async {
    final createData = {
      "emoji": emojiName,
      "title": title,
      "start_at": startAt.toString(),
      "end_at": endAt.toString()
    };

    final response = await postRequest(modelPath, data: createData);
    final Map<String, dynamic> data = json.decode(response);
    return itemFromJson(data);
  }

  Future<Iterable<EventViewer>> toView() {
    return getItems<EventViewer>("${modelPath}to_view/", EventViewer.fromJson);
  }

  Future validateDates(DateTime startAt, DateTime endAt) async {


    final response = await postRequest(modelUrlWith("validate_dates?start_at="));
    final Map<String, dynamic> data = json.decode(response);

  }
}


class EventFlashbackApiClient extends BaseApiModelClient<BasicFlashback> with ApiModelAllMixin<BasicFlashback> {
  int eventPk;

  @override
  String modelPath = "api/event/{eventPk}/flashback";

  @override
  BasicFlashback itemFromJson(Map<String, dynamic> json) => BasicFlashback.fromJson(json);

  EventFlashbackApiClient({required super.apiBaseUrl, required this.eventPk, required super.authToken}) {
    modelPath = modelPath.replaceFirst("{eventPk}", eventPk.toString());
  }

  Future<BasicFlashback> create(File media) async {
    String fileName = media.path.split("/").last;

    FormData formData = FormData.fromMap({
      "media": await MultipartFile.fromFile(media.path, filename: fileName),
    });

    final response = await Dio().post(modelPath, data: formData, options: Options(headers: getHeaders()));
    final Map<String, dynamic> data = json.decode(response.data);

    if (response.statusCode != 201) {
      return Future.error(data);
    }

    return BasicFlashback.fromJson(data);
  }
}


class EventMemberApiClient extends BaseApiModelClient<EventMember> with ApiModelAllMixin<EventMember>,
                                                                        ApiModelGetMixin<EventMember> {
  int eventPk;

  @override
  String modelPath = "api/event/{eventPk}/member/";

  @override
  EventMember itemFromJson(Map<String, dynamic> json) => EventMember.fromJson(json);

  EventMemberApiClient({required super.apiBaseUrl, required this.eventPk, required super.authToken}) {
    modelPath = modelPath.replaceFirst("{eventPk}", eventPk.toString());
  }

  Future<Iterable<EventMember>> add(int userPk) async {
    final response = await postRequest("$modelPath$userPk/add/");
    final List<dynamic> data = json.decode(response);
    return data.map((item) => EventMember.fromJson(item));
  }

  Future<Iterable<User>> possible() async {
    return getItems<User>("${modelPath}possible/", User.fromJson);
  }

  Future delete(int userPk) async {
    return deleteItem("$modelPath$userPk/");
  }
}


class EventChatApiClient extends BaseApiModelClient<Message> with ApiModelGetMixin<Message> {
  int eventPk;

  @override
  String modelPath = "api/event/{eventPk}/chat/";

  @override
  Message itemFromJson(Map<String, dynamic> json) => Message.fromJson(json);

  EventChatApiClient({required super.apiBaseUrl, required this.eventPk, required super.authToken}) {
    modelPath = modelPath.replaceFirst("{eventPk}", eventPk.toString());
  }

  Future<Pagination<Message>> all({String? path}) {
    return getItemsPagination<Message>(path ?? modelPath, itemFromJson);
  }
}
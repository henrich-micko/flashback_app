import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flashbacks/models/chat.dart';
import 'package:flashbacks/models/event.dart';
import 'package:flashbacks/models/flashback.dart';
import 'package:flashbacks/utils/api/client.dart';
import 'package:flashbacks/utils/api/mixins.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'dart:io';
import 'package:http/http.dart' as http;

import 'package:flashbacks/utils/api/pagination.dart';
import 'package:permission_handler/permission_handler.dart';

Future<bool> requestStoragePermission() async {
  var status = await Permission.storage.request();
  return status.isGranted;
}


class EventApiDetailClient extends BaseApiModelDetailClient<Event> with ApiDetModelDeleteMixin<Event>,
                                                                        ApiDetModelGetMixin<Event>,
                                                                        ApiDetModelPatchMixin<Event> {
  late EventFlashbackApiClient flashback;
  late EventMemberApiClient member;
  late EventChatApiClient chat;

  @override
  String modelPath = "api/event/{detailPk}/";
  String wsChatPath = "ws/event/{detailPk}/chat/";

  @override
  Event itemFromJson(Map<String, dynamic> json) => Event.fromJson(json);

  EventApiDetailClient({required super.apiBaseUrl, required super.detailPk, required super.authToken}) {
    flashback = EventFlashbackApiClient(apiBaseUrl: apiBaseUrl, eventPk: detailPk, authToken: authToken);
    member = EventMemberApiClient(apiBaseUrl: apiBaseUrl, eventPk: detailPk, authToken: authToken);
    chat = EventChatApiClient(apiBaseUrl: apiBaseUrl, eventPk: detailPk, authToken: authToken);

    wsChatPath = wsChatPath.replaceFirst("{detailPk}", super.detailPk.toString());
  }

  Future<Event> close() async {
    final response = await postRequest("${modelPath}close/");
    final Map<String, dynamic> data = json.decode(response);
    return itemFromJson(data);
  }

  Future<Iterable<EventMember>> getFriendsMembers() {
    return getItems<EventMember>("${modelPath}get_friends_members/", EventMember.fromJson);
  }

  Future<EventViewer> markAsOpen() {
    return getItem<EventViewer>("${modelPath}mark_as_open/", EventViewer.fromJson);
  }

  Future downloadPosterPdf(int templateId, int colorId) async {
    final taskId = await FlutterDownloader.enqueue(
      url: resolveUrl("${modelPath}poster_generate/?template=$templateId&color=$colorId&?file_type=pdf").toString(),
      fileName: "poster.pdf",
      headers: getHeaders(),
      savedDir: '/storage/emulated/0/Download',
      showNotification: true, // show download progress in status bar (for Android)
      openFileFromNotification: true, // click on notification to open downloaded file (for Android)
    );
  }

  Future<String> generatePosterHtml(int templateId, int colorId) async {
    final response = await http.get(
        resolveUrl("${modelPath}poster_generate/?template=$templateId&color=$colorId&?file_type=html"), headers: getHeaders()
    );

    if (response.statusCode != 200)
      return Future.error(response.statusCode != 204 ? json.decode(response.body) : response.body);
    return response.body;
  }
}


class EventApiClient extends BaseApiModelClient<Event> with ApiModelAllMixin<Event>,
                                                            ApiModelGetMixin<Event>,
                                                            ApiModelFilterMixin<Event>,
                                                            ApiModelDeleteMixin<Event>,
                                                            ApiModelSearchMixin<Event> {

  EventApiClient({required super.apiBaseUrl, required super.authToken});

  @override
  String modelPath = "api/event/";

  @override
  Event itemFromJson(Map<String, dynamic> json) => Event.fromJson(json);

  EventApiDetailClient detail(int detailPk)
    => EventApiDetailClient(
        apiBaseUrl: apiBaseUrl,
        detailPk: detailPk,
        authToken: authToken
    );

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

  Future<Iterable<EventViewer>> toView({String? search, bool? isMember}) {
    Map<String, String> filter = {};
    if (search != null) filter["q"] = search;
    if (isMember != null) filter["is_member"] = isMember.toString();

    return getItems<EventViewer>(
        "${modelPath}to_view/", EventViewer.fromJson, filter: filter
    );
  }

  Future validateDates(DateTime startAt, DateTime endAt) async {
    final response = await postRequest(modelUrlWith("validate_dates?start_at="));
    final Map<String, dynamic> data = json.decode(response);
  }

  Future<Event> currEvent() {
    return getItem<Event>("${modelPath}curr_event/", Event.fromJson);
  }

  Future<Iterable<EventPosterTemplate>> posterTemplates() {
    return getItems<EventPosterTemplate>(
        "${modelPath}poster_templates/", EventPosterTemplate.fromJson
    );
  }
}


class EventFlashbackApiClient extends BaseApiModelClient<BasicFlashback> with ApiModelAllMixin<BasicFlashback> {
  int eventPk;

  @override
  String modelPath = "api/event/{eventPk}/flashback/";

  @override
  BasicFlashback itemFromJson(Map<String, dynamic> json) => BasicFlashback.fromJson(json);

  EventFlashbackApiClient({required super.apiBaseUrl, required this.eventPk, required super.authToken}) {
    modelPath = modelPath.replaceFirst("{eventPk}", eventPk.toString());
  }

  Future create(File media) async {
    String fileName = media.path.split("/").last;

    FormData formData = FormData.fromMap({
      "media": await MultipartFile.fromFile(media.path, filename: fileName),
    });

    final response = await Dio().post(resolveUrl(modelPath).toString(), data: formData, options: Options(headers: getHeaders()));
    if (response.statusCode != 201) {
      return Future.error({});
    }
    return Future.value({});
  }
}


class EventMemberApiClient extends BaseApiModelClient<EventMember> with ApiModelAllMixin<EventMember> {
  int eventPk;

  @override
  String modelPath = "api/event/{eventPk}/member/";

  @override
  EventMember itemFromJson(Map<String, dynamic> json) => EventMember.fromJson(json);

  EventMemberApiClient({required super.apiBaseUrl, required this.eventPk, required super.authToken}) {
    modelPath = modelPath.replaceFirst("{eventPk}", eventPk.toString());
  }

  Future invite(int userPk) async {
    await getRequest("${modelPath}invite/?user=$userPk");
  }

  Future deleteInvite(int userPk) async {
    await getRequest("${modelPath}delete_invite/?user=$userPk");
  }

  Future acceptInvite() async {
    await getRequest("${modelPath}accept_invite/");
  }

  Future declineInvite() async {
    await getRequest("${modelPath}accept_invite/");
  }

  Future<Iterable<EventInvite>> invites() {
    return getItems<EventInvite>("${modelPath}invites/", EventInvite.fromJson);
  }

  Future<Iterable<EventPossibleMember>> possible({String? search}) async {
    return getItems<EventPossibleMember>(
        "${modelPath}possible/", EventPossibleMember.fromJson,
        filter: search != null ? {"search": search} : {}
    );
  }

  Future delete(int userPk) async {
    return deleteItem("$modelPath$userPk/");
  }

  Future<EventMember> get(int userPk) async {
    return getItem("$modelPath$userPk/", itemFromJson);
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
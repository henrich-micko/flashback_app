import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flashbacks/models/user.dart';
import 'package:flashbacks/utils/api/client.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;


class AuthWithGoogleResponse {
  final String token;
  final bool created;

  AuthWithGoogleResponse({required this.token, required this.created});
}

class AuthApiClient extends BaseApiClient {
  AuthApiClient({required super.authToken, required super.apiBaseUrl});

  Future<String?> login(String username, String password) async {
    final response = await http.post(
        Uri.parse("${apiBaseUrl}api/user/auth/"),
        headers: getHeaders(),
        body: jsonEncode({
          "username": username,
          "password": password,
        })
    );

    Map<String, dynamic> data = jsonDecode(response.body);
    if (response.statusCode != 200) return Future.error(data);
    return data["token"];
  }

  Future<CreateUserResponse> register(String email, String username, String password) async {
    final response = await http.post(
        Uri.parse("${apiBaseUrl}api/user/users/"),
        headers: getHeaders(),
        body: jsonEncode({
          "email": email,
          "username": username,
          "password": password,
        })
    );

    Map<String, dynamic> data = jsonDecode(response.body);
    if (response.statusCode != 201) return Future.error(data);
    return CreateUserResponse.fromJson(data);
  }

  Future<AuthWithGoogleResponse> authWithGoogle() async {
    final GoogleSignIn googleSignIn = GoogleSignIn(
      scopes: ['email'],
    );

    // TODO: ios integration (needs client id)

    try {
      final GoogleSignInAccount? account = await googleSignIn.signIn();
      final GoogleSignInAuthentication googleAuth = await account!.authentication;

      final response = await postRequest("/api/user/auth/google/", data: {'auth_token': googleAuth.accessToken});

      final data = json.decode(response);
      return AuthWithGoogleResponse(
          token: data["token"] as String,
          created: data["created"] as bool
      );

    } catch (e) {
      return Future.error(e);
    }
  }

  Future<MiniUser> updateProfilePicture(File media) async {
    String fileName = media.path.split("/").last;

    FormData formData = FormData.fromMap({
      "profile": await MultipartFile.fromFile(media.path, filename: fileName),
    });

    final response = await Dio().post(
        resolveUrl("${apiBaseUrl}api/user/auth_user/update_profile_picture/").toString(),
        data: formData,
        options: Options(headers: getHeaders())
    );

    if (response.statusCode != 200)
      return Future.error({});
    return Future.value(MiniUser.fromJson(response.data));
  }
  
  Future<MiniUser> updateProfile(Map<String, String?> data) async {
     return patchRequest("/api/user/auth_user/update_profile/", data: data).then((data) {
       Map<String, dynamic> item = json.decode(data);
       return MiniUser.fromJson(item);
     });
  }
}
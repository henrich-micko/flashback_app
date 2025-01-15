import 'dart:convert';
import 'package:flashbacks/utils/api/client.dart';
import 'package:flashbacks/utils/api/utils.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:flashbacks/models/user.dart';


class UserApiClient extends BaseApiClient {
  late FriendApiClient friend;

  UserApiClient({required super.apiBaseUrl, required super.authToken}) {
    friend = FriendApiClient(apiBaseUrl: apiBaseUrl, authToken: authToken);
  }

  Future<AnonymousUserData> anonymous() async {
    final response = await http.get(Uri.parse("$apiBaseUrl/user/anonymous/"), headers: getHeaders());
    preventValidResponse(response, 200);
    final Map<String, dynamic> data = json.decode(response.body);
    return AnonymousUserData.fromJson(data);
  }

  Future<User> me() async {
    final response = await http.get(Uri.parse("$apiBaseUrl/user/me/"), headers: getHeaders());
    preventValidResponse(response, 200);
    final Map<String, dynamic> data = json.decode(response.body);
    return User.fromJson(data);
  }

  Future<Iterable<FriendRequest>> requests() async {
    final response = await http.get(Uri.parse("$apiBaseUrl/api/user/requests"), headers: getHeaders());
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((item) => FriendRequest.fromJson(item));
    }
    return Future.error({});
  }

  Future<UserPov> get(int userId) async {
    final response = await http.get(Uri.parse("$apiBaseUrl/api/user/$userId"), headers: getHeaders());
    preventValidResponse(response, 200);
    final Map<String, dynamic> data = json.decode(response.body);
    return UserPov.fromJson(data);
  }

  Future<Iterable<UserPov>> all() async {
    final response = await http.get(Uri.parse("$apiBaseUrl/api/user/"), headers: getHeaders());
    preventValidResponse(response, 200);
    final List<dynamic> data = json.decode(response.body);
    return data.map((item) => UserPov.fromJson(item));
  }

  Future<Iterable<User>> search(String value) async {
    final response = await http.get(Uri.parse("$apiBaseUrl/api/user/search?value=$value"), headers: getHeaders());
    preventValidResponse(response, 200);
    final List<dynamic> data = json.decode(response.body);
    return data.map((item) => User.fromJson(item));
  }

  Future<String?> login(String username, String password) async {
    final response = await http.post(
        Uri.parse("$apiBaseUrl/api/user/login/"),
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
        Uri.parse("$apiBaseUrl/api/user/"),
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

  Future<String?> authWithGoogle() async {
    final GoogleSignIn googleSignIn = GoogleSignIn(
      scopes: ['email'],
    );

    // TODO: ios integration (needs client id)

    try {
      final GoogleSignInAccount? account = await googleSignIn.signIn();
      final GoogleSignInAuthentication googleAuth = await account!.authentication;

      final response = await postRequest("/api/user/auth/google/", data: {'auth_token': googleAuth.accessToken});

      final data = json.decode(response);
      final String token = data['token'];
      return token;

    } catch (e) {
      return Future.error(e);
    }
  }
}

class FriendApiClient extends BaseApiClient {
  FriendApiClient({required super.apiBaseUrl, required super.authToken});

  Future<Iterable<UserPov>> all(int userId) async {
    final response = await http.get(Uri.parse("$apiBaseUrl/api/user/friend/$userId"), headers: getHeaders());
    preventValidResponse(response, 200);
    final List<dynamic> data = json.decode(response.body);
    return data.map((item) => UserPov.fromJson(item));
  }

  Future<Iterable<UserPov>> my() async {
    final response = await http.get(Uri.parse("$apiBaseUrl/api/user/my_friends/"), headers: getHeaders());
    preventValidResponse(response, 200);
    final List<dynamic> data = json.decode(response.body);
    return data.map((item) => UserPov.fromJson(item));
  }

  Future sendRequest(int toUser) async {
    final response = await http.post(Uri.parse("$apiBaseUrl/api/user/$toUser/friend/"), headers: getHeaders());
    if (response.statusCode == 200 || response.statusCode == 201) return Future.value();
    return Future.error({});
  }

  Future acceptRequest(int toUser) async {
    final response = await http.put(Uri.parse("$apiBaseUrl/api/user/$toUser/friend/"), headers: getHeaders());
    if (response.statusCode == 200) return Future.value();
    return Future.error({});
  }

  Future deleteRequestOrFriendship(int toUser) async {
    final response = await http.delete(Uri.parse("$apiBaseUrl/api/user/$toUser/friend/"), headers: getHeaders());
    if (response.statusCode == 204) return Future.value();
    return Future.error({});
  }
}

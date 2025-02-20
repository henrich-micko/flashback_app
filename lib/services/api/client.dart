import 'package:flashbacks/services/api/auth.dart';
import 'package:flashbacks/services/api/event.dart';
import 'package:flashbacks/services/api/user.dart';
import 'package:flashbacks/services/websockets/client.dart';
import 'package:flashbacks/utils/api/client.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';


class ApiClient extends BaseApiClient {
  late EventApiClient event;
  late UserApiClient user;
  late AuthApiClient auth;
  late AuthUserApiClient authUser;
  late ClientWebSocketService websocket;

  ApiClient({ required super.authToken }) : super(apiBaseUrl: Uri.parse(dotenv.get("API_BASE_URL", fallback: "http://0.0.0.0:8000/"))) {
    event = EventApiClient(apiBaseUrl: apiBaseUrl, authToken: authToken);
    user = UserApiClient(apiBaseUrl: apiBaseUrl, authToken: authToken);
    auth = AuthApiClient(authToken: authToken, apiBaseUrl: apiBaseUrl);
    authUser = AuthUserApiClient(apiBaseUrl: apiBaseUrl, authToken: authToken);
    websocket = ClientWebSocketService(socketEndPoint: getWebSocketEndPoint(), authToken: authToken);
  }

  Uri getWebSocketEndPoint() {
    String apiBaseHttpUrl = apiBaseUrl.toString();
    apiBaseHttpUrl = apiBaseHttpUrl.startsWith("http")
                        ? apiBaseHttpUrl.replaceFirst("http", "ws")
                        : apiBaseHttpUrl.replaceFirst("https", "wss");
    return Uri.parse(apiBaseHttpUrl).resolve("ws");
  }
}

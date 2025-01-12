import 'package:flashbacks/services/api/event.dart';
import 'package:flashbacks/services/api/user.dart';
import 'package:flashbacks/utils/api/client.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';


class ApiClient extends BaseApiClient {
  late EventApiClient event;
  late UserApiClient user;

  ApiClient({ required super.authToken }) : super(apiBaseUrl: Uri.parse(dotenv.get("API_BASE_URL", fallback: "http://0.0.0.0:8000/"))) {
    event = EventApiClient(apiBaseUrl: apiBaseUrl, authToken: authToken);
    user = UserApiClient(apiBaseUrl: apiBaseUrl, authToken: authToken);
  }
}

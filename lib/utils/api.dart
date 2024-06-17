import 'package:logger/logger.dart';
import 'package:http/http.dart' as http;

void preventValidResponse(http.Response response, int expectedStatus) {
  if (response.statusCode != expectedStatus) {
    Logger().e("Response status/body: ${response.statusCode}/${response.body} Expected status: $expectedStatus");
    throw Exception("Invalid response status code: ${response.statusCode} (expected $expectedStatus).");
  }
}

abstract class ApiApplicationClient {
  String? _authToken;
  final String apiBaseUrl;

  ApiApplicationClient({required this.apiBaseUrl});

  String? get authToken => _authToken;
  set authToken(String? token) => _authToken = token;

  // Get basic headers for request
  Map<String, String> getHeaders() {
    var headers = {
      "Accept": "application/json", 'Content-Type':
      'application/json; charset=UTF-8'
    };

    if (_authToken != null) headers["Authorization"] = "Token $_authToken";
    return headers;
  }

  Future waitForToken() async {
    while (true) {
      if (authToken != null) break;
    }
  }
}
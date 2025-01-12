import 'package:logger/logger.dart';
import 'package:http/http.dart' as http;


void preventValidResponse(http.Response response, int expectedStatus) {
  if (response.statusCode != expectedStatus) {
    Logger().e("Response status/body: ${response.statusCode}/${response.body} Expected status: $expectedStatus");
    throw Exception("Invalid response status code: ${response.statusCode} (expected $expectedStatus).");
  }
}

String generateGetParamsString(Map<String, String> params) {
  return params.entries
      .map((entry) => "?${entry.key}=${entry.value}")
      .join("");
}
import 'package:flutter_secure_storage/flutter_secure_storage.dart';


const String authTokenStorageKey = "Token";
typedef Token = String?;

Future<Token> readAuthToken() async =>
  await const FlutterSecureStorage().read(key: authTokenStorageKey);

void writeAuthToken(Token authToken) =>
    const FlutterSecureStorage().write(key: authTokenStorageKey, value: authToken);

void deleteAuthToken() =>
    const FlutterSecureStorage().delete(key: authTokenStorageKey);
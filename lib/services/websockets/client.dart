import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:flashbacks/models/chat.dart';
import 'package:flashbacks/utils/api/client.dart';
import 'package:logger/logger.dart';


enum MessageRequest {
  message,
  likeUnlike,
}

enum MessageResponse {
  message,
  notification
}

class ClientWebSocketService {
  final Uri socketEndPoint;
  final String? authToken;

  WebSocket? _socket;
  final Logger logger = Logger();

  Function(Message message)? onMessage;
  Function(dynamic notification)? onNotification;

  ClientWebSocketService({
    required this.socketEndPoint,
    required this.authToken,
  });

  bool get isConnected => _socket != null && _socket!.readyState == WebSocket.open;

  Uri getAuthEndPoint() {
    if (authToken == null) return socketEndPoint;
    return socketEndPoint.resolve("?token=$authToken");
  }

  Future<void> connect() async {
    final authEndPoint = getAuthEndPoint().toString();

    try {
      _socket = await WebSocket.connect(authEndPoint);
      logger.i('Connected to WebSocket at $authEndPoint');

      _socket!.listen((data) => _onMessage(data),
            onError: (error) => _onError(error),
            onDone: () => _onDone()
      );
    } catch (e) {
      _onError(e.toString());
    }
  }

  void sendMessage(int event, String content, {MessageParent? parent}) {
    if (!isConnected) {
      logger.e('WebSocket is not connected');
      return;
    }

    final requestData = {
      "type": MessageRequest.message.index,
      "data": {
        "event": event,
        "content": content,
        "parent": parent?.pk
      }
    };

    _socket!.add(json.encode(requestData));
  }

  void likeUnlike(int messageId) {
    if (!isConnected) {
      logger.e('WebSocket is not connected');
      return;
    }

    final requestData = {
      "type": MessageRequest.likeUnlike.index,
      "data": {
        "id": messageId,
      }
    };

    _socket!.add(json.encode(requestData));
  }

  void close() {
    if (_socket != null) {
      _socket!.close();
      logger.i('WebSocket connection closed');
    }
  }

  void _onMessage(String data) {
    JsonData jsonData = json.decode(data);
    logger.i("New message: [$jsonData]");

    if (!jsonData.containsKey("type") || !jsonData.containsKey("data"))
      return;

    // TODO: check for type

    MessageResponse messageResponse = MessageResponse.values[jsonData["type"]];

    if (messageResponse == MessageResponse.message) {
      Message message = Message.fromJson(jsonData["data"]);
      onMessage!(message);
    }

    if (messageResponse == MessageResponse.notification) {

    }
  }

  void _onError(String error) {
    logger.e("websocket chat error: $error");
  }

  void _onDone() {
    logger.i("connection closed");
  }
}

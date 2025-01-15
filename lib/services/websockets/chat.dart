import 'dart:convert';
import 'dart:async';
import 'dart:io';  // Import for WebSocket
import 'package:flashbacks/models/chat.dart';
import 'package:flashbacks/utils/api/client.dart';
import 'package:logger/logger.dart';

class ChatWebSocketService {
  final String socketEventType = "chat_message";
  final Uri socketUrl;
  final String? authToken;
  WebSocket? _socket;
  final Logger logger = Logger();

  final Function(Message message) onMessage;

  ChatWebSocketService({
    required this.socketUrl,
    required this.authToken,
    required this.onMessage,
  });

  /// Establish WebSocket connection with token in URL query parameter for authentication
  Future<void> connect() async {
    // Append the token as a query parameter in the URL for authentication
    final uriWithToken = Uri.parse('${socketUrl.toString()}?token=$authToken');

    try {
      // Establish connection using the built-in WebSocket
      _socket = await WebSocket.connect(uriWithToken.toString());
      logger.i('Connected to WebSocket at ${uriWithToken.toString()}');

      // Listen for incoming messages
      _socket!.listen((data) => _onMessage(data),
            onError: (error) => _onError(error),
            onDone: () => _onDone()
      );
    } catch (e) {
      _onError(e.toString());
    }
  }

  /// Send a message to the WebSocket server
  void sendMessage(String message) {
    if (_socket != null && _socket!.readyState == WebSocket.open) {
      _socket!.add(json.encode({'content': message}));
      logger.i('Sent: $message');
    } else {
      logger.e('WebSocket is not connected');
    }
  }

  /// Close the WebSocket connection
  void close() {
    if (_socket != null) {
      _socket!.close();
      logger.i('WebSocket connection closed');
    }
  }

  void _onMessage(String data) {
    JsonData jsonData = json.decode(data);
    logger.i(jsonData);
    onMessage(Message.fromJson(jsonData));
  }

  void _onError(String error) {
    logger.e("websocket chat error: $error");
  }

  void _onDone() {
    logger.i("connection closed");
  }
}

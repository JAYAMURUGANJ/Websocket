import 'package:web_socket_channel/web_socket_channel.dart';

class ChatService {
  final WebSocketChannel _channel =
      WebSocketChannel.connect(Uri.parse("ws://10.163.2.67:4000"));

  WebSocketChannel get channel => _channel;

  void sendMessage(String message) {
    if (message.isNotEmpty) {
      _channel.sink.add(message);
    }
  }

  void dispose() {
    _channel.sink.close();
  }
}

import 'package:flutter/material.dart';
import 'package:flutterapp/services/chat_service.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatService _chatService = ChatService();
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    listenToTheStream();
  }

  Future<void> listenToTheStream() async {
    _chatService.channel.stream.listen((data) {
      debugPrint("Received Data: $data");

      String message =
          data is List<int> ? String.fromCharCodes(data) : data.toString();

      setState(() {
        _messages.add({
          'message': message,
          'isMe': false,
        });
      });
      _scrollToBottom();
    });
  }

  void sendMessage() {
    if (_controller.text.isNotEmpty) {
      setState(() {
        _messages.add({
          'message': _controller.text,
          'isMe': true,
        });
      });
      _chatService.sendMessage(_controller.text);
      _controller.clear();
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Accessing theme data

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Chat",
          style: theme.textTheme.titleLarge, // Updated for better title style
        ),
        centerTitle: true, // Center the title
      ),
      body: Column(
        children: [
          // Messages List
          Expanded(
            child: _messages.isEmpty
                ? Center(
                    child: Text(
                      "No messages yet!",
                      style: theme.textTheme.bodyLarge,
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      bool isMe = message['isMe'];
                      return Align(
                        alignment:
                            isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                              vertical: 6.0, horizontal: 8.0),
                          padding: const EdgeInsets.symmetric(
                              vertical: 10.0, horizontal: 14.0),
                          decoration: BoxDecoration(
                            color: isMe
                                ? theme.colorScheme.primary
                                : theme.colorScheme.secondary,
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: SizedBox(
                            width: MediaQuery.sizeOf(context).width * 0.6,
                            child: Column(
                              crossAxisAlignment: isMe
                                  ? CrossAxisAlignment.end
                                  : CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isMe ? "you" : "other",
                                  style: TextStyle(
                                    color: isMe ? Colors.red : Colors.green,
                                  ),
                                ),
                                SizedBox(height: 4.0),
                                Text(
                                  message['message'],
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          // Message Input
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "Type a message...",
                      hintStyle: theme.textTheme.bodyMedium
                          ?.copyWith(color: Colors.grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(color: theme.dividerColor),
                      ),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 12.0),
                    ),
                  ),
                ),
                const SizedBox(width: 10.0),
                IconButton(
                  icon: Icon(
                    Icons.send,
                    color: theme.iconTheme.color, // Use theme icon color
                  ),
                  onPressed: sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _chatService.dispose();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

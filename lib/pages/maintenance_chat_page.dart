import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/maintenance_service.dart';
import '../utils/user_helpers.dart';
import '../services/chat_service.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:convert';

class MaintenanceChatPage extends StatefulWidget {
  final MaintenanceRequest request;
  const MaintenanceChatPage({super.key, required this.request});

  @override
  State<MaintenanceChatPage> createState() => _MaintenanceChatPageState();
}

class _MaintenanceChatPageState extends State<MaintenanceChatPage> {
  final MaintenanceService _service = MaintenanceService();
  final TextEditingController _messageCtrl = TextEditingController();

  List<Message> _messages = [];
  final ChatService _chat = ChatService();
  WebSocketChannel? _channel;
  bool _online = false;

  @override
  void initState() {
    super.initState();
    _loadMessages();
    _connectSocket();
  }

  void _connectSocket() {
    if (widget.request.id == null) return;
    _channel = _chat.connect(widget.request.id!.toString());
    _channel!.stream.listen((event) {
      final data = jsonDecode(event as String) as Map<String, dynamic>;
      if (data['type'] == 'message') {
        final msg = Message.fromJson(data['data'] as Map<String, dynamic>);
        if (mounted && !_messages.any((m) => m.id == msg.id)) {
          setState(() => _messages.add(msg));
        }
      } else if (data['type'] == 'online' || data['type'] == 'offline') {
        final uid = data['userId'] as String?;
        if (uid != null && uid != currentUserId()) {
          setState(() => _online = data['type'] == 'online');
        }
      }
    });
  }

  Future<void> _loadMessages() async {
    if (widget.request.id == null) return;
    final msgs = await _service.fetchMessages(widget.request.id!);
    setState(() => _messages = msgs);
  }

  Future<void> _sendMessage() async {
    final text = _messageCtrl.text.trim();
    if (text.isEmpty || widget.request.id == null) return;
    final message = Message(
      requestId: widget.request.id!,
      senderId: currentUserId(),
      content: text,
    );
    await _service.sendMessage(message);
    _messageCtrl.clear();
  }

  @override
  void dispose() {
    _messageCtrl.dispose();
    _channel?.sink.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text(widget.request.subject),
            const SizedBox(width: 8),
            Icon(
              Icons.circle,
              size: 10,
              color: _online ? Colors.green : Colors.grey,
            ),
          ],
        ),
        backgroundColor: colorScheme.primaryContainer,
        foregroundColor: colorScheme.onPrimaryContainer,
        elevation: 1,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isMe = msg.senderId == currentUserId();
                return Align(
                  alignment: isMe
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isMe
                          ? colorScheme.primaryContainer
                          : colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(msg.content),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageCtrl,
                    decoration: const InputDecoration(
                      hintText: 'Type a message',
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

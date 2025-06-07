import 'package:flutter/material.dart';

import '../models/models.dart';
import '../services/directory_service.dart';
import '../utils/user_helpers.dart';
import '../services/chat_service.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:convert';

class UserChatPage extends StatefulWidget {
  final User user;
  final DirectoryService? service;
  const UserChatPage({super.key, required this.user, this.service});

  @override
  State<UserChatPage> createState() => _UserChatPageState();
}

class _UserChatPageState extends State<UserChatPage> {
  late final DirectoryService _service;
  final TextEditingController _messageCtrl = TextEditingController();
  List<Message> _messages = [];
  final ChatService _chat = ChatService();
  WebSocketChannel? _channel;
  bool _online = false;

  @override
  void initState() {
    super.initState();
    _service = widget.service ?? DirectoryService();
    _loadMessages();
    _connectSocket();
  }

  void _connectSocket() {
    if (widget.user.id == null) return;
    _channel = _chat.connect(widget.user.id!);
    _channel!.stream.listen((event) {
      final data = jsonDecode(event as String) as Map<String, dynamic>;
      if (data['type'] == 'message') {
        final msg = Message.fromJson(data['data'] as Map<String, dynamic>);
        if (mounted && !_messages.any((m) => m.id == msg.id)) {
          setState(() => _messages.add(msg));
        }
      } else if (data['type'] == 'online' || data['type'] == 'offline') {
        final uid = data['userId'] as String?;
        if (uid == widget.user.id) {
          setState(() => _online = data['type'] == 'online');
        }
      }
    });
  }

  Future<void> _loadMessages() async {
    if (widget.user.id == null) return;
    final msgs = await _service.fetchMessages(widget.user.id!);
    if (!mounted) return;
    setState(() => _messages = msgs);
  }

  Future<void> _sendMessage() async {
    final text = _messageCtrl.text.trim();
    if (text.isEmpty || widget.user.id == null) return;
    await _service.sendMessage(widget.user.id!, text);
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
            Text(widget.user.name),
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

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../models/models.dart';
import '../providers/chat_providers.dart';
import '../providers/directory_providers.dart';
import '../services/directory_service.dart';
import '../utils/user_helpers.dart';

class UserChatPage extends ConsumerStatefulWidget {
  final User user;
  final DirectoryService? service;
  const UserChatPage({super.key, required this.user, this.service});

  @override
  ConsumerState<UserChatPage> createState() => _UserChatPageState();
}

class _UserChatPageState extends ConsumerState<UserChatPage> {
  final TextEditingController _messageCtrl = TextEditingController();
  List<Message> _messages = [];
  WebSocketChannel? _channel;
  bool _online = false;

  DirectoryService _resolveService() {
    final DirectoryService service =
        widget.service ?? ref.read(directoryServiceProvider);
    return service;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadMessages();
      _connectSocket();
    });
  }

  void _connectSocket() {
    if (widget.user.id == null) return;
    _channel = ref.read(chatServiceProvider).connect(widget.user.id!);
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
    final msgs = await _resolveService().fetchMessages(widget.user.id!);
    if (!mounted) return;
    setState(() => _messages = msgs);
  }

  Future<void> _sendMessage() async {
    final text = _messageCtrl.text.trim();
    if (text.isEmpty || widget.user.id == null) return;
    await _resolveService().sendMessage(widget.user.id!, text);
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

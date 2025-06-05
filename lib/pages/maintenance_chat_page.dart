import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/maintenance_service.dart';
import '../utils/user_helpers.dart';

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

  @override
  void initState() {
    super.initState();
    _loadMessages();
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
    final saved = await _service.sendMessage(message);
    setState(() => _messages.add(saved));
    _messageCtrl.clear();
  }

  @override
  void dispose() {
    _messageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.request.subject),
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
                  alignment:
                      isMe ? Alignment.centerRight : Alignment.centerLeft,
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
                    decoration: const InputDecoration(hintText: 'Type a message'),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

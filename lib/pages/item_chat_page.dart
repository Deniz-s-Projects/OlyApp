import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/item_service.dart';

class ItemChatPage extends StatefulWidget {
  final Item item;
  final ItemService? service;
  const ItemChatPage({super.key, required this.item, this.service});

  @override
  State<ItemChatPage> createState() => _ItemChatPageState();
}

class _ItemChatPageState extends State<ItemChatPage> {
  late final ItemService _service;
  final TextEditingController _messageCtrl = TextEditingController();

  List<Message> _messages = [];

  @override
  void initState() {
    super.initState();
    _service = widget.service ?? ItemService();
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    if (widget.item.id == null) return;
    try {
      final msgs = await _service.fetchMessages(widget.item.id!);
      if (!mounted) return;
      setState(() => _messages = msgs);
    } catch (_) {
      // ignore errors in example
    }
  }

  Future<void> _sendMessage() async {
    final text = _messageCtrl.text.trim();
    if (text.isEmpty || widget.item.id == null) return;
    final message = Message(
      requestId: widget.item.id!,
      senderId: 1,
      content: text,
    );
    try {
      final saved = await _service.sendMessage(message);
      if (!mounted) return;
      setState(() => _messages.add(saved));
      _messageCtrl.clear();
    } catch (_) {
      // ignore errors in example
    }
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
        title: Text(widget.item.title),
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
                final isMe = msg.senderId == 1;
                return Align(
                  alignment:
                      isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color:
                          isMe
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

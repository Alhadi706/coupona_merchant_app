import 'package:flutter/material.dart';

class MerchantChatScreen extends StatefulWidget {
  const MerchantChatScreen({Key? key}) : super(key: key);

  @override
  State<MerchantChatScreen> createState() => _MerchantChatScreenState();
}

class _MerchantChatScreenState extends State<MerchantChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> _dummyMessages = [
    {'text': 'مرحباً، كيف يمكنني المساعدة؟', 'senderRole': 'support'},
    {'text': 'لدي مشكلة في أحد الطلبات', 'senderRole': 'merchant'},
  ];

  void _sendMessage() {
    if (_controller.text.trim().isEmpty) return;
    setState(() {
      _dummyMessages.add({
        'text': _controller.text.trim(),
        'senderRole': 'merchant',
      });
      _controller.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الدردشة')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true,
              itemCount: _dummyMessages.length,
              itemBuilder: (context, index) {
                final msg = _dummyMessages.reversed.toList()[index];
                final isMe = msg['senderRole'] == 'merchant';
                return Align(
                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isMe ? Colors.deepPurple.shade100 : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(msg['text'] ?? ''),
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
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'اكتب رسالتك...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _sendMessage,
                  child: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

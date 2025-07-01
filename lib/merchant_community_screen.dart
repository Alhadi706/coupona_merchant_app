import 'package:flutter/material.dart';

class MerchantCommunityScreen extends StatelessWidget {
  const MerchantCommunityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // بيانات وهمية للمجموعات
    final fakeGroups = [
      {'id': '1', 'name': 'تجار سوق الجمعة', 'desc': 'تبادل الخبرات والعروض', 'members': 12},
      {'id': '2', 'name': 'أصحاب محلات التقنية', 'desc': 'مناقشة أحدث الأجهزة', 'members': 8},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('مجتمع التجار'),
        backgroundColor: Colors.deepPurple.shade700,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: fakeGroups.length,
        itemBuilder: (context, i) {
          final group = fakeGroups[i];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: const Icon(Icons.groups, color: Colors.deepPurple, size: 32),
              title: Text(group['name']!, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(group['desc']!),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.people, size: 18, color: Colors.grey),
                  Text('${group['members']}'),
                ],
              ),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => MerchantGroupChatScreen(
                      groupId: group['id']!,
                      groupName: group['name']!,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class MerchantGroupChatScreen extends StatefulWidget {
  final String groupId;
  final String groupName;
  const MerchantGroupChatScreen({required this.groupId, required this.groupName});

  @override
  State<MerchantGroupChatScreen> createState() => _MerchantGroupChatScreenState();
}

class _MerchantGroupChatScreenState extends State<MerchantGroupChatScreen> {
  final TextEditingController _msgController = TextEditingController();
  final List<Map<String, String>> messages = [
    {'senderName': 'تاجر1', 'msg': 'السلام عليكم'},
    {'senderName': 'تاجر2', 'msg': 'مرحبا بك!'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.groupName),
        backgroundColor: Colors.deepPurple.shade700,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder: (context, i) {
                final msg = messages[i];
                return Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(msg['senderName']!, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple)),
                        const SizedBox(height: 2),
                        Text(msg['msg']!),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _msgController,
                    decoration: const InputDecoration(hintText: 'اكتب رسالة...'),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    final text = _msgController.text.trim();
                    if (text.isNotEmpty) {
                      setState(() {
                        messages.add({'senderName': 'أنا', 'msg': text});
                        _msgController.clear();
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
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

import 'package:flutter/material.dart';

class StoreCommunityScreen extends StatelessWidget {
  final String storeId;
  const StoreCommunityScreen({super.key, required this.storeId});

  @override
  Widget build(BuildContext context) {
    // بيانات تجريبية للرسائل
    final List<Map<String, dynamic>> demoMessages = [
      {
        'sender': 'محمد أحمد',
        'text': 'هل هذا المنتج متوفر بحجم أكبر؟',
        'time': '10:30 ص',
      },
      {
        'sender': 'إدارة المتجر',
        'text': 'نعم متوفر بحجم XL، يمكنك الطلب الآن',
        'time': '11:45 ص',
      },
      {
        'sender': 'سارة خالد',
        'text': 'متى موعد وصول التشكيلة الجديدة؟',
        'time': 'اليوم 9:20 ص',
      },
    ];

    final TextEditingController _msgController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('مجتمع المحل'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              reverse: false,
              itemCount: demoMessages.length,
              itemBuilder: (context, index) {
                final message = demoMessages[index];
                final isAdmin = message['sender'] == 'إدارة المتجر';
                
                return Align(
                  alignment: isAdmin ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isAdmin ? Colors.deepPurple[100] : Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!isAdmin)
                          Text(
                            message['sender'],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        Text(message['text']),
                        const SizedBox(height: 4),
                        Text(
                          message['time'],
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
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
                    controller: _msgController,
                    decoration: InputDecoration(
                      hintText: 'اكتب رسالة...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: Colors.deepPurple,
                  child: IconButton(
                    onPressed: () {
                      if (_msgController.text.isNotEmpty) {
                        // هنا يمكنك إضافة الرسالة الجديدة للقائمة
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('تم إرسال الرسالة')),
                        );
                        _msgController.clear();
                      }
                    },
                    icon: const Icon(Icons.send, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
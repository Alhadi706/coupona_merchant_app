import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StoreCommunityScreen extends StatelessWidget {
  final String storeId;
  const StoreCommunityScreen({super.key, required this.storeId});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final TextEditingController _msgController = TextEditingController();
    return Scaffold(
      appBar: AppBar(title: const Text('مجتمع المحل')),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: null, // ضع هنا Stream الرسائل من Firestore
              builder: (context, snapshot) {
                // ... انسخ هنا من الكود الأصلي ...
                return const SizedBox();
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
                    decoration: const InputDecoration(
                      hintText: 'اكتب رسالة...'
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {}, // انسخ هنا من الكود الأصلي
                  child: const Icon(Icons.send),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

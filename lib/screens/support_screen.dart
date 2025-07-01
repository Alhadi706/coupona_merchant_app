import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  final _msgController = TextEditingController();
  final _typeController = TextEditingController();
  bool _sending = false;

  final List<Map<String, String>> _faq = [
    {'q': 'كيف أضيف عرض جديد؟', 'a': 'من لوحة التحكم اختر "إضافة عرض" واملأ البيانات المطلوبة.'},
    {'q': 'كيف أغير كلمة المرور؟', 'a': 'من الإعدادات يمكنك تغيير كلمة المرور.'},
    {'q': 'كيف أتابع نقاط الزبائن؟', 'a': 'من شاشة الزبائن يمكنك استعراض النقاط والتفاصيل.'},
    {'q': 'كيف أتواصل مع الدعم؟', 'a': 'استخدم زر "تواصل مع الدعم" أو أرسل مشكلة عبر النموذج.'},
  ];

  Future<void> _sendSupportMessage() async {
    if (_msgController.text.trim().isEmpty) return;
    setState(() => _sending = true);
    await FirebaseFirestore.instance.collection('support_requests').add({
      'userId': FirebaseAuth.instance.currentUser?.uid,
      'message': _msgController.text.trim(),
      'type': _typeController.text.trim(),
      'createdAt': DateTime.now(),
    });
    setState(() => _sending = false);
    _msgController.clear();
    _typeController.clear();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم إرسال رسالتك للدعم')));
  }

  void _contactSupport() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تواصل مع الدعم'),
        content: const Text('راسلنا عبر البريد: support@coupona.com\nأو عبر الواتساب: 0555555555'),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إغلاق'))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الدعم والمساعدة'),
        backgroundColor: Colors.deepPurple.shade700,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('الأسئلة الشائعة', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
          const SizedBox(height: 12),
          ..._faq.map((item) => ExpansionTile(
                title: Text(item['q']!),
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text(item['a']!),
                  ),
                ],
              )),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _contactSupport,
            icon: const Icon(Icons.support_agent),
            label: const Text('تواصل مع الدعم'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple, foregroundColor: Colors.white),
          ),
          const SizedBox(height: 32),
          const Text('إرسال مشكلة أو اقتراح', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 10),
          TextField(
            controller: _typeController,
            decoration: const InputDecoration(labelText: 'نوع الرسالة (مشكلة/اقتراح)'),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _msgController,
            decoration: const InputDecoration(labelText: 'اكتب رسالتك هنا'),
            minLines: 2,
            maxLines: 5,
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: _sending ? null : _sendSupportMessage,
            child: _sending ? const CircularProgressIndicator() : const Text('إرسال', style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple, foregroundColor: Colors.white),
          ),
        ],
      ),
    );
  }
}

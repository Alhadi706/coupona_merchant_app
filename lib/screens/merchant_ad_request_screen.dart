import 'package:flutter/material.dart';

class MerchantAdRequestScreen extends StatefulWidget {
  const MerchantAdRequestScreen({super.key});

  @override
  State<MerchantAdRequestScreen> createState() => _MerchantAdRequestScreenState();
}

class _MerchantAdRequestScreenState extends State<MerchantAdRequestScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  bool _loading = false;

  Future<void> _submitAdRequest() async {
    setState(() => _loading = true);
    // محاكاة إرسال الطلب بدون قاعدة بيانات
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _loading = false);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم إرسال طلب الإعلان بنجاح!')));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('طلب إعلان متحرك')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'عنوان الإعلان'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descController,
              decoration: const InputDecoration(labelText: 'وصف الإعلان'),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loading ? null : _submitAdRequest,
              icon: const Icon(Icons.campaign),
              label: _loading ? const CircularProgressIndicator() : const Text('إرسال الطلب'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple, foregroundColor: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

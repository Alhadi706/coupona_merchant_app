import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/services.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  final _msgController = TextEditingController();
  final _typeController = TextEditingController();
  bool _sending = false;

  String? _merchantCode;
  bool _loadingCode = true;

  final List<Map<String, String>> _faq = [
    {'q': 'كيف أضيف عرض جديد؟', 'a': 'من لوحة التحكم اختر "إضافة عرض" واملأ البيانات المطلوبة.'},
    {'q': 'كيف أغير كلمة المرور؟', 'a': 'من الإعدادات يمكنك تغيير كلمة المرور.'},
    {'q': 'كيف أتابع نقاط الزبائن؟', 'a': 'من شاشة الزبائن يمكنك استعراض النقاط والتفاصيل.'},
    {'q': 'كيف أتواصل مع الدعم؟', 'a': 'استخدم زر "تواصل مع الدعم" أو أرسل مشكلة عبر النموذج.'},
  ];

  @override
  void initState() {
    super.initState();
    _fetchMerchantCode();
  }

  Future<void> _fetchMerchantCode() async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;
    print('Firebase user.id: \\${user?.id}'); // طباعة uid في debug console
    if (user == null) {
      setState(() {
        _merchantCode = null;
        _loadingCode = false;
      });
      return;
    }
    final res = await supabase
        .from('merchants')
        .select('merchant_code, user_id')
        .eq('user_id', user.id)
        .maybeSingle();
    print('Supabase merchant row: \\${res?.toString()}'); // طباعة نتيجة الاستعلام
    setState(() {
      _merchantCode = res != null ? res['merchant_code'] as String? : null;
      _loadingCode = false;
    });
  }

  Future<void> _sendSupportMessage() async {
    if (_msgController.text.trim().isEmpty) return;
    setState(() => _sending = true);
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;
    await supabase.from('support_requests').insert({
      'user_id': user?.id,
      'message': _msgController.text.trim(),
      'type': _typeController.text.trim(),
      'created_at': DateTime.now().toIso8601String(),
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
        actions: [
          IconButton(
            icon: const Icon(Icons.key),
            tooltip: 'عرض رمز التاجر',
            onPressed: _loadingCode || _merchantCode == null || _merchantCode!.isEmpty
                ? null
                : () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('رمز التاجر المختصر'),
                        content: Row(
                          children: [
                            Expanded(
                              child: SelectableText(
                                _merchantCode!,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.copy),
                              tooltip: 'نسخ الرمز',
                              onPressed: () {
                                Clipboard.setData(ClipboardData(text: _merchantCode!));
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم نسخ رمز التاجر')));
                              },
                            ),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text('إغلاق'),
                          ),
                        ],
                      ),
                    );
                  },
          ),
          _loadingCode
              ? const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  ),
                )
              : (_merchantCode != null && _merchantCode!.isNotEmpty)
                  ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Row(
                        children: [
                          Text(
                            'رمز التاجر: ',
                            style: const TextStyle(fontSize: 14, color: Colors.white),
                          ),
                          SelectableText(
                            _merchantCode!,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                          ),
                          IconButton(
                            icon: const Icon(Icons.copy, color: Colors.white, size: 20),
                            tooltip: 'نسخ الرمز',
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: _merchantCode!));
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم نسخ رمز التاجر')));
                            },
                          ),
                        ],
                      ),
                    )
                  : const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text('لا يوجد رمز تاجر', style: TextStyle(color: Colors.white)),
                    ),
        ],
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

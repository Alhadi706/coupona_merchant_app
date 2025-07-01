import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import '../services/auth_manager.dart';

class AddOfferScreen extends StatefulWidget {
  final String merchantId; // تغيير إلى غير nullable
  final Map<String, dynamic>? offer;
  final String? offerId;
  const AddOfferScreen({Key? key, required this.merchantId, this.offer, this.offerId}) : super(key: key);

  @override
  State<AddOfferScreen> createState() => _AddOfferScreenState();
}

class _AddOfferScreenState extends State<AddOfferScreen> {
  String _merchantId = ''; // تغيير إلى غير nullable مع قيمة افتراضية
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _loading = false;

  // ...existing variables...

  @override
  void initState() {
    super.initState();
    _merchantId = widget.merchantId; // تعيين القيمة مباشرةً
    _initAuthAndData();
  }

  Future<void> _initAuthAndData() async {
    print('[AddOfferScreen] بدء التحقق من المصادقة المزدوجة...');
    await AuthManager.ensureAuth();
    final fbUser = FirebaseAuth.instance.currentUser;
    print('[AddOfferScreen] بعد ensureAuth: Firebase user: \\${fbUser?.uid}');
    setState(() {
      _merchantId = widget.merchantId.isNotEmpty ? widget.merchantId : fbUser?.uid ?? '';
      print('[AddOfferScreen] merchantId النهائي: \\$_merchantId');
    });
    if (_merchantId.isEmpty) {
      print('[AddOfferScreen] تعذر تحديد هوية التاجر بعد المصادقة!');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تعذر تحديد هوية التاجر. يرجى إعادة تسجيل الدخول.')),
        );
      }
      return;
    }
    // ...بقية الدالة كما هي...
  }

  Future<void> _fetchMerchantLocation() async {
    if (_merchantId.isEmpty) return; // الآن يمكن استخدام isEmpty مباشرة
    // ...بقية الدالة...
  }

  Future<void> _submit() async {
    try {
      if (_merchantId.isEmpty) {
        throw Exception('Merchant ID is empty');
      }

      if (!_formKey.currentState!.validate()) {
        throw Exception('Please fill all required fields');
      }

      // ... بقية الدالة
    } catch (e, stackTrace) {
      print('Error submitting offer: $e');
      print(stackTrace);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('حدث خطأ: \\${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<String?> _uploadImageToFirebase(File? imageFile) async {
    if (imageFile == null) return null;
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User not authenticated');
      final fileName = 'offers/${user.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final storageRef = FirebaseStorage.instance.ref().child(fileName);
      final uploadTask = await storageRef.putFile(imageFile);
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      print('Error uploading image: $e');
      throw Exception('Failed to upload image');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_merchantId.isEmpty) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 20),
              Text(
                'جاري تحميل بيانات التاجر...\nMerchantId: \\$_merchantId',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              TextButton(
                onPressed: _initAuthAndData,
                child: const Text('إعادة المحاولة'),
              ),
              // إضافة زر لإظهار معلومات المصادقة
              TextButton(
                onPressed: () {
                  final fbUser = FirebaseAuth.instance.currentUser;
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('معلومات المصادقة'),
                      content: Text('Firebase UID: \\${fbUser?.uid}'),
                    ),
                  );
                },
                child: const Text('عرض معلومات المصادقة'),
              ),
            ],
          ),
        ),
      );
    }
    // ... بقية بناء الواجهة ...
    return Container(); // مؤقتًا حتى تكتمل الواجهة
  }

  // ...بقية الكود بنفس الطريقة...
}
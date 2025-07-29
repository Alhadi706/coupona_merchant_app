import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthNotifier extends ChangeNotifier {
  bool _isLoggedIn = false;
  bool get isLoggedIn => _isLoggedIn;
  Map<String, dynamic>? _merchantData;
  Map<String, dynamic>? get merchantData => _merchantData;

  Future<void> login(String email, String password) async {
    try {
      // 1. تسجيل الدخول في Firebase فقط
      final fbUser = await fb_auth.FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      if (fbUser.user == null) {
        throw Exception('فشل تسجيل الدخول في Firebase');
      }

      // 2. جلب بيانات التاجر من Supabase (جدول merchants) باستخدام البريد الإلكتروني
      final response = await Supabase.instance.client
          .from('merchants')
          .select()
          .eq('email', email)
          .maybeSingle();

      if (response == null) {
        // يمكن هنا إنشاء سجل جديد في Supabase إذا رغبت بذلك
        // await Supabase.instance.client.from('merchants').insert({ ... });
        throw Exception('لم يتم العثور على بيانات التاجر في قاعدة البيانات');
      }

      _merchantData = response;
      _isLoggedIn = true;
      notifyListeners();
    } catch (e) {
      print('حدث خطأ أثناء المصادقة أو جلب البيانات: $e');
      rethrow;
    }
  }

  Future<void> logout() async {
    await fb_auth.FirebaseAuth.instance.signOut();
    // لا حاجة لتسجيل الخروج من Supabase Auth
    _isLoggedIn = false;
    _merchantData = null;
    notifyListeners();
  }
}
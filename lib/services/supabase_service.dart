import 'dart:math';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static const String supabaseUrl = 'https://pedzvbkrlbhfguhkzznr.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBlZHp2YmtybGJoZmd1aGt6em5yIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDg2OTY5NjcsImV4cCI6MjA2NDI3Mjk2N30.fNM7yYuqauXXbnwEiYbBu86R5VDhe0Ie4Xc7iJgwZzg';

  static Future<void> init() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }

  static SupabaseClient get client => Supabase.instance.client;

  /// تسجيل دخول آمن إلى Supabase (يستعمل بريد/كلمة مرور مستخدم Supabase)
  /// يستدعيه التطبيق بعد نجاح تسجيل الدخول في Firebase لضمان أن auth.uid() متاح لسياسات RLS.
  static Future<bool> ensureLogin({required String email, required String password}) async {
    final auth = Supabase.instance.client.auth;
    // لو جلسة موجودة بنفس البريد نكتفي
    if (auth.currentUser != null && auth.currentUser!.email == email) return true;
    try {
      await auth.signInWithPassword(email: email, password: password);
      return true;
    } on AuthApiException catch (_) {
      return false; // فشل (بيانات خاطئة)
    } catch (_) {
      return false;
    }
  }

  /// توليد رمز تاجر مختصر بناءً على المدينة والتخصص
  static Future<String> generateMerchantCode(String cityCode, String typeCode) async {
    final prefix = '$cityCode$typeCode';
    final supabase = Supabase.instance.client;
    final response = await supabase
        .from('merchants')
        .select('merchant_code')
        .like('merchant_code', '$prefix%');
    final codes = (response as List).map((e) => e['merchant_code'] as String).toList();
    int maxNum = 0;
    for (final code in codes) {
      final numPart = code.replaceFirst(prefix, '');
      final num = int.tryParse(numPart) ?? 0;
      if (num > maxNum) maxNum = num;
    }
    final newNum = maxNum + 1;
    return '$prefix$newNum';
  }
}

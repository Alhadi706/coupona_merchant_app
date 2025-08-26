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
  // بعد تسجيل الدخول نحاول توحيد معرف التاجر في الجداول المختلفة
  await _harmonizeMerchantIdentity();
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

  /// محاولة توحيد معرفات التاجر: إذا وُجد صف قديم في merchants بمعرف Firebase UID مختلف عن Supabase UUID
  /// ننسخه تحت UUID ونوجّه الجداول التابعة (offers, merchant_products) ثم نحذف القديم إن أمكن.
  static Future<void> _harmonizeMerchantIdentity() async {
    final client = Supabase.instance.client;
    final user = client.auth.currentUser;
    if (user == null) return;
    final uuid = user.id;
    final email = user.email;
    try {
      // هل يوجد صف بالمعرف الحالي؟
      final existing = await client.from('merchants').select().eq('id', uuid).maybeSingle();
      if (existing != null) return; // كل شيء منسجم

      // ابحث بالـ email عن صف قديم
      Map<String, dynamic>? legacy;
      if (email != null) {
        legacy = await client.from('merchants').select().eq('email', email).maybeSingle();
      }
      if (legacy == null) {
        // لا صف قديم: ربما لم يتم إدراج التاجر بعد => نتوقف
        return;
      }
      final oldId = legacy['id']?.toString();
      if (oldId == null || oldId == uuid) return;

      // أنشئ صف جديد بالUUID لو لم يوجد (نسخ الحقول الأساسية)
      final newData = Map<String, dynamic>.from(legacy)
        ..['id'] = uuid
        ..['user_id'] = uuid
        ..remove('created_at'); // ستُعاد تعبئتها آلياً إن كان لها default
      try {
        await client.from('merchants').insert(newData);
      } catch (e) {
        // إذا فشل الإدراج ربما بسبب تعارض فنتجاهل
      }

      // تحديث الجداول التابعة التي تستخدم المعرف القديم
      Future<void> safeUpdate(String table) async {
        try {
          await client.from(table).update({'merchant_id': uuid}).eq('merchant_id', oldId);
        } catch (_) {}
      }
      await safeUpdate('offers');
      await safeUpdate('merchant_products');
      await safeUpdate('rewards');
      await safeUpdate('merchant_posts');

      // حذف الصف القديم (اختياري) إذا بقي موجوداً
      try {
        await client.from('merchants').delete().eq('id', oldId);
      } catch (_) {
        // قد تفشل بسبب قيود RLS أو علاقات - نتجاهل
      }
    } catch (e) {
      // Debug فقط، لا نرمي الخطأ للمستخدم
      // ignore: avoid_print
      print('[harmonizeMerchantIdentity] Failed: $e');
    }
  }
}

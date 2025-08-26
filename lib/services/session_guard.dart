/// حارس جلسة بسيط (In-Memory) لحفظ آخر بريد وكلمة مرور لإعادة إنشاء جلسة Supabase.
/// تنبيه: لا يصلح للإنتاج دون استخدام تخزين آمن.
class SessionGuard {
  static String? lastEmail;
  static String? lastPassword;

  static void remember(String email, String password) {
    lastEmail = email;
    lastPassword = password;
  }
}

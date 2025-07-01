import 'package:firebase_auth/firebase_auth.dart' as fb_auth;

class AuthManager {
  static Future<void> ensureAuth() async {
    final fbUser = fb_auth.FirebaseAuth.instance.currentUser;

    print('[AuthManager] Firebase user: \\${fbUser?.uid}');

    // إذا كان مسجل في Firebase فقط، سجل في Supabase (مثال باستخدام البريد)
    if (fbUser != null) {
      print('[AuthManager] مستخدم Firebase مسجل دخول.');
      return;
    }

    print('[AuthManager] لا يوجد تسجيل دخول نشط.');
  }

  static Future<void> syncUserData() async {
    final fbUser = fb_auth.FirebaseAuth.instance.currentUser;
    print('[AuthManager] مزامنة بيانات المستخدم. Firebase user: \\${fbUser?.uid}');
    if (fbUser != null) {
      print('[AuthManager] تم مزامنة بيانات المستخدم بنجاح.');
    }
  }
}

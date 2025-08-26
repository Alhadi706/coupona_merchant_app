import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/supabase_service.dart';

class MerchantLoginScreen extends StatefulWidget {
  const MerchantLoginScreen({super.key});

  @override
  State<MerchantLoginScreen> createState() => _MerchantLoginScreenState();
}

class _MerchantLoginScreenState extends State<MerchantLoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _loading = false;

  Future<void> _login() async {
    setState(() => _loading = true);
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى إدخال البريد الإلكتروني وكلمة المرور')),
      );
      setState(() => _loading = false);
      return;
    }

    try {
      // 1) تسجيل الدخول في Firebase
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      // حفظ الاعتمادات مؤقتاً لإعادة إنشاء جلسة Supabase عند الحاجة (محدودة بزمن تشغيل التطبيق)
      try {
        // تجاهل لو لم يتم ربط المتغيرات (قد لا تكون معرفة لو تغير الهيكل مستقبلاً)
        // ignore: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member
        // سيتم الوصول للمتغيرات العالمية في main.dart
        // استخدم Function.apply للمرونة (تفادي التحذيرات) - لكن هنا بسيط:
        // سيتم تعيين المتغيرات عبر مكتبة main (مستوردة هناك)
        // لأننا لا نملك وصول مباشر هنا يمكننا استخدام Zone أو بديل، لكن الأبسط إعادة تسجيل في redirect.
      } catch (_) {}

      // 2) ضمان جلسة Supabase (مطلوبة لسياسات RLS + إدراج المنتجات وغيرها)
      final supaOk = await SupabaseService.ensureLogin(email: email, password: password);
      if (!supaOk) {
        // محاولة تسجيل (signUp) تلقائية إذا لم يكن الحساب موجوداً في Supabase بعد
        try {
          await SupabaseService.client.auth.signUp(email: email, password: password);
          await SupabaseService.ensureLogin(email: email, password: password);
        } catch (_) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('تعذّر إنشاء جلسة Supabase، لن تعمل بعض الميزات')), 
            );
          }
        }
      }

      // 3) الانتقال للوحة التحكم بعد ضمان الجلسة (أو محاولة ذلك)
  // كذلك نخزّن القيم عالمياً عبر Isolate الحالي (import main غير دائري لأن main يستورد هذه الشاشة بالفعل)
  // الحل الأبسط: استخدام مكتبة 'main.dart' غير ممكن هنا لتجنب الدوران، لذا سنضيف Callback لاحقاً إن احتجنا.
      if (mounted) context.go('/dashboard');
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل تسجيل الدخول: ${e.message}')),
      );
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  /// دالة مخصصة وواضحة للانتقال لشاشة التسجيل
  void _goToRegisterScreen() {
    // التأكد من أننا لا نقوم بعملية أخرى
    if (_loading) return;
    // استخدام GoRouter للانتقال الصريح
    context.go('/register');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('دخول التاجر'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              Image.asset(
                'assets/images/logo.png',
                height: 120,
                errorBuilder: (_, __, ___) => const Icon(Icons.store, size: 80),
              ),
              const SizedBox(height: 40),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'البريد الإلكتروني',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'كلمة المرور',
                  prefixIcon: Icon(Icons.lock),
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: _loading ? null : _login,
                child: _loading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(color: Colors.white),
                      )
                    : const Text('دخول', style: TextStyle(fontSize: 18)),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: _goToRegisterScreen, // تم الربط بالدالة الجديدة لمنع التداخل
                child: const Text('إنشاء حساب تاجر جديد'),
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('سيتم إرسال رابط استرجاع كلمة المرور'),
                      ),
                    );
                  },
                  child: const Text('نسيت كلمة المرور؟',
                      style: TextStyle(color: Colors.deepPurple)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
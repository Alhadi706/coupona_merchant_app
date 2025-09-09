import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/supabase_service.dart';
import '../services/session_guard.dart';
import 'package:coupona_merchant/gen_l10n/app_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
  final loc = AppLocalizations.of(context);
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(loc?.enterEmailPassword ?? 'Enter email & password')));
      setState(() => _loading = false);
      return;
    }

    try {
      // 1) تسجيل الدخول في Firebase أولاً
      await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
      // تذكر الاعتمادات مؤقتاً (للاستخدام في redirect في main)
      SessionGuard.remember(email, password);

  // 2) محاولة الجسر (إنشاء/تسجيل مستخدم Supabase بكلمة مشتقة من UID إن لزم)
  bool bridged = await SupabaseService.ensureBridgedSessionFromFirebase();
  // ignore: avoid_print
  print('[login] bridged=$bridged');

      // 3) إن فشل الجسر (مثلاً لسبب مؤقت) نحاول نفس البريد/كلمة المرور مباشرة
      if (!bridged) {
        final supaOk = await SupabaseService.ensureLogin(email: email, password: password);
        // ignore: avoid_print
        print('[login] ensureLogin with user password => $supaOk');
        if (!supaOk) {
          // 4) محاولة signUp ثم تسجيل الدخول بكلمة المستخدم (قد تكون حساب Supabase مستقل)
          try {
            await SupabaseService.client.auth.signUp(email: email, password: password);
            final second = await SupabaseService.ensureLogin(email: email, password: password);
            // ignore: avoid_print
            print('[login] post-signUp ensureLogin => $second');
          } catch (e) {
            // ignore: avoid_print
            print('[login] signUp fallback error: $e');
          }
        }
      }

      // 5) الانتقال للوحة التحكم
      if (mounted) {
        final authUser = Supabase.instance.client.auth.currentUser;
        if (authUser == null) {
          final loc = AppLocalizations.of(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(loc?.supabaseSessionFailed ?? 'Supabase session failed')),
          );
        }
        context.go('/dashboard');
      }
    } on FirebaseAuthException catch (e) {
  final loc = AppLocalizations.of(context);
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${loc?.loginFailed ?? 'Login failed'}: ${e.message}')));
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
  title: Text(AppLocalizations.of(context)?.merchantLoginTitle ?? 'Merchant Login'),
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
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)?.emailLabel ?? 'Email',
                  prefixIcon: const Icon(Icons.email),
                  border: const OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)?.passwordLabel ?? 'Password',
                  prefixIcon: const Icon(Icons.lock),
                  border: const OutlineInputBorder(),
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
                    : Text(AppLocalizations.of(context)?.loginButton ?? 'Login', style: const TextStyle(fontSize: 18)),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: _goToRegisterScreen, // تم الربط بالدالة الجديدة لمنع التداخل
                child: Text(AppLocalizations.of(context)?.createMerchantAccount ?? 'Create account'),
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context)?.sendResetLink ?? 'Reset link will be sent')),
                    );
                  },
          child: Text(AppLocalizations.of(context)?.forgotPassword ?? 'Forgot password?',
            style: const TextStyle(color: Colors.deepPurple)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
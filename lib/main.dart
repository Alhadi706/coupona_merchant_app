import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import 'firebase_options.dart';
import 'supabase_config.dart';
import 'screens/merchant_login_screen.dart';
import 'screens/merchant_dashboard_screen.dart';
import 'screens/merchant_register_screen.dart';
import 'screens/merchant_offers_screen.dart';
import 'screens/merchant_products_screen.dart';
import 'screens/merchant_analytics_screen.dart';
import 'screens/merchant_customers_screen.dart';
import 'screens/merchant_reports_screen.dart';
import 'screens/merchant_rewards_screen.dart';
import 'screens/store_community_screen.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'services/supabase_service.dart';
import 'screens/settings_screen.dart'; // استيراد شاشة الإعدادات

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // تهيئة Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // تهيئة Supabase عبر الخدمة (مثل تطبيق الزبون)
  await SupabaseService.init();

  // إزالة المستمع القديم لتجنب التعارض
  // fb_auth.FirebaseAuth.instance.authStateChanges().listen((user) {
  //   print('حالة Firebase: ${user?.email}');
  //   // توجيه المستخدم تلقائيًا بعد تسجيل الدخول أو الخروج
  //   final ctx = navigatorKey.currentContext;
  //   if (ctx != null) {
  //     if (user != null) {
  //       GoRouter.of(ctx).go('/dashboard');
  //     } else {
  //       GoRouter.of(ctx).go('/');
  //     }
  //   }
  // });

  runApp(const MyApp());
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

final _router = GoRouter(
  navigatorKey: navigatorKey,
  // إضافة منطق إعادة التوجيه
  redirect: (BuildContext context, GoRouterState state) {
    final bool loggedIn = fb_auth.FirebaseAuth.instance.currentUser != null;
    final bool loggingIn = state.matchedLocation == '/' || state.matchedLocation == '/register';

    // إذا لم يكن المستخدم مسجلاً دخوله ويحاول الوصول لصفحة داخلية
    if (!loggedIn && !loggingIn) {
      return '/'; // اذهب لشاشة الدخول
    }

    // إذا كان المستخدم مسجلاً دخوله ويحاول الوصول لشاشة الدخول أو التسجيل
    if (loggedIn && loggingIn) {
      return '/dashboard'; // اذهب للوحة التحكم
    }

    // في الحالات الأخرى، لا تقم بإعادة التوجيه
    return null;
  },
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const MerchantLoginScreen(),
    ),
    GoRoute(
      path: '/dashboard',
      builder: (context, state) => const MerchantDashboardScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const MerchantRegisterScreen(),
    ),
    GoRoute(
      path: '/analytics',
      builder: (context, state) => const MerchantAnalyticsScreen(),
    ),
    GoRoute(
      path: '/offers',
      builder: (context, state) => const MerchantOffersScreen(),
    ),
    GoRoute(
      path: '/customers',
      builder: (context, state) => const MerchantCustomersScreen(),
    ),
    GoRoute(
      path: '/products',
      builder: (context, state) => const MerchantProductsScreen(),
    ),
    GoRoute(
      path: '/reports',
      builder: (context, state) => const MerchantReportsScreen(),
    ),
    GoRoute(
      path: '/rewards',
      builder: (context, state) => const MerchantRewardsScreen(),
    ),
    GoRoute(
      path: '/community/:storeId',
      builder: (context, state) {
        final storeId = state.pathParameters['storeId']!;
        return StoreCommunityScreen(storeId: storeId);
      },
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
      title: 'تطبيق التاجر',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
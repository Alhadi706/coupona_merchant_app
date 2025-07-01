import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:latlong2/latlong.dart';
import 'package:go_router/go_router.dart';
import 'firebase_options.dart';
import 'screens/merchant_login_screen.dart';
import 'screens/merchant_dashboard_screen.dart';
import 'screens/merchant_community_screen.dart';
import 'screens/merchant_reports_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/merchant_analytics_screen.dart';
import 'screens/placeholder_screen.dart';
import 'screens/store_community_screen.dart';
import 'screens/merchant_location_screen.dart';
import 'screens/merchant_ad_request_screen.dart';
import 'screens/merchant_offers_screen.dart';
import 'screens/merchant_chat_screen.dart';
import 'screens/add_offer_screen.dart';
import 'screens/merchant_rewards_screen.dart';
import 'screens/merchant_cashier_screen.dart';
import 'screens/customer_details_screen.dart';
import 'screens/merchant_customers_screen.dart';
import 'screens/merchant_products_screen.dart';
import 'screens/merchant_receipts_screen.dart';
import 'screens/not_supported_screen.dart';
import 'screens/merchant_register_screen.dart';
import 'screens/add_demo_data.dart';
import 'screens/customer_reports_screen.dart';
import 'screens/confirm_reward_screen_stub.dart'
    if (dart.library.io) 'screens/confirm_reward_screen_mobile.dart';
import 'screens/support_screen_stub.dart'
    if (dart.library.io) 'screens/support_screen.dart';
import 'screens/stores_map_screen_stub.dart'
    if (dart.library.io) 'screens/stores_map_screen.dart';
import 'screens/pick_location_screen.dart';
import 'screens/add_edit_reward_screen.dart';
import 'package:coupona_merchant/services/auth_notifier.dart';

final authNotifier = AuthNotifier();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await Hive.initFlutter();
  runApp(const MyApp());
}

final _router = GoRouter(
  refreshListenable: authNotifier,
  initialLocation: '/login', // تغيير نقطة البداية
  routes: [
    GoRoute(
      name: 'login',
      path: '/login',
      builder: (context, state) => const MerchantLoginScreen(),
    ),
    GoRoute(
      name: 'register',
      path: '/register',
      builder: (context, state) => const MerchantRegisterScreen(),
    ),
    GoRoute(
      name: 'dashboard',
      path: '/dashboard',
      builder: (context, state) {
        debugPrint('[GoRouter] Building MerchantDashboardScreen');
        return const MerchantDashboardScreen();
      },
      routes: [
        GoRoute(
          name: 'settings',
          path: 'settings',
          builder: (context, state) => const SettingsScreen(),
        ),
        GoRoute(
          name: 'reports',
          path: 'reports',
          builder: (context, state) => const MerchantReportsScreen(),
        ),
        GoRoute(
          name: 'analytics',
          path: 'analytics',
          builder: (context, state) => const MerchantAnalyticsScreen(),
        ),
        GoRoute(
          name: 'community',
          path: 'community',
          builder: (context, state) => const MerchantCommunityScreen(),
        ),
        GoRoute(
          name: 'offers',
          path: 'offers',
          builder: (context, state) => const MerchantOffersScreen(),
        ),
        GoRoute(
          name: 'add-offer',
          path: 'add-offer',
          builder: (context, state) {
            final extra = state.extra as Map<String, dynamic>?;
            final offer = extra?['offer'] as Map<String, dynamic>?;
            final offerId = extra?['offerId'] as String?;
            return AddOfferScreen(
              merchantId: fb_auth.FirebaseAuth.instance.currentUser?.uid ?? '',
              offer: offer,
              offerId: offerId,
            );
          },
        ),
        GoRoute(
          name: 'rewards',
          path: 'rewards',
          builder: (context, state) => const MerchantRewardsScreen(),
        ),
        GoRoute(
            name: 'add-edit-reward',
            path: 'add-edit-reward',
            builder: (context, state) {
              final reward = state.extra as Map<String, dynamic>?;
              return AddEditRewardScreen(reward: reward);
            }),
        GoRoute(
          name: 'cashier',
          path: 'cashier',
          builder: (context, state) => const MerchantCashierScreen(),
        ),
        GoRoute(
          name: 'customers',
          path: 'customers',
          builder: (context, state) => const MerchantCustomersScreen(),
        ),
        GoRoute(
          name: 'customer-details',
          path: 'customer-details/:customerId',
          builder: (context, state) => CustomerDetailsScreen(
            customerId: state.pathParameters['customerId']!,
          ),
        ),
        GoRoute(
          name: 'products',
          path: 'products',
          builder: (context, state) => const MerchantProductsScreen(),
        ),
        GoRoute(
          name: 'receipts',
          path: 'receipts',
          builder: (context, state) => const MerchantReceiptsScreen(),
        ),
        GoRoute(
          name: 'ad-request',
          path: 'ad-request',
          builder: (context, state) => const MerchantAdRequestScreen(),
        ),
        GoRoute(
          name: 'chat',
          path: 'chat',
          builder: (context, state) => const MerchantChatScreen(),
        ),
      ],
    ),
  ],
  redirect: (BuildContext context, GoRouterState state) {
    final bool loggedIn = authNotifier.isLoggedIn;
    final bool loggingIn = state.matchedLocation == '/login' || state.matchedLocation == '/register';

    if (!loggedIn) {
      // إذا لم يكن مسجلاً، اسمح له بالذهاب إلى /login أو /register فقط
      return loggingIn ? null : '/login';
    }

    if (loggingIn) {
      // إذا كان مسجلاً ويحاول الذهاب إلى /login أو /register، وجهه إلى الداشبورد
      return '/dashboard';
    }

    // إذا كان مسجلاً ولا يحاول الذهاب لصفحات الدخول، اسمح له بالمرور
    return null;
  },
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
      title: 'تاجر كوبونا',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
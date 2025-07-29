import 'package:coupona_merchant/screens/merchant_customers_screen.dart';
import 'package:coupona_merchant/screens/merchant_offers_screen.dart';
import 'package:coupona_merchant/screens/merchant_reports_screen.dart';
import 'package:coupona_merchant/screens/merchant_rewards_screen.dart';
import 'package:coupona_merchant/screens/settings_screen.dart';
import 'package:coupona_merchant/screens/store_community_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart'; // لاستخدام الحافظة

class MerchantDashboardScreen extends StatefulWidget {
  const MerchantDashboardScreen({super.key});

  @override
  State<MerchantDashboardScreen> createState() => _MerchantDashboardScreenState();
}

class _MerchantDashboardScreenState extends State<MerchantDashboardScreen> {
  String _storeName = 'لوحة التحكم';
  String? _merchantCode;
  final _supabase = Supabase.instance.client;
  final _user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    if (_user != null) {
      _fetchMerchantData();
    }
  }

  Future<void> _fetchMerchantData() async {
    try {
      final data = await _supabase
          .from('merchants')
          .select('store_name, merchant_code')
          .eq('id', _user!.uid)
          .single();
      if (mounted) {
        setState(() {
          _storeName = data['store_name'] ?? 'لوحة التحكم';
          _merchantCode = data['merchant_code'];
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في جلب بيانات المتجر: $e')),
        );
      }
    }
  }

  void _showMerchantCodeDialog() {
    if (_merchantCode == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('رمز التاجر غير متوفر حاليًا')),
      );
      return;
    }
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('رمز التاجر الخاص بك'),
        content: Text(
          _merchantCode!,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: _merchantCode!));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تم نسخ الرمز إلى الحافظة')),
              );
              Navigator.of(context).pop();
            },
            child: const Text('نسخ الرمز'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_storeName),
        actions: [
          IconButton(
            icon: const Icon(Icons.vpn_key),
            onPressed: _showMerchantCodeDialog,
            tooltip: 'عرض رمز التاجر',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              await Supabase.instance.client.auth.signOut();
              // لا تستخدم context في async gap
              if (mounted) {
                context.go('/login');
              }
            },
          ),
        ],
      ),
      body: Center(
        child: SizedBox(
          width: 500,
          child: GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            padding: const EdgeInsets.all(24),
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: [
              _DashboardTile(
                icon: Icons.storefront,
                label: 'العروض',
                onTap: () => context.go('/offers'),
              ),
              _DashboardTile(
                icon: Icons.card_giftcard,
                label: 'الجوائز',
                onTap: () => context.go('/rewards'),
              ),
              _DashboardTile(
                icon: Icons.people,
                label: 'زبائن المحل',
                onTap: () => context.go('/customers'),
              ),
              _DashboardTile(
                icon: Icons.chat_bubble,
                label: 'مجتمع المحل',
                onTap: () {
                  final userId = _user?.uid;
                  if (userId != null) {
                    context.go('/community/$userId');
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('لا يمكن الوصول للمجتمع، المستخدم غير مسجل')),
                    );
                  }
                },
              ),
              _DashboardTile(
                icon: Icons.bar_chart,
                label: 'التقارير',
                onTap: () => context.go('/reports'),
              ),
              _DashboardTile(
                icon: Icons.settings,
                label: 'الإعدادات',
                onTap: () => context.go('/settings'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Widget لبلاطة الشاشة
class _DashboardTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _DashboardTile({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 40, color: Colors.deepPurple),
              const SizedBox(height: 12),
              Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}
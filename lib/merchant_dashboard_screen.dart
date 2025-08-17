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
  int _customersCount = 0;
  int _pointsCount = 0;
  int _offersCount = 0;
  final _supabase = Supabase.instance.client;
  final _user = FirebaseAuth.instance.currentUser;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    if (_user != null) {
      _fetchMerchantData();
      _fetchStats();
    }
  }

  Future<void> _fetchStats() async {
    try {
      // عدد الزبائن
      final customers = await _supabase
          .from('store_group_members')
          .select('customerid')
          .eq('groupid', _user?.uid)
          .execute();
      _customersCount = customers.data?.length ?? 0;
      // عدد النقاط (مثال: مجموع النقاط في جدول النقاط)
      final points = await _supabase
          .from('points')
          .select('points')
          .eq('merchant_id', _user?.uid)
          .execute();
      _pointsCount = points.data?.fold(0, (sum, item) => sum + (item['points'] ?? 0)) ?? 0;
      // عدد العروض النشطة
      final offers = await _supabase
          .from('offers')
          .select('id')
          .eq('merchant_id', _user?.uid)
          .eq('isActive', true)
          .execute();
      _offersCount = offers.data?.length ?? 0;
      if (mounted) setState(() {});
    } catch (e) {
      // تجاهل الخطأ في الإحصائيات السريعة
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('رمز التاجر الخاص بك'),
        content: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            (_merchantCode != null && _merchantCode!.trim().isNotEmpty)
                ? _merchantCode!
                : 'لا يوجد رمز تاجر',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
              color: (_merchantCode != null && _merchantCode!.trim().isNotEmpty)
                  ? Colors.black87
                  : Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        actions: [
          if (_merchantCode != null && _merchantCode!.trim().isNotEmpty)
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
        title: Text(_storeName, style: const TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('القائمة الجانبية قريباً')));
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('الإشعارات قريباً')));
            },
          ),
          IconButton(
            icon: const Icon(Icons.person_add),
            tooltip: 'إضافة كاشير',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('إضافة كاشير قريباً')));
            },
          ),
          IconButton(
            icon: const Icon(Icons.vpn_key),
            onPressed: _showMerchantCodeDialog,
            tooltip: 'عرض رمز التاجر',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // إحصائيات سريعة
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _StatCard(label: 'الزبائن', value: _customersCount.toString(), icon: Icons.people),
                  _StatCard(label: 'النقاط', value: _pointsCount.toString(), icon: Icons.star),
                  _StatCard(label: 'العروض', value: _offersCount.toString(), icon: Icons.local_offer),
                ],
              ),
              const SizedBox(height: 24),
              // قائمة الوظائف الأساسية
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _DashboardTile(
                    icon: Icons.add_box,
                    label: 'إضافة عرض جديد',
                    onTap: () => context.go('/offers'),
                  ),
                  _DashboardTile(
                    icon: Icons.storefront,
                    label: 'إدارة العروض',
                    onTap: () => context.go('/offers'),
                  ),
                  _DashboardTile(
                    icon: Icons.qr_code_scanner,
                    label: 'قراءة الفواتير',
                    onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('قراءة الفواتير قريباً'))),
                  ),
                  _DashboardTile(
                    icon: Icons.analytics,
                    label: 'تحليل المبيعات',
                    onTap: () => context.go('/analytics'),
                  ),
                  _DashboardTile(
                    icon: Icons.chat,
                    label: 'التواصل مع الزبائن',
                    onTap: () => context.go('/customers'),
                  ),
                  _DashboardTile(
                    icon: Icons.loyalty,
                    label: 'إدارة النقاط',
                    onTap: () => context.go('/rewards'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() => _selectedIndex = index);
          switch (index) {
            case 0:
              context.go('/dashboard');
              break;
            case 1:
              context.go('/offers');
              break;
            case 2:
              final userId = _user?.uid;
              if (userId != null) {
                context.go('/dashboard/community/$userId');
              }
              break;
            case 3:
              context.go('/reports');
              break;
            case 4:
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('الرسائل قريباً')));
              break;
            case 5:
              context.go('/settings');
              break;
          }
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'الرئيسية'),
          BottomNavigationBarItem(icon: Icon(Icons.local_offer), label: 'العروض'),
          BottomNavigationBarItem(icon: Icon(Icons.groups), label: 'المجتمع'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'التقارير'),
          BottomNavigationBarItem(icon: Icon(Icons.message), label: 'الرسائل'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'الإعدادات'),
        ],
      ),
    );
// كرت إحصائية سريعة
class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const _StatCard({required this.label, required this.value, required this.icon});
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 32, color: Colors.deepPurple),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 13)),
          ],
        ),
      ),
    );
  }
}
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
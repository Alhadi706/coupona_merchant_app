import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:your_app_name/screens/complete_profile_screen.dart';

class MerchantDashboardScreen extends StatelessWidget {
  const MerchantDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(body: Center(child: Text('لا يوجد مستخدم مسجل')));
    }

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('merchants')
          .doc(user.uid)
          .get(),
      builder: (context, snapshot) {
        // حالة التحميل
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // حالة الخطأ
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Text('خطأ في جلب البيانات: ${snapshot.error}')),
          );
        }

        // إذا لم توجد بيانات
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return Scaffold(
            appBar: AppBar(title: const Text('لوحة التحكم')),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('لم يتم العثور على بيانات المتجر'),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const CompleteProfileScreen(),
                      ),
                    ),
                    child: const Text('إكمال الملف الشخصي'),
                  ),
                ],
              ),
            ),
          );
        }

        // إذا كانت البيانات موجودة
        final merchantData = snapshot.data!.data() as Map<String, dynamic>;
        return Scaffold(
          appBar: AppBar(
            title: Text(merchantData['store_name'] ?? 'لوحة التحكم'),
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
                    onTap: () => Navigator.of(context).pushNamed('/dashboard/offers'),
                  ),
                  _DashboardTile(
                    icon: Icons.card_giftcard,
                    label: 'الجوائز',
                    onTap: () => Navigator.of(context).pushNamed('/dashboard/rewards'),
                  ),
                  _DashboardTile(
                    icon: Icons.receipt_long,
                    label: 'الكاشير',
                    onTap: () => Navigator.of(context).pushNamed('/dashboard/cashier'),
                  ),
                  _DashboardTile(
                    icon: Icons.people,
                    label: 'الزبائن',
                    onTap: () => Navigator.of(context).pushNamed('/dashboard/customers'),
                  ),
                  _DashboardTile(
                    icon: Icons.chat_bubble,
                    label: 'المحادثات',
                    onTap: () => Navigator.of(context).pushNamed('/dashboard/chat'),
                  ),
                  _DashboardTile(
                    icon: Icons.analytics,
                    label: 'التحليلات',
                    onTap: () => Navigator.of(context).pushNamed('/dashboard/analytics'),
                  ),
                  _DashboardTile(
                    icon: Icons.flag,
                    label: 'البلاغات',
                    onTap: () => Navigator.of(context).pushNamed('/dashboard/reports'),
                  ),
                  _DashboardTile(
                    icon: Icons.settings,
                    label: 'الإعدادات',
                    onTap: () => Navigator.of(context).pushNamed('/dashboard/settings'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
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
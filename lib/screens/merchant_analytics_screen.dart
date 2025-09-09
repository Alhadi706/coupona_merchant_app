import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:coupona_merchant/gen_l10n/app_localizations.dart';

class MerchantAnalyticsScreen extends StatelessWidget {
  const MerchantAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // قائمة بجميع وظائف لوحة التحكم
    final loc = AppLocalizations.of(context);
    final List<Map<String, dynamic>> dashboardItems = [
      {
        'icon': Icons.local_offer,
        'label': loc?.offers ?? 'Offers',
        'path': '/dashboard/offers'
      },
      {
        'icon': Icons.shopping_bag,
        'label': loc?.products ?? 'Products',
        'path': '/dashboard/products'
      },
      {
        'icon': Icons.people,
        'label': loc?.customers ?? 'Customers',
        'path': '/dashboard/customers'
      },
      {
        'icon': Icons.receipt,
        'label': loc?.receipts ?? 'Receipts',
        'path': '/dashboard/receipts'
      },
      // Additional features (not yet localized keys created): keep Arabic fallback or add new keys later.
      {
        'icon': Icons.point_of_sale,
        'label': 'شاشة الكاشير',
        'path': '/dashboard/cashier'
      },
      {
        'icon': Icons.card_giftcard,
        'label': 'إدارة الجوائز',
        'path': '/dashboard/rewards'
      },
      {
        'icon': Icons.bar_chart,
        'label': 'التقارير والتحليلات',
        'path': '/dashboard/reports'
      },
      {
        'icon': Icons.forum,
        'label': 'المجتمع',
        'path': '/dashboard/community'
      },
      {
        'icon': Icons.settings,
        'label': loc?.settings ?? 'Settings',
        'path': '/dashboard/settings'
      },
    ];

    return Scaffold(
      body: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // عدد الأعمدة
          crossAxisSpacing: 16.0,
          mainAxisSpacing: 16.0,
          childAspectRatio: 1.2, // يمكن تعديل النسبة لتناسب التصميم
        ),
        padding: const EdgeInsets.all(16.0),
        itemCount: dashboardItems.length,
        itemBuilder: (context, index) {
          final item = dashboardItems[index];
          return _buildDashboardCard(
            context,
            icon: item['icon'],
            label: item['label'],
            onTap: () => context.go(item['path']),
          );
        },
      ),
    );
  }

  Widget _buildDashboardCard(BuildContext context, {required IconData icon, required String label, required VoidCallback onTap}) {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(icon, size: 50.0, color: Theme.of(context).primaryColor),
            const SizedBox(height: 16.0),
            Text(
              label,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }
}

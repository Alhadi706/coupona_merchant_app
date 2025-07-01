import 'package:flutter/material.dart';

class MerchantAnalyticsScreen extends StatelessWidget {
  const MerchantAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تحليلات المتجر'),
        backgroundColor: Colors.deepPurple.shade700,
      ),
      body: const AnalyticsBody(),
    );
  }
}

class AnalyticsBody extends StatelessWidget {
  const AnalyticsBody({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('ملخص سريع', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
          const SizedBox(height: 16),
          const _SummaryCards(),
          const SizedBox(height: 32),
          const Text('تحليل العروض', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
          const SizedBox(height: 12),
          const _OffersAnalytics(),
          const SizedBox(height: 32),
          const Text('سلوك الزبائن', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
          const SizedBox(height: 12),
          const _CustomerBehavior(),
          const SizedBox(height: 32),
          const Text('أفضل الزبائن', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
          const SizedBox(height: 12),
          const _TopCustomers(),
        ],
      ),
    );
  }
}

class _SummaryCards extends StatelessWidget {
  const _SummaryCards();

  @override
  Widget build(BuildContext context) {
    // بيانات وهمية
    final offers = 12;
    final orders = 45;
    final customers = 30;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _StatCard(title: 'العروض', value: offers, color: Colors.deepPurple),
        _StatCard(title: 'الطلبات', value: orders, color: Colors.purple),
        _StatCard(title: 'الزبائن', value: customers, color: Colors.indigo),
      ],
    );
  }
}

class _OffersAnalytics extends StatelessWidget {
  const _OffersAnalytics();

  @override
  Widget build(BuildContext context) {
    // بيانات وهمية
    final active = 7;
    final expired = 5;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _StatCard(title: 'نشطة', value: active, color: Colors.green),
        _StatCard(title: 'منتهية', value: expired, color: Colors.red),
      ],
    );
  }
}

class _CustomerBehavior extends StatelessWidget {
  const _CustomerBehavior();

  @override
  Widget build(BuildContext context) {
    // بيانات وهمية
    final total = 45;
    final redeemed = 30;
    final canceled = 10;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _StatCard(title: 'مستبدلة', value: redeemed, color: Colors.blue),
        _StatCard(title: 'ملغاة', value: canceled, color: Colors.orange),
        _StatCard(title: 'الإجمالي', value: total, color: Colors.deepPurple),
      ],
    );
  }
}

class _TopCustomers extends StatelessWidget {
  const _TopCustomers();

  @override
  Widget build(BuildContext context) {
    // بيانات وهمية
    final customers = [
      {'name': 'زبون A', 'orders': 12},
      {'name': 'زبون B', 'orders': 9},
      {'name': 'زبون C', 'orders': 7},
    ];

    return Column(
      children: customers.map((e) {
        return ListTile(
          leading: const Icon(Icons.person, color: Colors.deepPurple),
          title: Text(e['name'] as String),
          trailing: Text('${e['orders']} طلب'),
        );
      }).toList(),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final int value;
  final Color color;

  const _StatCard({required this.title, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      color: color.withOpacity(0.1),
      child: Container(
        width: 100,
        height: 100,
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('$value', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28, color: color)),
            const SizedBox(height: 8),
            Text(title, style: TextStyle(fontSize: 16, color: color)),
          ],
        ),
      ),
    );
  }
}

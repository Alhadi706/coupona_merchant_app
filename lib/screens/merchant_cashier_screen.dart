import 'package:flutter/material.dart';

class MerchantCashierScreen extends StatefulWidget {
  const MerchantCashierScreen({Key? key}) : super(key: key);

  @override
  State<MerchantCashierScreen> createState() => _MerchantCashierScreenState();
}

class _MerchantCashierScreenState extends State<MerchantCashierScreen> {
  // بيانات وهمية للكاشير
  final List<Map<String, dynamic>> _dummyCashiers = [
    {'id': '1', 'name': 'أحمد محمود', 'email': 'ahmad@example.com', 'role': 'cashier'},
    {'id': '2', 'name': 'فاطمة علي', 'email': 'fatima@example.com', 'role': 'super_cashier'},
    {'id': '3', 'name': 'خالد وليد', 'email': 'khaled@example.com', 'role': 'cashier'},
  ];

  Future<void> _addCashier() async {
    // محاكاة إضافة كاشير بدون قاعدة بيانات
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تمت إضافة الكاشير (محاكاة)')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة الكاشير'),
        backgroundColor: Colors.deepPurple.shade700,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addCashier,
        icon: const Icon(Icons.add),
        label: const Text('إضافة كاشير'),
        backgroundColor: Colors.deepPurple,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        separatorBuilder: (_, __) => const Divider(),
        itemCount: _dummyCashiers.length,
        itemBuilder: (context, i) {
          final cashier = _dummyCashiers[i];
          return Card(
            child: ListTile(
              leading: const Icon(Icons.person, color: Colors.deepPurple),
              title: Text(cashier['name'] ?? ''),
              subtitle: Text(cashier['email'] ?? ''),
              trailing: Text(cashier['role'] ?? ''),
            ),
          );
        },
      ),
    );
  }
}

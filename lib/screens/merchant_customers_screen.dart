import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:coupona_merchant/gen_l10n/app_localizations.dart';

class MerchantCustomersScreen extends StatelessWidget {
  const MerchantCustomersScreen({Key? key}) : super(key: key);

  Future<List<Map<String, dynamic>>> _fetchCustomers() async {
    final supabase = Supabase.instance.client;
    // الحصول على معرف التاجر الحالي من الجلسة
    final user = supabase.auth.currentUser;
    final merchantId = user?.id; // إذا كان لديك حقل مخصص للمعرف استخدمه
    if (merchantId == null) return [];

    // جلب customer_id المرتبطين بالتاجر من جدول الربط
    final merchantCustomers = await supabase
        .from('merchant_customers')
        .select('customer_id')
        .eq('merchant_id', merchantId);
    final customerIds = merchantCustomers.map((e) => e['customer_id'] as String).toList();
    if (customerIds.isEmpty) return [];

    // جلب بيانات الزبائن من جدول customers
    final customers = await supabase
        .from('customers')
        .select()
        .inFilter('id', customerIds);
    return List<Map<String, dynamic>>.from(customers);
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(loc?.manageCustomersTitle ?? 'Customers'),
        backgroundColor: Colors.deepPurple,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchCustomers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('${loc?.customersFetchError ?? 'Error'}: ${snapshot.error}'));
          }
          final customers = snapshot.data ?? [];
          if (customers.isEmpty) {
            return Center(child: Text(loc?.noCustomersYet ?? 'No customers'));
          }
          return ListView.builder(
            itemCount: customers.length,
            itemBuilder: (context, index) {
              final customer = customers[index];
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.person, color: Colors.deepPurple),
                  title: Text(customer['name'] ?? ''),
                  subtitle: Text(loc?.pointsLabel((customer['points'] ?? 0) as int) ?? 'Points: ${customer['points'] ?? 0}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.info_outline, color: Colors.blue),
                    tooltip: loc?.customerDetailsTitle ?? 'Details',
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        '/customer-details',
                        arguments: customer['id'],
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

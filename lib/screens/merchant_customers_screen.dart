import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';
import 'package:coupona_merchant/widgets/cached_firestore_list.dart';

class MerchantCustomersScreen extends StatelessWidget {
  const MerchantCustomersScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة الزبائن'),
        backgroundColor: Colors.deepPurple,
      ),
      body: CachedFirestoreList<Map<String, dynamic>>(
        query: FirebaseFirestore.instance.collection('customers'),
        itemBuilder: (context, customer) {
          return Card(
            child: ListTile(
              leading: const Icon(Icons.person, color: Colors.deepPurple),
              title: Text(customer['name'] ?? ''),
              subtitle: Text('النقاط: ${customer['points'] ?? 0}'),
              trailing: IconButton(
                icon: const Icon(Icons.info_outline, color: Colors.blue),
                tooltip: 'تفاصيل الزبون',
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
        emptyWidget: const Center(child: Text('لا يوجد زبائن بعد')),
      ),
    );
  }
}

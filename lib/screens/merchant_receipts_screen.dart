import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive/hive.dart';
import 'package:coupona_merchant/widgets/cached_firestore_list.dart';

class MerchantReceiptsScreen extends StatelessWidget {
  const MerchantReceiptsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final merchantId = FirebaseAuth.instance.currentUser?.uid ?? 'demo_merchant_uid';
    return Scaffold(
      appBar: AppBar(
        title: const Text('سجل الفواتير'),
        backgroundColor: Colors.deepPurple.shade700,
      ),
      body: CachedFirestoreList<Map<String, dynamic>>(
        query: FirebaseFirestore.instance
            .collection('receipts')
            .where('merchantId', isEqualTo: merchantId)
            .orderBy('created_at', descending: true), // تعديل اسم العمود
        itemBuilder: (context, receipt) {
          final status = receipt['status'] ?? 'قيد المراجعة';
          final products = List<Map<String, dynamic>>.from(receipt['products'] ?? []);
          return Card(
            child: ExpansionTile(
              leading: Icon(
                status == 'مقبولة'
                    ? Icons.check_circle
                    : status == 'مرفوضة'
                        ? Icons.cancel
                        : Icons.copy,
                color: status == 'مقبولة'
                    ? Colors.green
                    : status == 'مرفوضة'
                        ? Colors.red
                        : Colors.orange,
              ),
              title: Text('فاتورة رقم: ${receipt['receiptNumber'] ?? '-'}'),
              subtitle: Row(
                children: [
                  Chip(
                    label: Text('الحالة: $status'),
                    backgroundColor: status == 'مقبولة'
                        ? Colors.green.shade50
                        : status == 'مرفوضة'
                            ? Colors.red.shade50
                            : Colors.orange.shade50,
                  ),
                  const SizedBox(width: 8),
                  Text(receipt['created_at'] != null // تعديل اسم العمود
                      ? (receipt['created_at'] as Timestamp).toDate().toString().substring(0, 16) // تعديل اسم العمود
                      : ''),
                ],
              ),
              children: [
                ...products.map((prod) => ListTile(
                      leading: const Icon(Icons.shopping_bag),
                      title: Text(prod['name'] ?? ''),
                      subtitle: Text('الكمية: ${prod['qty'] ?? 1} | السعر: ${prod['price'] ?? '-'}'),
                    )),
                if (products.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('لا توجد تفاصيل منتجات'),
                  ),
              ],
            ),
          );
        },
        emptyWidget: const Center(child: Text('لا توجد فواتير بعد')),
      ),
    );
  }
}

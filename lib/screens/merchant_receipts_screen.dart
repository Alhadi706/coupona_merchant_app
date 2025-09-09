import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive/hive.dart';
import 'package:coupona_merchant/widgets/cached_firestore_list.dart';
import 'package:coupona_merchant/gen_l10n/app_localizations.dart';

class MerchantReceiptsScreen extends StatelessWidget {
  const MerchantReceiptsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final merchantId = FirebaseAuth.instance.currentUser?.uid ?? 'demo_merchant_uid';
    final loc = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(loc?.receiptsLogTitle ?? 'Receipts'),
        backgroundColor: Colors.deepPurple.shade700,
      ),
      body: CachedFirestoreList<Map<String, dynamic>>(
        query: FirebaseFirestore.instance
            .collection('receipts')
            .where('merchantId', isEqualTo: merchantId)
            .orderBy('created_at', descending: true), // تعديل اسم العمود
        itemBuilder: (context, receipt) {
          final rawStatus = (receipt['status'] as String?)?.trim();
          String statusKey;
          switch (rawStatus) {
            case 'مقبولة':
            case 'Accepted':
              statusKey = loc?.statusAccepted ?? 'Accepted';
              break;
            case 'مرفوضة':
            case 'Rejected':
              statusKey = loc?.statusRejected ?? 'Rejected';
              break;
            default:
              statusKey = loc?.statusPending ?? 'Pending';
          }
          final products = List<Map<String, dynamic>>.from(receipt['products'] ?? []);
          return Card(
            child: ExpansionTile(
              leading: Icon(
                (statusKey == (loc?.statusAccepted ?? 'Accepted'))
                    ? Icons.check_circle
                    : (statusKey == (loc?.statusRejected ?? 'Rejected'))
                        ? Icons.cancel
                        : Icons.copy,
                color: (statusKey == (loc?.statusAccepted ?? 'Accepted'))
                    ? Colors.green
                    : (statusKey == (loc?.statusRejected ?? 'Rejected'))
                        ? Colors.red
                        : Colors.orange,
              ),
              title: Text(loc?.invoiceNumberShort((receipt['receiptNumber'] ?? '-').toString()) ?? 'Receipt #: ${receipt['receiptNumber'] ?? '-'}'),
              subtitle: Row(
                children: [
                  Chip(
                    label: Text(loc?.statusLabel(statusKey) ?? 'Status: $statusKey'),
                    backgroundColor: (statusKey == (loc?.statusAccepted ?? 'Accepted'))
                        ? Colors.green.shade50
                        : (statusKey == (loc?.statusRejected ?? 'Rejected'))
                            ? Colors.red.shade50
                            : Colors.orange.shade50,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    receipt['created_at'] != null
                        ? (loc?.createdAtLabel((receipt['created_at'] as Timestamp).toDate().toString().substring(0, 16)) ?? (receipt['created_at'] as Timestamp).toDate().toString().substring(0, 16))
                        : '',
                  ),
                ],
              ),
              children: [
                ...products.map((prod) => ListTile(
                      leading: const Icon(Icons.shopping_bag),
                      title: Text(prod['name'] ?? ''),
                      subtitle: Text(
                        loc?.quantityPrice(
                              (prod['qty'] ?? 1) is int ? prod['qty'] ?? 1 : int.tryParse('${prod['qty']}') ?? 1,
                              (prod['price'] ?? '-').toString(),
                            ) ?? 'Qty: ${prod['qty'] ?? 1} | Price: ${prod['price'] ?? '-'}',
                      ),
                    )),
                if (products.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(loc?.noProductDetails ?? 'No details'),
                  ),
              ],
            ),
          );
        },
        emptyWidget: Center(child: Text(loc?.noReceiptsYet ?? 'No receipts')),
      ),
    );
  }
}

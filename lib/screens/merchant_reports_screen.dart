import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MerchantReportsScreen extends StatelessWidget {
  const MerchantReportsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('بلاغات الزبائن')),
        body: const Center(child: Text('الرجاء تسجيل الدخول لعرض البلاغات.')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('بلاغات الزبائن')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('reports')
            .where('merchantId', isEqualTo: user.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('حدث خطأ في جلب البيانات: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return const Center(child: Text('لا توجد بلاغات حتى الآن'));
          }
          docs.sort((a, b) {
            final aTs = (a.data() as Map<String, dynamic>)['createdAt'] as Timestamp?;
            final bTs = (b.data() as Map<String, dynamic>)['createdAt'] as Timestamp?;
            if (bTs == null) return -1;
            if (aTs == null) return 1;
            return bTs.compareTo(aTs);
          });
          return ListView.separated(
            itemCount: docs.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, i) {
              final report = docs[i].data() as Map<String, dynamic>;
              return ListTile(
                leading: const Icon(Icons.report, color: Colors.red),
                title: Text(report['title'] ?? 'بلاغ بدون عنوان'),
                subtitle: Text(report['description'] ?? ''),
                trailing: Text(report['createdAt'] != null
                    ? (report['createdAt'] as Timestamp).toDate().toString()
                    : ''),
              );
            },
          );
        },
      ),
    );
  }
}

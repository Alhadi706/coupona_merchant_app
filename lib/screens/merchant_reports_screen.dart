import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchReports(user.uid),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('حدث خطأ في جلب البيانات: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snapshot.data ?? [];
          if (docs.isEmpty) {
            return const Center(child: Text('لا توجد بلاغات حتى الآن'));
          }
          docs.sort((a, b) {
            final aTs = DateTime.tryParse(a['createdAt']?.toString() ?? '');
            final bTs = DateTime.tryParse(b['createdAt']?.toString() ?? '');
            if (bTs == null) return -1;
            if (aTs == null) return 1;
            return bTs.compareTo(aTs);
          });
          return ListView.separated(
            itemCount: docs.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, i) {
              final report = docs[i];
              return ListTile(
                leading: const Icon(Icons.report, color: Colors.red),
                title: Text(report['title'] ?? 'بلاغ بدون عنوان'),
                subtitle: Text(report['description'] ?? ''),
                trailing: Text(report['createdAt'] != null
                    ? DateTime.tryParse(report['createdAt'].toString())?.toString() ?? ''
                    : ''),
              );
            },
          );
        },
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _fetchReports(String merchantId) async {
    final supabase = Supabase.instance.client;
    final response = await supabase
        .from('reports')
        .select()
        .eq('merchantId', merchantId);
    return List<Map<String, dynamic>>.from(response);
  }
}

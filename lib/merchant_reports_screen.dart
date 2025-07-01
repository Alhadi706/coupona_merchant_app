import 'package:flutter/material.dart';

class MerchantReportsScreen extends StatelessWidget {
  const MerchantReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // بيانات تجريبية للبلاغات
    final List<Map<String, dynamic>> demoReports = [
      {
        'title': 'مشكلة في المنتج',
        'description': 'المنتج غير مطابق للمواصفات المعلنة',
        'createdAt': '2023-05-15',
      },
      {
        'title': 'تأخر في التوصيل',
        'description': 'الطلب تأخر أكثر من أسبوع عن الموعد المحدد',
        'createdAt': '2023-05-10',
      },
      {
        'title': 'سوء معاملة',
        'description': 'موظف التوصيل تعامل بطريقة غير لائقة',
        'createdAt': '2023-05-05',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('بلاغات الزبائن'),
      ),
      body: demoReports.isEmpty
          ? const Center(child: Text('لا توجد بلاغات حتى الآن'))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: demoReports.length,
              separatorBuilder: (context, i) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final report = demoReports[i];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    leading: const Icon(Icons.report, color: Colors.red),
                    title: Text(
                      report['title'] ?? 'بلاغ بدون عنوان',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(report['description'] ?? ''),
                        const SizedBox(height: 8),
                        Text(
                          'التاريخ: ${report['createdAt']}',
                          style: const TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                    onTap: () {
                      // يمكنك إضافة تفاصيل إضافية عند النقر على البلاغ
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text(report['title']),
                          content: Text(report['description']),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('إغلاق'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
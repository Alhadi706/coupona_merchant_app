import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:coupona_merchant/gen_l10n/app_localizations.dart';

class CustomerReportsScreen extends StatefulWidget {
  const CustomerReportsScreen({Key? key}) : super(key: key);

  @override
  State<CustomerReportsScreen> createState() => _CustomerReportsScreenState();
}

class _CustomerReportsScreenState extends State<CustomerReportsScreen> {
  // تم حذف الاتصال بقاعدة البيانات والاعتماد على بيانات وهمية
  final List<Map<String, dynamic>> _dummyReports = List.generate(
    10,
    (i) => {
      'id': 'report_${i + 1}',
      'message': 'هذا مثال لبلاغ رقم ${i + 1} من أحد الزبائن. يحتوي البلاغ على تفاصيل المشكلة.',
      'createdAt': Timestamp(1672531200 + i * 86400, 0), // بيانات وهمية للتاريخ
    },
  );

  // محاكاة لفئة Timestamp الخاصة بـ Firestore
  // يمكنك حذفها إذا لم تكن هناك حاجة إليها
  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(loc?.customerReportsTitle ?? 'Reports')),
      body: ListView.builder(
        itemCount: _dummyReports.length,
        itemBuilder: (context, i) {
          final report = _dummyReports[i];
          final createdAt = report['createdAt'];
          String formattedDate = loc?.unknownDate ?? 'Unknown date';
          if (createdAt is Timestamp) {
            formattedDate =
                DateFormat('yyyy/MM/dd – hh:mm a').format(createdAt.toDate());
          }

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: ListTile(
              leading: const Icon(Icons.report, color: Colors.red),
              title: Text(report['message'] ?? (loc?.noMessage ?? 'No message'),
                  maxLines: 2, overflow: TextOverflow.ellipsis),
              subtitle: Text(loc?.reportDate(formattedDate) ?? 'Date: $formattedDate'),
              trailing: Text('#${report['id']?.substring(0, 8) ?? ''}'),
            ),
          );
        },
      ),
    );
  }
}

// فئة وهمية لتحل محل Timestamp الخاصة بـ Firestore
class Timestamp {
  final int _seconds;
  final int _nanoseconds;

  Timestamp(this._seconds, this._nanoseconds);

  DateTime toDate() {
    return DateTime.fromMillisecondsSinceEpoch(_seconds * 1000 + _nanoseconds ~/ 1000000);
  }
}

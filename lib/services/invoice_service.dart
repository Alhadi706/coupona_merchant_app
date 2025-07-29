import 'package:supabase_flutter/supabase_flutter.dart';

/// إضافة فاتورة جديدة إلى قاعدة البيانات
Future<void> addInvoice({
  required String merchantId,
  required String merchantName,
  required String customerId,
  required String invoiceNumber,
  required DateTime date,
  required double totalAmount,
  List<Map<String, dynamic>>? items, // يمكن أن تكون null
  String? imageUrl,
  String? uniqueHash,
  String? notes,
}) async {
  final supabase = Supabase.instance.client;
  final response = await supabase.from('invoices').insert({
    'merchant_id': merchantId,
    'merchant_name': merchantName,
    'customer_id': customerId,
    'invoice_number': invoiceNumber,
    'date': date.toIso8601String(),
    'total_amount': totalAmount,
    'items': items, // يمكن أن تكون null
    'image_url': imageUrl,
    'unique_hash': uniqueHash,
    'notes': notes,
  });
  if (response.error != null) {
    throw Exception('فشل في إضافة الفاتورة: ${response.error!.message}');
  }

  // إضافة الزبون كعضو في قروب المحل إذا لم يكن موجودًا
  final group = await supabase
      .from('store_groups')
      .select('id')
      .eq('adminid', merchantId)
      .maybeSingle();
  if (group != null) {
    final groupId = group['id'];
    // تحقق من وجود الزبون مسبقًا في جدول أعضاء القروب
    final member = await supabase
        .from('store_group_members')
        .select()
        .eq('groupid', groupId)
        .eq('customerid', customerId)
        .maybeSingle();
    if (member == null) {
      await supabase.from('store_group_members').insert({
        'groupid': groupId,
        'customerid': customerId,
        'joinedat': DateTime.now().toIso8601String(),
      });
    }
  }
}

/// إضافة عرض تجريبي مرتبط بالمستخدم الحالي
Future<void> addDemoOffer({
  required String merchantId,
}) async {
  final supabase = Supabase.instance.client;
  final response = await supabase.from('offers').insert({
    'merchant_id': merchantId,
    'title': 'عرض تجريبي',
    'description': 'هذا عرض تجريبي للتأكد من ظهور العروض',
    'discount': 10,
    'isActive': true,
    // تأكد من أن اسم العمود متوافق مع قاعدة البيانات
    'createdAt': DateTime.now().toIso8601String(),
  });
  if (response.error != null) {
    // تحسين رسالة الخطأ لتوضيح مشكلة الأعمدة
    if (response.error!.message.contains('column') && response.error!.message.contains('does not exist')) {
      throw Exception('خطأ في إضافة العرض التجريبي: تحقق من اسم العمود createdAt في جدول offers بقاعدة البيانات Supabase');
    }
    throw Exception('فشل في إضافة العرض التجريبي: ${response.error!.message}');
  }
}

/// مثال على استخدام دالة إضافة الفاتورة:
void exampleUsage() async {
  await addInvoice(
    merchantId: 'merchant123',
    merchantName: 'سوبرماركت النجاح',
    customerId: 'customer456',
    invoiceNumber: 'INV-2025-001',
    date: DateTime.now(),
    totalAmount: 120.0,
    items: [
      {'name': 'منتج 1', 'quantity': 2, 'price': 10},
      {'name': 'منتج 2', 'quantity': 1, 'price': 100},
    ],
    imageUrl: 'https://example.com/invoice.jpg',
    uniqueHash: 'hash123',
    notes: 'فاتورة تم إدخالها عبر التطبيق',
  );
}

/// عند الاستعلام عن الفواتير وتحليلها:
/// يمكنك التحقق من وجود تفاصيل الأصناف أو الاكتفاء بالإجمالي فقط
void analyzeInvoices(List<Map<String, dynamic>> invoices) {
  for (final invoice in invoices) {
    final items = invoice['items'];
    if (items != null) {
      // تحليل الأصناف
      for (final item in items) {
        print('الصنف: ${item['name']}, الكمية: ${item['quantity']}, السعر: ${item['price']}');
      }
    } else {
      print('لا توجد تفاصيل أصناف، فقط الإجمالي: ${invoice['total_amount']}');
    }
  }
}

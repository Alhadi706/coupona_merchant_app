import 'package:supabase_flutter/supabase_flutter.dart';

/// خدمة فواتير موحدة (نقاط حسب المنتج فقط).
/// الجداول المقترحة (تنشأ في Supabase):
/// invoices(id uuid pk, merchant_id text, customer_ref text null, customer_phone text, customer_email text,
///          total_points int, total_amount numeric, image_url text, created_at timestamptz)
/// invoice_items(id uuid pk, invoice_id uuid fk, product_id uuid null, product_name text, product_points int,
///          product_price numeric null, quantity int, line_points int, line_amount numeric, created_at timestamptz)
/// customers(id uuid pk, merchant_id text, customer_ref text, phone text, email text, total_points int, created_at timestamptz)
/// customer_points_ledger(id uuid pk, merchant_id text, customer_ref text, invoice_id uuid, delta_points int, balance_after int, created_at timestamptz)
class InvoiceService {
  static final _c = Supabase.instance.client;

  /// lines: [{product_id?, product_name, product_points, product_price, quantity}]
  static Future<String> createInvoice({
    required String merchantId,
    required List<Map<String,dynamic>> lines,
    String? customerPhone,
    String? customerEmail,
    String? imageUrl,
  }) async {
    if (lines.isEmpty) throw 'لا توجد عناصر';
    int totalPoints = 0; double totalAmount = 0;
    final prepared = <Map<String,dynamic>>[];
    for (final l in lines) {
      final qty = (l['quantity'] as int?) ?? 1;
      final pPts = (l['product_points'] as int?) ?? 0;
      final price = (l['product_price'] as num?)?.toDouble();
      final linePts = pPts * qty;
      final lineAmt = price==null?0:price*qty;
      totalPoints += linePts; totalAmount += lineAmt;
      prepared.add({
        'product_id': l['product_id'],
        'product_name': l['product_name'],
        'product_points': pPts,
        'product_price': price,
        'quantity': qty,
        'line_points': linePts,
        'line_amount': lineAmt,
      });
    }
    final customerRef = _normalizeCustomerRef(phone: customerPhone, email: customerEmail);
    final invIns = {
      'merchant_id': merchantId,
      'customer_ref': customerRef,
      'customer_phone': customerPhone,
      'customer_email': customerEmail?.toLowerCase(),
      'total_points': totalPoints,
      'total_amount': totalAmount,
      'image_url': imageUrl,
      'created_at': DateTime.now().toIso8601String(),
    };
    final inv = await _c.from('invoices').insert(invIns).select('id').maybeSingle();
    if (inv == null || inv['id']==null) throw 'تعذر إنشاء الفاتورة';
    final invoiceId = inv['id'].toString();

    // items
    const batch = 60;
    for (var i=0;i<prepared.length;i+=batch){
      final slice = prepared.sublist(i, (i+batch).clamp(0, prepared.length));
      await _c.from('invoice_items').insert(slice.map((m)=>{
        'invoice_id': invoiceId,
        ...m,
        'created_at': DateTime.now().toIso8601String(),
      }).toList());
    }

    if (customerRef!=null) {
      int newBalance = totalPoints; int old=0;
      final existing = await _c.from('customers')
        .select('id,total_points')
        .eq('merchant_id', merchantId)
        .eq('customer_ref', customerRef)
        .maybeSingle();
      if (existing!=null) {
        old = (existing['total_points'] as int?)??0;
        newBalance = old + totalPoints;
        await _c.from('customers').update({'total_points': newBalance})
          .eq('merchant_id', merchantId)
          .eq('customer_ref', customerRef);
      } else {
        await _c.from('customers').insert({
          'merchant_id': merchantId,
          'customer_ref': customerRef,
          'phone': customerPhone,
          'email': customerEmail?.toLowerCase(),
          'total_points': totalPoints,
          'created_at': DateTime.now().toIso8601String(),
        });
      }
      await _c.from('customer_points_ledger').insert({
        'merchant_id': merchantId,
        'customer_ref': customerRef,
        'invoice_id': invoiceId,
        'delta_points': totalPoints,
        'balance_after': newBalance,
        'created_at': DateTime.now().toIso8601String(),
      });
    }
    return invoiceId;
  }

  static String? _normalizeCustomerRef({String? phone, String? email}) {
    if (phone!=null && phone.trim().isNotEmpty) {
      final digits = phone.replaceAll(RegExp(r'[^0-9+]'), '');
      return 'tel:$digits';
    }
    if (email!=null && email.trim().isNotEmpty) {
      return 'mail:${email.trim().toLowerCase()}';
    }
    return null;
  }
}

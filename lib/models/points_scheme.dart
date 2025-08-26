class PointsScheme {
  final String id;
  final String merchantId;
  final String mode; // per_amount | per_quantity | per_invoice | per_product
  final double? amountPerPoint; // دينار لكل نقطة
  final int? quantityPerPoint; // عدد القطع لكل نقطة
  final int? pointsPerInvoice; // نقاط ثابتة لكل فاتورة
  final DateTime createdAt;
  final DateTime updatedAt;

  const PointsScheme({
    required this.id,
    required this.merchantId,
    required this.mode,
    this.amountPerPoint,
    this.quantityPerPoint,
    this.pointsPerInvoice,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PointsScheme.fromMap(Map<String,dynamic> m) => PointsScheme(
    id: m['id'].toString(),
    merchantId: m['merchant_id'].toString(),
    mode: m['mode'].toString(),
    amountPerPoint: m['amount_per_point'] == null ? null : double.tryParse(m['amount_per_point'].toString()),
    quantityPerPoint: m['quantity_per_point'] as int?,
    pointsPerInvoice: m['points_per_invoice'] as int?,
    createdAt: DateTime.parse(m['created_at'].toString()),
    updatedAt: DateTime.parse(m['updated_at'].toString()),
  );

  Map<String,dynamic> toUpdate() => {
    'mode': mode,
    'amount_per_point': amountPerPoint,
    'quantity_per_point': quantityPerPoint,
    'points_per_invoice': pointsPerInvoice,
    'updated_at': DateTime.now().toIso8601String(),
  }..removeWhere((k,v)=>v==null);
}

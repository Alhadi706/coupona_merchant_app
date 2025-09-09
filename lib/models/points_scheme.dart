class PointsScheme {
  final String id;
  final String merchantId;
  final String mode; // ثابت الآن: per_product
  final DateTime createdAt;
  final DateTime updatedAt;

  const PointsScheme({
    required this.id,
    required this.merchantId,
    required this.mode,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PointsScheme.fromMap(Map<String,dynamic> m) => PointsScheme(
    id: m['id'].toString(),
    merchantId: m['merchant_id'].toString(),
    mode: m['mode'].toString(),
    createdAt: DateTime.parse(m['created_at'].toString()),
    updatedAt: DateTime.parse(m['updated_at'].toString()),
  );

  Map<String,dynamic> toUpdate() => {
    'mode': mode,
    'updated_at': DateTime.now().toIso8601String(),
  };
}

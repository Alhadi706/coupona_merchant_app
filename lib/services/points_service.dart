import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/points_scheme.dart';

class PointsService {
  static final _client = Supabase.instance.client;

  static Future<PointsScheme> fetchOrCreateScheme(String merchantId) async {
    final resp = await _client
        .from('merchant_point_scheme')
        .select()
        .eq('merchant_id', merchantId)
        .maybeSingle();
    if (resp != null) {
      return PointsScheme.fromMap(Map<String, dynamic>.from(resp as Map));
    }
    final insert = {
      'merchant_id': merchantId,
      'mode': 'per_product',
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };
    final ins = await _client
        .from('merchant_point_scheme')
        .insert(insert)
        .select()
        .maybeSingle();
    if (ins == null) {
      // Fallback minimal object (should rarely happen) – caller can re-fetch later.
      return PointsScheme.fromMap({
        'id': 'temp-${DateTime.now().millisecondsSinceEpoch}',
        'merchant_id': merchantId,
        'mode': 'per_product',
        'amount_per_point': null,
        'quantity_per_point': null,
        'points_per_invoice': null,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });
    }
    return PointsScheme.fromMap(Map<String, dynamic>.from(ins as Map));
  }

  static Future<PointsScheme?> getScheme(String merchantId) async {
    final resp = await _client
        .from('merchant_point_scheme')
        .select()
        .eq('merchant_id', merchantId)
        .maybeSingle();
    if (resp == null) return null;
    return PointsScheme.fromMap(Map<String, dynamic>.from(resp as Map));
  }

  static Future<PointsScheme> updateScheme(String merchantId, PointsScheme draft) async {
    final resp = await _client
        .from('merchant_point_scheme')
        .update(draft.toUpdate())
        .eq('merchant_id', merchantId)
        .select()
        .maybeSingle();
    if (resp == null) {
      // If update returned nothing (rare), just return draft with new updatedAt.
      return draft;
    }
    return PointsScheme.fromMap(Map<String, dynamic>.from(resp as Map));
  }

  static int computePoints(PointsScheme scheme, {double amount = 0, int totalQuantity = 0, int productPointsSum = 0, int invoiceCount = 1}) {
    switch (scheme.mode) {
      case 'per_amount':
        final per = scheme.amountPerPoint ?? 0;
        if (per <= 0) return 0;
        return (amount / per).floor();
      case 'per_quantity':
        final q = scheme.quantityPerPoint ?? 0;
        if (q <= 0) return 0;
        return (totalQuantity / q).floor();
      case 'per_invoice':
        final p = scheme.pointsPerInvoice ?? 0;
        return p * invoiceCount;
      case 'per_product':
      default:
        return productPointsSum;
    }
  }
}

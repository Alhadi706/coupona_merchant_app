import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';

/// خدمة بحث منتجات غامض (fuzzy) باستخدام pg_trgm على العمود canonical_name
class ProductSearchService {
  static final _client = SupabaseService.client;

  /// بحث غامض داخل منتجات التاجر الحالي مرتب حسب التشابه.
  /// يتطلب إنشاء الدالة search_merchant_products في قاعدة البيانات.
  static Future<List<Map<String, dynamic>>> fuzzySearch(String query, {int limit = 10}) async {
    if (query.trim().isEmpty) return [];
    final user = _client.auth.currentUser;
    if (user == null) return [];
    final res = await _client.rpc('search_merchant_products', params: {
      'p_merchant_id': user.id,
      'p_query': query,
      'p_limit': limit,
    });
    if (res is List) {
      return res.cast<Map<String, dynamic>>();
    }
    return [];
  }
}

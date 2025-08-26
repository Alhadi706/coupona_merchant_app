import 'package:supabase_flutter/supabase_flutter.dart';

class RewardRedeemResult {
  final bool success;
  final String message;
  final Map<String, dynamic>? claim;
  final Map<String, dynamic>? reward;
  RewardRedeemResult({required this.success, required this.message, this.claim, this.reward});
}

class RewardService {
  static final _client = Supabase.instance.client;

  /// Redeem a reward claim using a QR token.
  /// Flow:
  /// 1. Find claim by qr_token.
  /// 2. Validate ownership (merchant_id == auth.uid()).
  /// 3. Ensure not already consumed.
  /// 4. Mark consumed + consumed_at.
  static Future<RewardRedeemResult> redeemByToken(String token) async {
    if (token.trim().isEmpty) {
      return RewardRedeemResult(success: false, message: 'رمز فارغ');
    }
    final uid = _client.auth.currentUser?.id;
    if (uid == null) {
      return RewardRedeemResult(success: false, message: 'جلسة Supabase غير موجودة');
    }
    try {
      final claim = await _client
          .from('reward_claims')
          .select()
          .eq('qr_token', token)
          .maybeSingle();
      if (claim == null) {
        return RewardRedeemResult(success: false, message: 'رمز غير صالح (Claim غير موجود)');
      }
      if (claim['merchant_id'] != uid) {
        return RewardRedeemResult(success: false, message: 'غير مخوّل لهذا الرمز');
      }
      if (claim['consumed'] == true) {
        return RewardRedeemResult(success: false, message: 'تم استخدام هذا الرمز مسبقاً');
      }
      // Fetch reward (اختياري)
      Map<String, dynamic>? reward;
      try {
        reward = await _client
            .from('rewards')
            .select()
            .eq('id', claim['reward_id'])
            .maybeSingle();
      } catch (_) {}

      // Update claim
      final updated = await _client
          .from('reward_claims')
          .update({'consumed': true, 'consumed_at': DateTime.now().toIso8601String()})
          .eq('id', claim['id'])
          .select()
          .maybeSingle();

      return RewardRedeemResult(success: true, message: 'تم تسليم الجائزة بنجاح', claim: updated, reward: reward);
    } catch (e) {
      return RewardRedeemResult(success: false, message: 'خطأ أثناء التحقق: $e');
    }
  }
}

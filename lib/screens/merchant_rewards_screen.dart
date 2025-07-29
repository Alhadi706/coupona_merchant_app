import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:intl/intl.dart'; // لاستخدامه في تنسيق التاريخ
import 'package:coupona_merchant/screens/add_edit_reward_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MerchantRewardsScreen extends StatefulWidget {
  const MerchantRewardsScreen({Key? key}) : super(key: key);

  @override
  State<MerchantRewardsScreen> createState() => _MerchantRewardsScreenState();
}

class _MerchantRewardsScreenState extends State<MerchantRewardsScreen> {
  String? merchantId;
  bool loading = true;
  List<Map<String, dynamic>> rewards = [];
  List<Map<String, dynamic>> redeemed = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => loading = false);
      return;
    }
    merchantId = user.uid;
    final supabase = Supabase.instance.client;
    try {
      final rewardsResponse = await supabase
          .from('rewards')
          .select()
          .eq('merchant_id', merchantId!)
          .eq('active', true)
          .order('created_at', ascending: false);
      rewards = List<Map<String, dynamic>>.from(rewardsResponse);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('حدث خطأ في جلب الجوائز: $e')),
        );
      }
    }
    try {
      final redeemedResponse = await supabase
          .from('redeemed_rewards')
          .select()
          .eq('merchant_id', merchantId!)
          .order('redeemedAt', ascending: false);
      redeemed = List<Map<String, dynamic>>.from(redeemedResponse);
    } catch (e) {
      print("خطأ في جلب سجل الاستبدال: $e");
    }
    if (mounted) {
      setState(() => loading = false);
    }
  }

  Future<void> _deleteReward(String rewardId) async {
    try {
      final supabase = Supabase.instance.client;
      await supabase.from('rewards').delete().eq('id', rewardId);
      _fetchData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('حدث خطأ أثناء حذف الجائزة: $e')),
        );
      }
    }
  }

  void _showQrDialog(Map<String, dynamic> reward) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('QR لاستلام الجائزة'),
        content: SizedBox(
          width: 200,
          height: 200,
          child: QrImageView(
            data: reward['qrCode'] ?? reward['id'],
            version: QrVersions.auto,
            size: 200.0,
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('إغلاق')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('إدارة الجوائز'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'الجوائز المفعلة'),
              Tab(text: 'سجل الاستبدال'),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              tooltip: 'إضافة جائزة جديدة',
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddEditRewardScreen(),
                  ),
                );
                if (result == true) {
                  _fetchData(); // Refresh the list if a reward was added
                }
              },
            ),
          ],
        ),
        body: loading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                children: [
                  // Tab 1: الجوائز المفعلة
                  _buildRewardsList(),
                  // Tab 2: سجل الاستبدال
                  _buildRedeemedList(),
                ],
              ),
      ),
    );
  }

  Widget _buildRewardsList() {
    if (rewards.isEmpty) {
      return const Center(child: Text('لا توجد جوائز مفعلة حاليًا.'));
    }
    return ListView.builder(
      itemCount: rewards.length,
      itemBuilder: (context, i) {
        final data = rewards[i];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: ListTile(
            leading: CircleAvatar(
              child: Text(data['pointsCost']?.toString() ?? '0'),
            ),
            title: Text(data['title'] ?? 'جائزة بدون عنوان'),
            subtitle: Text(data['description'] ?? ''),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.grey),
                  onPressed: () async {
                     final result = await Navigator.push(
                       context,
                       MaterialPageRoute(
                         builder: (context) => AddEditRewardScreen(reward: data),
                       ),
                     );
                     if (result == true) {
                       _fetchData(); // Refresh the list if a reward was edited
                     }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.qr_code, color: Colors.blue),
                  onPressed: () => _showQrDialog(data),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteReward(data['id']),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRedeemedList() {
    if (redeemed.isEmpty) {
      return const Center(child: Text('لا توجد جوائز تم استبدالها.'));
    }
    return ListView.builder(
      itemCount: redeemed.length,
      itemBuilder: (context, i) {
        final data = redeemed[i];
        final redeemedAt = data['redeemedAt'];
        String formattedDate = 'تاريخ غير معروف';
        if (redeemedAt is String) {
          try {
            final parsedDate = DateTime.parse(redeemedAt);
            formattedDate = DateFormat('yyyy/MM/dd').format(parsedDate);
          } catch (e) {
            // Handle parsing error if needed
          }
        } else if (redeemedAt is Timestamp) { // Keep old logic for safety
          formattedDate =
              DateFormat('yyyy/MM/dd').format(redeemedAt.toDate());
        }

        return ListTile(
          leading: const Icon(Icons.check_circle, color: Colors.green),
          title: Text('جائزة: ${data['rewardTitle'] ?? 'غير معروف'}'),
          subtitle: Text('زبون: ${data['customerName'] ?? 'غير معروف'}'),
          trailing: Text(formattedDate),
        );
      },
    );
  }
}

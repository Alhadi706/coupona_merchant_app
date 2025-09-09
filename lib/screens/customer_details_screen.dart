import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:coupona_merchant/gen_l10n/app_localizations.dart';

class CustomerDetailsScreen extends StatelessWidget {
  final String customerId;
  const CustomerDetailsScreen({Key? key, required this.customerId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(loc?.customerDetailsTitle ?? 'Customer Details'),
        backgroundColor: Colors.deepPurple,
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('customers').doc(customerId).get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final data = snapshot.data!.data() as Map<String, dynamic>?;
          if (data == null) {
            return Center(child: Text(loc?.customerNotFound ?? 'Not found'));
          }
          final name = data['name'] ?? '';
          final points = data['points'] ?? 0;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              ListTile(
                leading: const Icon(Icons.person, color: Colors.deepPurple),
                title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                subtitle: Text(loc?.totalPoints(points) ?? 'Total points: $points'),
              ),
              const SizedBox(height: 16),
              Text(loc?.purchaseHistory ?? 'Purchases', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              _CustomerOrders(customerId: customerId),
              const SizedBox(height: 24),
              Text(loc?.redeemedRewards ?? 'Rewards', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              _CustomerRewards(customerId: customerId),
              const SizedBox(height: 24),
              Text(loc?.receiptsHistory ?? 'Receipts', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              _CustomerReceipts(customerId: customerId),
              const SizedBox(height: 24),
              Text(loc?.customerOffers ?? 'Offers', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              _CustomerOffers(customerId: customerId),
            ],
          );
        },
      ),
    );
  }
}

class _CustomerOrders extends StatelessWidget {
  final String customerId;
  const _CustomerOrders({required this.customerId});

  @override
  Widget build(BuildContext context) {
  final loc = AppLocalizations.of(context);
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('orders')
          .where('customerId', isEqualTo: customerId)
          .orderBy('created_at', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final orders = snapshot.data!.docs;
        if (orders.isEmpty) {
          return Text(loc?.noPurchasesYet ?? 'No purchases');
        }
        return Column(
          children: orders.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return ListTile(
              leading: const Icon(Icons.shopping_cart, color: Colors.green),
              title: Text(AppLocalizations.of(context)?.orderNumber(doc.id) ?? 'Order #: ${doc.id}'),
              subtitle: Text(
                '${(loc?.dateLabel((data['created_at'] as Timestamp?)?.toDate().toString().substring(0, 16) ?? '-') ?? '')}\n${(loc?.amountLabel((data['total'] ?? '-').toString()) ?? '')}',
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

class _CustomerRewards extends StatelessWidget {
  final String customerId;
  const _CustomerRewards({required this.customerId});

  @override
  Widget build(BuildContext context) {
  final loc = AppLocalizations.of(context);
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('redeemed_rewards')
          .where('customerId', isEqualTo: customerId)
          .orderBy('redeemedAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final rewards = snapshot.data!.docs;
        if (rewards.isEmpty) {
          return Text(loc?.noRewardsYet ?? 'No rewards');
        }
        return Column(
          children: rewards.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return ListTile(
              leading: const Icon(Icons.card_giftcard, color: Colors.purple),
              title: Text(data['rewardName'] ?? ''),
              subtitle: Text(loc?.dateLabel((data['redeemedAt'] as Timestamp?)?.toDate().toString().substring(0, 16) ?? '-') ?? ''),
            );
          }).toList(),
        );
      },
    );
  }
}

class _CustomerReceipts extends StatelessWidget {
  final String customerId;
  const _CustomerReceipts({required this.customerId});

  @override
  Widget build(BuildContext context) {
  final loc = AppLocalizations.of(context);
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('receipts')
          .where('customerId', isEqualTo: customerId)
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final receipts = snapshot.data!.docs;
        if (receipts.isEmpty) {
          return Text(loc?.noReceiptsYet ?? 'No receipts');
        }
        return Column(
          children: receipts.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return ListTile(
              leading: const Icon(Icons.receipt_long, color: Colors.orange),
              title: Text(loc?.invoiceNumber(doc.id) ?? 'Invoice #: ${doc.id}'),
              subtitle: Text(
                '${(loc?.dateLabel((data['createdAt'] as Timestamp?)?.toDate().toString().substring(0, 16) ?? '-') ?? '')}\n${(loc?.amountLabel((data['total'] ?? '-').toString()) ?? '')}',
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

class _CustomerOffers extends StatelessWidget {
  final String customerId;
  const _CustomerOffers({required this.customerId});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _fetchOffers(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Text('حدث خطأ أثناء جلب العروض: ${snapshot.error}');
        }
        final offers = snapshot.data ?? [];
        if (offers.isEmpty) {
          return Text(loc?.noOffersForCustomer ?? 'No offers');
        }
        return Column(
          children: offers.map((offer) {
            return Card(
              child: ListTile(
                leading: offer['image_url'] != null
                    ? Image.network(offer['image_url'], width: 40, height: 40, fit: BoxFit.cover)
                    : const Icon(Icons.local_offer, color: Colors.blue),
                title: Text(offer['title'] ?? (loc?.noTitle ?? 'No title')),
                subtitle: Text(offer['description'] ?? ''),
                trailing: ElevatedButton.icon(
                  icon: const Icon(Icons.thumb_up),
                  label: Text(loc?.supportOffer ?? 'Support'),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(loc?.offerSupported ?? 'Supported')),
                    );
                    // هنا يمكنك إضافة منطق دعم العرض في Supabase إذا رغبت
                  },
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Future<List<Map<String, dynamic>>> _fetchOffers() async {
    final supabase = Supabase.instance.client;
    final response = await supabase
        .from('offers')
        .select()
        .eq('user_id', customerId);
    return List<Map<String, dynamic>>.from(response);
  }
}

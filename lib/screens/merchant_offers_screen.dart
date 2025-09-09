import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:coupona_merchant/screens/add_offer_screen.dart';
import 'package:hive/hive.dart';
import 'package:latlong2/latlong.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:coupona_merchant/widgets/home_button.dart';
import 'package:coupona_merchant/l10n/app_localizations.dart';

import '../widgets/address_from_latlng.dart';

class MerchantOffersScreen extends StatefulWidget {
  const MerchantOffersScreen({super.key});

  @override
  State<MerchantOffersScreen> createState() => _MerchantOffersScreenState();
}

class _MerchantOffersScreenState extends State<MerchantOffersScreen> {
  AppLocalizations? get loc => AppLocalizations.of(context);
  String? _merchantId;
  String? _supabaseMerchantId;
  String _searchQuery = '';
  bool _migrating = false;
  int _migratedCount = 0;

  @override
  void initState() {
    super.initState();
    // استخدم FirebaseAuth للحصول على معرف المستخدم الصحيح
    final user = FirebaseAuth.instance.currentUser;
  _merchantId = user?.uid; // Firebase UID
  _supabaseMerchantId = Supabase.instance.client.auth.currentUser?.id; // Supabase UUID
  // محاولة ترحيل معرفات قديمة (Firebase) إلى Supabase في الجدول
  _migrateMerchantIds();
    // بعد الإطار الأول شغّل الترحيل التلقائي (لن يعمل كثيراً بسبب التخزين)
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeMigrateOffers());
  }

  Future<void> _maybeMigrateOffers({bool force = false}) async {
    if (_merchantId == null) return;
    try {
      final box = await Hive.openBox('offers_migration_meta');
      final key = 'last_migration_${_merchantId!}';
      final lastIso = box.get(key) as String?;
      if (!force && lastIso != null) {
        final last = DateTime.tryParse(lastIso);
        if (last != null && DateTime.now().difference(last).inHours < 6) {
          return; // لا نكرر الترحيل خلال 6 ساعات إلا عند force
        }
      }
      setState(() {
        _migrating = true;
        _migratedCount = 0;
      });
      final supa = Supabase.instance.client;
      // اجلب المعرفات الحالية في Supabase
      final existing = await supa.from('offers').select('id').eq('merchant_id', _merchantId!);
      final existingIds = <String>{};
      for (final row in existing) {
        final id = row['id'];
        if (id is String) existingIds.add(id);
      }
      // اجلب عروض Firestore
      final fsSnap = await FirebaseFirestore.instance
          .collection('offers')
          .where('merchantId', isEqualTo: _merchantId)
          .get();
      for (final doc in fsSnap.docs) {
        if (existingIds.contains(doc.id)) continue; // موجود بالفعل
        final d = doc.data();
        try {
          await supa.from('offers').upsert({
            'id': doc.id,
            'merchant_id': _merchantId,
            'title': d['title'],
            'description': d['description'],
            'imageUrl': d['imageUrl'],
            'startDate': d['startDate'] is Timestamp ? (d['startDate'] as Timestamp).toDate().toIso8601String() : d['startDate'],
            'endDate': d['endDate'] is Timestamp ? (d['endDate'] as Timestamp).toDate().toIso8601String() : d['endDate'],
            'originalPrice': d['originalPrice'],
            'discountPercentage': d['discountPercentage'],
            'type': d['type'],
            'location': d['location'],
            'isActive': d['isActive'] ?? true,
            'created_at': DateTime.now().toIso8601String(),
          }, onConflict: 'id');
          _migratedCount++;
        } catch (e) {
          // نتابع بقية العناصر
          debugPrint('فشل ترحيل عرض ${doc.id}: $e');
        }
      }
      await box.put(key, DateTime.now().toIso8601String());
      if (mounted && _migratedCount > 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(loc?.offersMigratedCount(_migratedCount) ?? 'Migrated $_migratedCount offers')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${loc?.autoMigrationFailed ?? 'Migration failed'}: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _migrating = false;
        });
      }
    }
  }

  Stream<List<Map<String, dynamic>>> _getOffersStream() {
    final supabase = Supabase.instance.client;
    final effectiveId = _supabaseMerchantId ?? _merchantId;
    if (effectiveId == null) {
      // أرجع stream فارغ إذا لم يكن هناك معرف تاجر
      return const Stream<List<Map<String, dynamic>>>.empty();
    }
    return supabase
        .from('offers')
        .stream(primaryKey: ['id'])
        .inFilter('merchant_id', [effectiveId, if (_merchantId != null) _merchantId!])
        .order('created_at', ascending: false)
        .map((offers) => List<Map<String, dynamic>>.from(offers));
  }

  Future<void> _migrateMerchantIds() async {
    if (_merchantId == null || _supabaseMerchantId == null) return;
    if (_merchantId!.length > 30) return; // يبدو أنه UUID بالفعل
    try {
      final supa = Supabase.instance.client;
  final oldId = _merchantId; // تثبيت القيمة لتفادي مشكلة الترويج للنوع
  if (oldId != null && oldId.isNotEmpty) {
    await supa
    .from('offers')
    .update({'merchant_id': _supabaseMerchantId})
    .match({'merchant_id': oldId});
  }
    } catch (e) {
      debugPrint('فشل ترحيل معرفات العروض: $e');
    }
  }

  Future<void> deleteOffer(String offerId) async {
    if (offerId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(content: Text(loc?.offerIdMissing ?? 'Offer ID missing!')),
      );
      return;
    }
    try {
      final supabase = Supabase.instance.client;
      await supabase.from('offers').delete().eq('id', offerId);
      final box = await Hive.openBox('offers_$_merchantId');
      await box.delete(offerId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(loc?.offerDeleted ?? 'Offer deleted')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${loc?.offerDeleteFailed ?? 'Delete failed'}: $e')),
        );
      }
    }
  }

  Future<void> toggleOfferStatus(String offerId, bool currentStatus) async {
    try {
      final supabase = Supabase.instance.client;
      await supabase.from('offers').update({'isActive': !currentStatus}).eq('id', offerId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(loc?.offerStatusChanged ?? 'Status changed')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${loc?.offerStatusChangeFailed ?? 'Status change failed'}: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_merchantId == null || _merchantId!.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    final loc = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(loc?.manageOffersTitle ?? 'Manage Offers'),
        leading: const HomeButton(),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            tooltip: loc?.addNewOffer ?? 'Add Offer',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddOfferScreen(merchantId: _merchantId!),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.sync),
            tooltip: loc?.migrateOldOffers ?? 'Migrate Old',
            onPressed: () => _maybeMigrateOffers(force: true),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                labelText: loc?.offers ?? 'Offers',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey.shade200,
              ),
            ),
          ),
          if (_migrating)
            const LinearProgressIndicator(minHeight: 3),
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _getOffersStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('${loc?.unexpectedError ?? 'Error'}: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text(loc?.noOffersYet ?? 'No offers'));
                }
                // تصفية النتائج هنا فقط
                final offers = _searchQuery.isEmpty
                    ? snapshot.data!
                    : snapshot.data!.where((offer) {
                        final title = offer['title']?.toString().toLowerCase() ?? '';
                        return title.contains(_searchQuery.toLowerCase());
                      }).toList();
                if (offers.isEmpty) {
                  return Center(child: Text(loc?.noMatchingResults ?? 'No matching results'));
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: offers.length,
                  itemBuilder: (context, index) {
                    final offer = offers[index];
                    return _OfferCard(
                      offer: offer,
                      onDelete: () => deleteOffer(offer['id']),
                      onToggleStatus: (status) =>
                          toggleOfferStatus(offer['id'], status),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _OfferCard extends StatelessWidget {
  final Map<String, dynamic> offer;
  final VoidCallback onDelete;
  final Function(bool) onToggleStatus;

  const _OfferCard({
    required this.offer,
    required this.onDelete,
    required this.onToggleStatus,
  });

  Future<Map<String, dynamic>?> _getMerchantDetails() async {
    final supabase = Supabase.instance.client;
    final response = await supabase
        .from('merchants')
        .select()
        .eq('id', offer['merchant_id'])
        .single();
    return response;
  }

  @override
  Widget build(BuildContext context) {
  final isActive = offer['is_active'] ?? offer['isActive'] ?? true;
  final type = offer['offer_type'] ?? offer['type'] ?? 'N/A';
  final endDateStr = offer['end_date'] ?? offer['endDate'];
    final loc = AppLocalizations.of(context);
    String displayEndDate = loc?.notSpecified ?? 'Not specified';
    if (endDateStr is String) {
      final date = DateTime.tryParse(endDateStr);
      if (date != null) {
        displayEndDate = '${date.day}-${date.month}-${date.year}';
      }
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: FutureBuilder<Map<String, dynamic>?>(
          future: _getMerchantDetails(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return _buildCardContent(context, null, isActive, type, displayEndDate);
            }
            final merchantData = snapshot.data;
            return _buildCardContent(context, merchantData, isActive, type, displayEndDate);
          },
        ),
      ),
    );
  }

  Widget _buildCardContent(BuildContext context, Map<String, dynamic>? merchantData, bool isActive, String type, String displayEndDate) {
    final loc = AppLocalizations.of(context);
    final storeName = merchantData?['store_name'] ?? (loc?.storeNameNotAvailable ?? 'Store name not available');
    final location = merchantData?['location'];

    // تفاصيل خاصة بالعرض نفسه
    final showPhoneNumber = offer['showPhoneNumber'] as bool? ?? false;
    final phoneNumber = offer['phoneNumber'] as String?;
    final deliveryAvailable = offer['deliveryAvailable'] as bool? ?? false;

    // معالجة الإحداثيات بشكل آمن
    double? latNum;
    double? lngNum;
    if (location is Map) {
      final latRaw = location['lat'];
      final lngRaw = location['lng'];
      if (latRaw is num) {
        latNum = latRaw.toDouble();
      } else if (latRaw is String) {
        latNum = double.tryParse(latRaw);
      }
      if (lngRaw is num) {
        lngNum = lngRaw.toDouble();
      } else if (lngRaw is String) {
        lngNum = double.tryParse(lngRaw);
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
        child: ((offer['image_url'] ?? offer['imageUrl']) != null && (offer['image_url'] ?? offer['imageUrl']).toString().isNotEmpty)
                  ? Image.network(
          (offer['image_url'] ?? offer['imageUrl']).toString(),
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.sell, size: 80, color: Colors.grey),
                    )
                  : Container(
                      width: 80,
                      height: 80,
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.sell, size: 50, color: Colors.grey),
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    offer['title'] ?? (loc?.noTitle ?? 'No title'),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    storeName,
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    offer['description'] ?? (loc?.noDescription ?? 'No description'),
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Chip(
              label: Text(type),
              backgroundColor: Colors.orange.shade100,
              padding: EdgeInsets.zero,
            ),
          ],
        ),
        const SizedBox(height: 12),
        const Divider(),
        // Merchant Details Section
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Column(
            children: [
              if (showPhoneNumber && phoneNumber != null && phoneNumber.isNotEmpty)
                _buildDetailRow(Icons.phone, phoneNumber),
              const SizedBox(height: 8),
              if (latNum != null && lngNum != null)
                AddressFromLatLng(
                  latitude: latNum,
                  longitude: lngNum,
                ),
              const SizedBox(height: 8),
              _buildDetailRow(
                Icons.delivery_dining,
                deliveryAvailable
                    ? (loc?.deliveryAvailable ?? 'Delivery available')
                    : (loc?.deliveryNotAvailable ?? 'Delivery not available'),
              ),
            ],
          ),
        ),
        const Divider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(loc?.offerEndsAt(displayEndDate) ?? 'Ends at: $displayEndDate', style: const TextStyle(color: Colors.red, fontSize: 12)),
            Row(
              children: [
                Text(loc?.active ?? 'Active', style: const TextStyle(fontSize: 14)),
                Switch(
                  value: isActive,
                  onChanged: (value) => onToggleStatus(isActive),
                  activeColor: Colors.deepPurple,
                ),
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddOfferScreen(
                          offer: offer,
                          offerId: offer['id'],
                          merchantId: offer['merchant_id'] ?? offer['merchantId'],
                        ),
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: onDelete,
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade800),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
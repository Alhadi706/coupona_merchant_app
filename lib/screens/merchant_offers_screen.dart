import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:coupona_merchant/screens/add_offer_screen.dart';
import 'package:hive/hive.dart';
import 'package:latlong2/latlong.dart';

import '../widgets/address_from_latlng.dart';

class MerchantOffersScreen extends StatefulWidget {
  const MerchantOffersScreen({super.key});

  @override
  State<MerchantOffersScreen> createState() => _MerchantOffersScreenState();
}

class _MerchantOffersScreenState extends State<MerchantOffersScreen> {
  final String _merchantId = FirebaseAuth.instance.currentUser?.uid ?? '';
  Stream<List<Map<String, dynamic>>>? _offersStream;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    if (_merchantId.isNotEmpty) {
      _offersStream = _getOffersStream();
    }
  }

  Stream<List<Map<String, dynamic>>> _getOffersStream() {
    Query query = FirebaseFirestore.instance
        .collection('offers')
        .where('merchantId', isEqualTo: _merchantId)
        .orderBy('createdAt', descending: true);

    return query.snapshots().map((snapshot) {
      final offers = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();

      if (_searchQuery.isNotEmpty) {
        return offers.where((offer) {
          final title = offer['title']?.toString().toLowerCase() ?? '';
          return title.contains(_searchQuery.toLowerCase());
        }).toList();
      }
      return offers;
    });
  }

  Future<void> deleteOffer(String offerId) async {
    if (offerId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('رقم العرض غير موجود!')),
      );
      return;
    }
    try {
      await FirebaseFirestore.instance.collection('offers').doc(offerId).delete();
      final box = await Hive.openBox('offers_$_merchantId');
      await box.delete(offerId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم حذف العرض بنجاح.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل حذف العرض: $e')),
        );
      }
    }
  }

  Future<void> toggleOfferStatus(String offerId, bool currentStatus) async {
    try {
      await FirebaseFirestore.instance
          .collection('offers')
          .doc(offerId)
          .update({'isActive': !currentStatus});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم تغيير حالة العرض بنجاح.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل تغيير حالة العرض: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة العروض'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            tooltip: 'إضافة عرض جديد',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddOfferScreen(merchantId: _merchantId),
                ),
              );
            },
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
                  _offersStream = _getOffersStream();
                });
              },
              decoration: InputDecoration(
                labelText: 'ابحث عن عرض بالاسم...',
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
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _offersStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('حدث خطأ: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('لا توجد عروض حالياً.'));
                }
                final offers = snapshot.data!;
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

  Future<DocumentSnapshot> _getMerchantDetails() {
    return FirebaseFirestore.instance
        .collection('merchants')
        .doc(offer['merchantId'])
        .get();
  }

  @override
  Widget build(BuildContext context) {
    final isActive = offer['isActive'] ?? true;
    final type = offer['type'] ?? 'N/A';
    final endDateStr = offer['endDate'];
    String displayEndDate = 'غير محدد';
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
        child: FutureBuilder<DocumentSnapshot>(
          future: _getMerchantDetails(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              // Show a placeholder while loading merchant data
              return _buildCardContent(context, null, isActive, type, displayEndDate);
            }
            final merchantData = snapshot.data!.data() as Map<String, dynamic>?;
            return _buildCardContent(context, merchantData, isActive, type, displayEndDate);
          },
        ),
      ),
    );
  }

  Widget _buildCardContent(BuildContext context, Map<String, dynamic>? merchantData, bool isActive, String type, String displayEndDate) {
    final storeName = merchantData?['store_name'] ?? 'اسم المحل غير متوفر';
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
              child: Image.network(
                offer['imageUrl'] ?? 'https://placehold.co/100x100?text=Offer',
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.sell, size: 80, color: Colors.grey),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    offer['title'] ?? 'بلا عنوان',
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
                    offer['description'] ?? 'لا يوجد وصف',
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
                deliveryAvailable ? 'خدمة التوصيل متوفرة' : 'خدمة التوصيل غير متوفرة',
              ),
            ],
          ),
        ),
        const Divider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('ينتهي في: $displayEndDate', style: const TextStyle(color: Colors.red, fontSize: 12)),
            Row(
              children: [
                const Text('مفعل', style: TextStyle(fontSize: 14)),
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
                          merchantId: offer['merchantId'],
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
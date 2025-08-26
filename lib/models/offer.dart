import 'package:cloud_firestore/cloud_firestore.dart';

class OfferModel {
  final String id;
  final String merchantId;
  final String? title;
  final String? description;
  final String? imageUrl;
  final DateTime? startDate;
  final DateTime? endDate;
  final num? originalPrice;
  final int? discountPercentage;
  final String? offerType;
  final Map<String, dynamic>? location;
  final bool isActive;

  OfferModel({
    required this.id,
    required this.merchantId,
    this.title,
    this.description,
    this.imageUrl,
    this.startDate,
    this.endDate,
    this.originalPrice,
    this.discountPercentage,
    this.offerType,
    this.location,
    this.isActive = true,
  });

  factory OfferModel.fromSupabase(Map<String, dynamic> map) {
    DateTime? parseDt(dynamic v) {
      if (v == null) return null;
      if (v is DateTime) return v;
      if (v is String) return DateTime.tryParse(v);
      return null;
    }
    return OfferModel(
      id: map['id']?.toString() ?? '',
      merchantId: map['merchant_id']?.toString() ?? '',
      title: map['title'] as String?,
      description: map['description'] as String?,
      imageUrl: map['image_url'] as String? ?? map['imageUrl'] as String?,
      startDate: parseDt(map['start_date'] ?? map['startDate']),
      endDate: parseDt(map['end_date'] ?? map['endDate']),
      originalPrice: map['original_price'] ?? map['originalPrice'],
      discountPercentage: (map['discount_percentage'] ?? map['discountPercentage']) as int?,
      offerType: map['offer_type'] as String? ?? map['type'] as String?,
      location: (map['location'] is Map<String, dynamic>) ? (map['location'] as Map<String, dynamic>) : null,
      isActive: (map['is_active'] ?? map['isActive'] ?? true) as bool,
    );
  }

  OfferModel copyWith({
    String? id,
    String? merchantId,
    String? title,
    String? description,
    String? imageUrl,
    DateTime? startDate,
    DateTime? endDate,
    num? originalPrice,
    int? discountPercentage,
    String? offerType,
    Map<String, dynamic>? location,
    bool? isActive,
  }) => OfferModel(
        id: id ?? this.id,
        merchantId: merchantId ?? this.merchantId,
        title: title ?? this.title,
        description: description ?? this.description,
        imageUrl: imageUrl ?? this.imageUrl,
        startDate: startDate ?? this.startDate,
        endDate: endDate ?? this.endDate,
        originalPrice: originalPrice ?? this.originalPrice,
        discountPercentage: discountPercentage ?? this.discountPercentage,
        offerType: offerType ?? this.offerType,
        location: location ?? this.location,
        isActive: isActive ?? this.isActive,
      );

  Map<String, dynamic> toSupabaseInsert() => {
        'id': id,
        'merchant_id': merchantId,
        'title': title,
        'description': description,
        'image_url': imageUrl,
        'start_date': startDate?.toIso8601String(),
        'end_date': endDate?.toIso8601String(),
        'original_price': originalPrice,
        'discount_percentage': discountPercentage,
        'offer_type': offerType,
        'location': location,
        'is_active': isActive,
      }..removeWhere((k, v) => v == null);

  Map<String, dynamic> toFirestore() => {
        'title': title,
        'description': description,
        'imageUrl': imageUrl,
        'startDate': startDate != null ? Timestamp.fromDate(startDate!) : null,
        'endDate': endDate != null ? Timestamp.fromDate(endDate!) : null,
        'originalPrice': originalPrice,
        'discountPercentage': discountPercentage,
        'type': offerType,
        'location': location,
        'isActive': isActive,
        'merchantId': merchantId,
      }..removeWhere((k, v) => v == null);
}

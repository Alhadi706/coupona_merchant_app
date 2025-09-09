import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coupona_merchant/services/auth_manager.dart';
import 'package:flutter/material.dart';
import 'package:coupona_merchant/gen_l10n/app_localizations.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:latlong2/latlong.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/offer.dart';

import 'pick_location_screen.dart';

class AddOfferScreen extends StatefulWidget {
  final String merchantId; // تغيير إلى غير nullable
  final Map<String, dynamic>? offer;
  final String? offerId;
  const AddOfferScreen({Key? key, required this.merchantId, this.offer, this.offerId}) : super(key: key);

  @override
  State<AddOfferScreen> createState() => _AddOfferScreenState();
}

class _AddOfferScreenState extends State<AddOfferScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;
  String? _merchantId;
  String? _supabaseMerchantId; // المعرف الحقيقي المستخدم في جداول Supabase

  // Controllers and variables for form fields
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _originalPriceController = TextEditingController();
  final _discountPercentageController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  File? _imageFile;
  String? _existingImageUrl;
  LatLng? pickedLocation;

  // Internal canonical offer types mapped to localized labels at build time
  final List<String> _offerTypeCodes = [
    'discount',
    'gift',
    'coupon',
    'limited',
    'other'
  ];
  String? selectedOfferType;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    setState(() {
      _loading = true;
    });

    // Ensure user is authenticated
    await AuthManager.ensureAuth();
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) {
        final t = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(t.mustLoginFirst),
          backgroundColor: Colors.red,
        ));
        Navigator.of(context).pop();
      }
      return;
    }
    _merchantId = user.uid;
  _supabaseMerchantId = Supabase.instance.client.auth.currentUser?.id;

    // If editing an offer, populate the fields
    if (widget.offer != null) {
      _titleController.text = widget.offer!['title'] ?? '';
      _descriptionController.text = widget.offer!['description'] ?? '';
      _originalPriceController.text =
          widget.offer!['originalPrice']?.toString() ?? '';
      _discountPercentageController.text =
          widget.offer!['discountPercentage']?.toString() ?? '';
      _startDate = (widget.offer!['startDate'] as Timestamp?)?.toDate();
      _endDate = (widget.offer!['endDate'] as Timestamp?)?.toDate();
      _existingImageUrl = widget.offer!['imageUrl'];

      if (widget.offer!['location'] != null && widget.offer!['location'] is Map) {
        final loc = widget.offer!['location'];
        pickedLocation = LatLng(loc['lat'] ?? 0.0, loc['lng'] ?? 0.0);
      }
      if (widget.offer!['type'] != null) {
        selectedOfferType = _mapLegacyOfferType(widget.offer!['type'].toString());
      }
    }

    setState(() {
      _loading = false;
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _originalPriceController.dispose();
    _discountPercentageController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: source, imageQuality: 85, maxWidth: 1280);
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
          // عند اختيار صورة جديدة نحذف رابط القديمة حتى لا نرفع حقل قديم خطأً
          if (_existingImageUrl != null) _existingImageUrl = null;
        });
      }
    } catch (e) {
      if (mounted) {
  final t = AppLocalizations.of(context)!;
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t.imagePickFailed(e.toString()))));
      }
    }
  }

  Future<void> _pickDate(BuildContext context, bool isStartDate) async {
    final initialDate = isStartDate
        ? (_startDate ?? DateTime.now())
        : (_endDate ?? _startDate ?? DateTime.now());
    final newDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (newDate != null) {
      setState(() {
        if (isStartDate) {
          _startDate = newDate;
        } else {
          _endDate = newDate;
        }
      });
    }
  }

  Future<String?> _uploadImage() async {
    if (_imageFile == null) return _existingImageUrl;

    if (_merchantId == null) {
      throw Exception('User not authenticated');
    }
    final fileName =
        'offers/$_merchantId-${DateTime.now().millisecondsSinceEpoch}.jpg';
    final ref = FirebaseStorage.instance.ref().child(fileName);
    final uploadTask = await ref.putFile(_imageFile!);
    return await uploadTask.ref.getDownloadURL();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_startDate == null || _endDate == null) {
      final t = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(t.selectStartEndDates),
        backgroundColor: Colors.red,
      ));
      return;
    }
  // الصورة أصبحت اختيارية (مسموح عدم رفع صورة)
    if (pickedLocation == null) {
      final t = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t.offerLocationRequired), backgroundColor: Colors.red));
      return;
    }
    if (selectedOfferType == null || selectedOfferType!.isEmpty) {
      final t = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t.offerTypeRequired), backgroundColor: Colors.red));
      setState(() => _loading = false);
      return;
    }

    setState(() => _loading = true);

    try {
      final imageUrl = await _uploadImage();
      final offerModel = OfferModel(
        id: widget.offerId ?? '',
        merchantId: _supabaseMerchantId ?? _merchantId!,
        title: _titleController.text,
        description: _descriptionController.text,
        originalPrice: double.parse(_originalPriceController.text),
        discountPercentage: int.parse(_discountPercentageController.text),
        startDate: _startDate!,
        endDate: _endDate!,
        imageUrl: imageUrl,
        offerType: selectedOfferType,
        location: {'lat': pickedLocation!.latitude, 'lng': pickedLocation!.longitude},
        isActive: true,
      );

      final collection = FirebaseFirestore.instance.collection('offers');
      String docId = widget.offerId ?? '';
      if (widget.offerId != null) {
        await collection.doc(docId).update(offerModel.toFirestore());
      } else {
        final added = await collection.add(offerModel.toFirestore());
        docId = added.id;
      }

      // Supabase upsert snake_case فقط
      try {
        final supa = Supabase.instance.client;
        await supa.from('offers').upsert({
          ...offerModel.copyWith(id: docId).toSupabaseInsert(),
          'created_at': DateTime.now().toIso8601String(),
        }, onConflict: 'id');
        // ترحيل أي صف قديم أنشئ سابقاً بمعرف Firebase قصير إلى معرف Supabase
        if (_supabaseMerchantId != null) {
          final oldId = _merchantId; // snapshot
          if (oldId != null && oldId.length < 30) {
            await supa
                .from('offers')
                .update({'merchant_id': _supabaseMerchantId})
                .match({'merchant_id': oldId});
          }
        }
      } catch (e) {
        if (mounted) {
          final t = AppLocalizations.of(context)!;
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t.savedWithSupabaseWarning(e.toString()))));
        }
      }

  if (mounted) {
    final t = AppLocalizations.of(context)!;
    final successMsg = widget.offerId == null ? t.offerAddedSynced : t.offerUpdatedSynced;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(successMsg), backgroundColor: Colors.green));
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    print('Building AddOfferScreen with back button');
  final t = AppLocalizations.of(context)!;
  return Scaffold(
      appBar: AppBar(
    title: Text(t.addOfferTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            print('Back button pressed');
            Navigator.pop(context);
          },
        ),
        actions: [
          if (!_loading)
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _submit,
            ),
          if (_loading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                  width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white)),
            )
        ],
      ),
      body: _loading && _merchantId == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image Picker
                    Center(
                      child: Column(
                        children: [
                          Container(
                            height: 160,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.grey.shade50,
                            ),
                            child: _imageFile != null
                                ? Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      Image.file(_imageFile!, fit: BoxFit.cover),
                                      Positioned(
                                        top: 4,
                                        right: 4,
                                        child: CircleAvatar(
                                          radius: 16,
                                          backgroundColor: Colors.black54,
                                          child: IconButton(
                                            padding: EdgeInsets.zero,
                                            icon: const Icon(Icons.close, size: 16, color: Colors.white),
                                            onPressed: () {
                                              setState(() { _imageFile = null; });
                                            },
                                          ),
                                        ),
                                      )
                                    ],
                                  )
                                : (_existingImageUrl != null
                                    ? Stack(
                                        fit: StackFit.expand,
                                        children: [
                                          Image.network(_existingImageUrl!, fit: BoxFit.cover),
                                          Positioned(
                                            top: 4,
                                            right: 4,
                                            child: CircleAvatar(
                                              radius: 16,
                                              backgroundColor: Colors.black54,
                                              child: IconButton(
                                                padding: EdgeInsets.zero,
                                                icon: const Icon(Icons.close, size: 16, color: Colors.white),
                                                onPressed: () {
                                                  setState(() { _existingImageUrl = null; });
                                                },
                                              ),
                                            ),
                                          )
                                        ],
                                      )
                  : Center(child: Text(t.offerImagePlaceholderOptional))),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            children: [
                              OutlinedButton.icon(
                icon: const Icon(Icons.photo),
                label: Text(t.pickFromGallery),
                                onPressed: () => _pickImage(ImageSource.gallery),
                              ),
                              OutlinedButton.icon(
                icon: const Icon(Icons.photo_camera),
                label: Text(t.captureWithCamera),
                                onPressed: () => _pickImage(ImageSource.camera),
                              ),
                            ],
                          ),
              const SizedBox(height: 4),
              Text(t.imageOptionalNote, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Title
                    TextFormField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        labelText: t.offerTitleLabel,
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.title),
                      ),
                      validator: (value) =>
                          value!.isEmpty ? t.requiredField : null,
                    ),
                    // overlay labelText via InputDecoration in build using copyWith not trivial here; simplest: use hint
                    // For simplicity leave label replaced by localized hint style
                    const SizedBox(height: 16),

                    // Description
                    TextFormField(
                      controller: _descriptionController,
                      decoration: InputDecoration(
                        labelText: t.offerDescriptionLabel,
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.description),
                      ),
                      maxLines: 3,
                      validator: (value) =>
                          value!.isEmpty ? t.requiredField : null,
                    ),
                    const SizedBox(height: 16),

                    // Prices
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _originalPriceController,
                            decoration: InputDecoration(
                              labelText: t.originalPriceLabel,
                              border: const OutlineInputBorder(),
                              prefixIcon: const Icon(Icons.attach_money),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) =>
                                value!.isEmpty ? t.requiredField : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _discountPercentageController,
                            decoration: InputDecoration(
                              labelText: t.discountPercentageLabel,
                              border: const OutlineInputBorder(),
                              prefixIcon: const Icon(Icons.percent),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value!.isEmpty) return t.requiredField;
                              final p = int.tryParse(value);
                              if (p == null || p < 1 || p > 99) {
                                return t.discountPercentageInvalid;
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Dates
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
            Text(t.startDateLabel, style: const TextStyle(fontWeight: FontWeight.bold)),
                            TextButton.icon(
                              icon: const Icon(Icons.calendar_today),
                              label: Text(_startDate == null
              ? t.chooseGeneric
                                  : DateFormat('yyyy/MM/dd')
                                      .format(_startDate!)),
                              onPressed: () => _pickDate(context, true),
                            ),
                          ],
                        ),
                        Column(
                          children: [
            Text(t.endDateLabel, style: const TextStyle(fontWeight: FontWeight.bold)),
                            TextButton.icon(
                              icon: const Icon(Icons.event_busy),
                              label: Text(_endDate == null
              ? t.chooseGeneric
                                  : DateFormat('yyyy/MM/dd')
                                      .format(_endDate!)),
                              onPressed: () => _pickDate(context, false),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextButton.icon(
                      icon: const Icon(Icons.location_on, color: Colors.deepPurple),
                      label: Text(pickedLocation == null ? t.pickOfferLocation : t.offerLocationPicked),
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PickLocationScreen(initialLocation: pickedLocation),
                          ),
                        );
                        if (result != null && result is LatLng) {
                          setState(() {
                            pickedLocation = result;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedOfferType,
                      items: _offerTypeCodes.map((code) {
                        final label = _localizedOfferType(code, t);
                        return DropdownMenuItem(value: code, child: Text(label));
                      }).toList(),
                      onChanged: (val) {
                        setState(() {
                          selectedOfferType = val;
                        });
                      },
                      decoration: InputDecoration(
                        labelText: t.offerTypeLabel,
                        prefixIcon: const Icon(Icons.category),
                        border: const OutlineInputBorder(),
                      ),
                      validator: (value) => value == null || value.isEmpty ? t.offerTypeRequired : null,
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  String _localizedOfferType(String code, AppLocalizations t) {
    switch (code) {
      case 'discount':
        return t.offerTypeDiscount;
      case 'gift':
        return t.offerTypeGift;
      case 'coupon':
        return t.offerTypeCoupon;
      case 'limited':
        return t.offerTypeLimitedTime;
      case 'other':
      default:
        return t.offerTypeOther;
    }
  }

  String _mapLegacyOfferType(String legacy) {
    switch (legacy) {
      case 'خصم مباشر':
        return 'discount';
      case 'هدية مع الشراء':
        return 'gift';
      case 'كوبون':
        return 'coupon';
      case 'عرض لفترة محدودة':
        return 'limited';
      case 'آخر...':
        return 'other';
      default:
        // Already a code or unknown
        return legacy;
    }
  }
}
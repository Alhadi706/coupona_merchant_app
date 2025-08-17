import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coupona_merchant/services/auth_manager.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:latlong2/latlong.dart';

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

  final List<String> offerTypes = [
    'خصم مباشر',
    'هدية مع الشراء',
    'كوبون',
    'عرض لفترة محدودة',
    'آخر...'
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('يجب تسجيل الدخول أولاً.'),
              backgroundColor: Colors.red),
        );
        Navigator.of(context).pop();
      }
      return;
    }
    _merchantId = user.uid;

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
        selectedOfferType = widget.offer!['type'];
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

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('الرجاء تحديد تاريخ البدء والانتهاء'),
            backgroundColor: Colors.red),
      );
      return;
    }
    if (_imageFile == null && _existingImageUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('الرجاء اختيار صورة للعرض'),
            backgroundColor: Colors.red),
      );
      return;
    }
    if (pickedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى اختيار موقع العرض على الخريطة'), backgroundColor: Colors.red),
      );
      return;
    }
    if (selectedOfferType == null || selectedOfferType!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى اختيار نوع العرض'), backgroundColor: Colors.red),
      );
      setState(() => _loading = false);
      return;
    }

    setState(() => _loading = true);

    try {
      final imageUrl = await _uploadImage();
      final offerData = {
        'title': _titleController.text,
        'description': _descriptionController.text,
        'originalPrice': double.parse(_originalPriceController.text),
        'discountPercentage': int.parse(_discountPercentageController.text),
        'startDate': Timestamp.fromDate(_startDate!),
        'endDate': Timestamp.fromDate(_endDate!),
        'imageUrl': imageUrl,
        'merchantId': _merchantId,
        'created_at': FieldValue.serverTimestamp(),
        'location': {'lat': pickedLocation!.latitude, 'lng': pickedLocation!.longitude},
        'type': selectedOfferType,
      };

      final collection = FirebaseFirestore.instance.collection('offers');
      if (widget.offerId != null) {
        await collection.doc(widget.offerId).update(offerData);
      } else {
        await collection.add(offerData);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(widget.offerId == null
                  ? 'تم إضافة العرض بنجاح'
                  : 'تم تحديث العرض بنجاح'),
              backgroundColor: Colors.green),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('حدث خطأ: $e'), backgroundColor: Colors.red),
        );
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('إضافة عرض جديد'),
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
                            height: 150,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: _imageFile != null
                                ? Image.file(_imageFile!, fit: BoxFit.cover)
                                : (_existingImageUrl != null
                                    ? Image.network(_existingImageUrl!,
                                        fit: BoxFit.cover)
                                    : const Center(
                                        child: Text('لم يتم اختيار صورة'))),
                          ),
                          TextButton.icon(
                            icon: const Icon(Icons.image),
                            label: const Text('اختيار صورة للعرض'),
                            onPressed: _pickImage,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Title
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'عنوان العرض',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.title),
                      ),
                      validator: (value) =>
                          value!.isEmpty ? 'هذا الحقل مطلوب' : null,
                    ),
                    const SizedBox(height: 16),

                    // Description
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'وصف العرض',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.description),
                      ),
                      maxLines: 3,
                      validator: (value) =>
                          value!.isEmpty ? 'هذا الحقل مطلوب' : null,
                    ),
                    const SizedBox(height: 16),

                    // Prices
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _originalPriceController,
                            decoration: const InputDecoration(
                              labelText: 'السعر الأصلي',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.attach_money),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) =>
                                value!.isEmpty ? 'هذا الحقل مطلوب' : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _discountPercentageController,
                            decoration: const InputDecoration(
                              labelText: 'نسبة الخصم (%)',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.percent),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value!.isEmpty) return 'هذا الحقل مطلوب';
                              final p = int.tryParse(value);
                              if (p == null || p < 1 || p > 99) {
                                return 'ادخل نسبة بين 1-99';
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
                            const Text('تاريخ البدء',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            TextButton.icon(
                              icon: const Icon(Icons.calendar_today),
                              label: Text(_startDate == null
                                  ? 'اختيار'
                                  : DateFormat('yyyy/MM/dd')
                                      .format(_startDate!)),
                              onPressed: () => _pickDate(context, true),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            const Text('تاريخ الانتهاء',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            TextButton.icon(
                              icon: const Icon(Icons.event_busy),
                              label: Text(_endDate == null
                                  ? 'اختيار'
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
                      label: Text(pickedLocation == null ? 'حدد موقع العرض على الخريطة' : 'تم اختيار الموقع'),
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
                      items: offerTypes
                          .map((type) => DropdownMenuItem(
                                value: type,
                                child: Text(type),
                              ))
                          .toList(),
                      onChanged: (val) {
                        setState(() {
                          selectedOfferType = val;
                        });
                      },
                      decoration: const InputDecoration(
                        labelText: 'نوع العرض',
                        prefixIcon: Icon(Icons.category),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => value == null || value.isEmpty ? 'يرجى اختيار نوع العرض' : null,
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
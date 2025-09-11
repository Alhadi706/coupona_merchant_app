import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:coupona_merchant/widgets/home_button.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:hive/hive.dart';
import 'package:coupona_merchant/gen_l10n/app_localizations.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _loading = true;
  Map<String, dynamic>? _data;
  File? _logoFile;
  String? _fetchError;

  final List<String> activityTypes = [
    // These will later be mapped/translated via localization if needed.
    'متجر ملابس',
    'مطعم',
    'مقهى',
    'سوبرماركت',
    'إلكترونيات',
    'مكتبة',
    'صيدلية',
    'خدمات أخرى',
  ];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      _loading = true;
      _fetchError = null;
    });
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      setState(() {
        _data = null;
        _loading = false;
        _fetchError = AppLocalizations.of(context)?.settingsUserNotLoggedIn;
      });
      return;
    }

    try {
      final merchantDoc = await FirebaseFirestore.instance.collection('merchants').doc(user.uid).get();

      if (merchantDoc.exists) {
        setState(() {
          _data = merchantDoc.data();
          _data!['id'] = merchantDoc.id;
          _loading = false;
        });
      } else {
        final newData = {
          'id': user.uid,
            'email': user.email ?? '',
            'store_name': '',
            'activity_type': null,
            'phone': '',
            'location': '',
            'whatsapp': '',
            'facebook': '',
            'instagram': '',
            'description': '',
            'logo_url': null,
            'created_at': Timestamp.now(),
        };
        await FirebaseFirestore.instance.collection('merchants').doc(user.uid).set(newData);
        setState(() {
          _data = newData;
          _loading = false;
        });
        if (mounted) {
          final loc = AppLocalizations.of(context);
          if (loc != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(loc.profileCreatedPrompt)),
            );
          }
        }
      }
    } catch (e, stack) {
      final loc = AppLocalizations.of(context);
      final errorMessage = loc?.firestoreFetchFailed ?? 'Error';
      setState(() {
        _data = null;
        _fetchError = '$errorMessage\n\n$e';
        _loading = false;
      });
    }
  }

  Future<void> _pickLogo() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _logoFile = File(picked.path));
      await _uploadLogo();
    }
  }

  Future<void> _uploadLogo() async {
    if (_logoFile == null) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final fileName = 'merchant_logos/${user.uid}_${DateTime.now().millisecondsSinceEpoch}.png';
    final storageRef = FirebaseStorage.instance.ref().child(fileName);

    try {
      final uploadTask = await storageRef.putFile(_logoFile!);
      final url = await uploadTask.ref.getDownloadURL();
      setState(() => _data!['logo_url'] = url);
      await _saveSettings(showMsg: false);
    } catch (e) {
      // Could add localized error snackbar if desired
    }
  }

  Future<void> _saveSettings({bool showMsg = true}) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && _data != null) {
      try {
        final dataToSave = Map<String, dynamic>.from(_data!);
        dataToSave.remove('id');

        await FirebaseFirestore.instance.collection('merchants').doc(user.uid).set(dataToSave, SetOptions(merge: true));

        if (dataToSave['store_name'] != null && (dataToSave['store_name'] as String).isNotEmpty) {
          await FirebaseFirestore.instance.collection('users').doc(user.uid).set({'store_name': dataToSave['store_name']}, SetOptions(merge: true));
          var settingsBox = await Hive.openBox('settingsBox');
          await settingsBox.put('store_name', dataToSave['store_name']);
        }

        if (showMsg) {
          final loc = AppLocalizations.of(context);
          if (loc != null) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(loc.settingsSavedSuccess)));
          }
        }
      } catch (e, stack) {
        final loc = AppLocalizations.of(context);
        final msg = loc?.settingsSaveError(e.toString()) ?? 'Error saving settings: $e';
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      }
    }
  }

  Future<void> _deleteAccount() async {
    final loc = AppLocalizations.of(context);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(loc?.deleteAccountTitle ?? 'Delete'),
        content: Text(loc?.deleteAccountConfirm ?? 'Delete?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(loc?.cancel ?? 'Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(loc?.delete ?? 'Delete'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance.collection('merchants').doc(user.uid).delete();
        await FirebaseAuth.instance.signOut();
        if (mounted) {
          Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final user = FirebaseAuth.instance.currentUser;

    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_fetchError != null) {
      return Scaffold(
        appBar: AppBar(title: Text(loc?.dataErrorTitle ?? 'Error')),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 60),
                const SizedBox(height: 20),
                Text(
                  loc?.storeDataFetchError ?? 'Error fetching data',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _fetchError!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red, fontSize: 14),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: _fetchData,
                  icon: const Icon(Icons.refresh),
                  label: Text(loc?.retry ?? 'Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (user != null && _data == null) {
      _data = {
        'id': user.uid,
        'email': user.email ?? '',
        'store_name': '',
        'activity_type': null,
        'phone': '',
        'location': '',
        'whatsapp': '',
        'facebook': '',
        'instagram': '',
        'description': '',
        'logo_url': null,
        'created_at': Timestamp.now(),
      };
    }

    if (_data == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(loc?.settingsTitle ?? 'Settings'),
          leading: const HomeButton(),
        ),
        body: Center(child: Text(loc?.loginToViewSettings ?? 'Login to view settings.')),
      );
    }

    final storeName = (_data!['store_name'] != null && (_data!['store_name'] as String).isNotEmpty)
        ? _data!['store_name']
        : '';
    return Scaffold(
      appBar: AppBar(
        leading: const HomeButton(),
        title: Row(
          children: [
            Text(loc?.merchantDashboardTitle ?? 'Merchant Dashboard'),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                storeName,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: GestureDetector(
              onTap: _pickLogo,
              child: CircleAvatar(
                radius: 48,
                backgroundImage: _logoFile != null
                    ? FileImage(_logoFile!)
                    : (_data!['logo_url'] != null ? NetworkImage(_data!['logo_url']) : null) as ImageProvider?,
                child: _logoFile == null && _data!['logo_url'] == null
                    ? const Icon(Icons.store, size: 48, color: Colors.deepPurple)
                    : null,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _InfoTile(
                    icon: Icons.store,
                    label: loc?.storeName ?? 'اسم المتجر',
                    value: (_data!['store_name'] ?? '').toString(),
                  ),
                  const Divider(),
                  _InfoTile(
                    icon: Icons.category,
                    label: loc?.activityType ?? 'نوع النشاط',
                    value: (_data!['activity_type'] ?? '').toString(),
                  ),
                  const Divider(),
                  _InfoTile(
                    icon: Icons.location_on,
                    label: loc?.mapLocationLabel ?? 'الموقع',
                    value: _data!['location'] is Map
                        ? 'Lat: ' + (_data!['location']['lat']?.toStringAsFixed(5) ?? '-') + ', Lng: ' + (_data!['location']['lng']?.toStringAsFixed(5) ?? '-')
                        : (_data!['location'] ?? '').toString(),
                  ),
                  const Divider(),
                  _InfoTile(
                    icon: Icons.email,
                    label: loc?.email ?? 'البريد الإلكتروني',
                    value: (_data!['email'] ?? '').toString(),
                  ),
                  const Divider(),
                  _InfoTile(
                    icon: Icons.phone,
                    label: loc?.phone ?? 'رقم الهاتف',
                    value: (_data!['phone'] ?? '').toString(),
                  ),
                  const Divider(),
                  _InfoTile(
                    icon: Icons.calendar_today,
                    label: loc?.createdAt ?? 'تاريخ الإنشاء',
                    value: (_data!['created_at'] is Timestamp)
                        ? ((_data!['created_at'] as Timestamp).toDate().toIso8601String().split('T').first)
                        : (loc?.unspecified ?? 'غير محدد'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            initialValue: (_data!['store_name'] != null && (_data!['store_name'] as String).isNotEmpty) ? _data!['store_name'] : '',
            decoration: InputDecoration(labelText: loc?.storeName ?? 'اسم المحل'),
            onChanged: (val) => _data!['store_name'] = val,
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _data!['activity_type'],
            items: activityTypes.map((type) => DropdownMenuItem(value: type, child: Text(type))).toList(),
            decoration: InputDecoration(labelText: loc?.activityType ?? 'نوع النشاط'),
            onChanged: (val) => setState(() => _data!['activity_type'] = val),
          ),
          const SizedBox(height: 12),
          TextFormField(
            initialValue: _data!['phone'] ?? '',
            decoration: InputDecoration(labelText: loc?.phone ?? 'رقم الهاتف'),
            keyboardType: TextInputType.phone,
            onChanged: (val) => _data!['phone'] = val,
          ),
          const SizedBox(height: 12),
          Text(loc?.workHoursTitle ?? 'ساعات العمل', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          ...List.generate(7, (i) {
            final days = [
              loc?.daySunday ?? 'الأحد',
              loc?.dayMonday ?? 'الاثنين',
              loc?.dayTuesday ?? 'الثلاثاء',
              loc?.dayWednesday ?? 'الأربعاء',
              loc?.dayThursday ?? 'الخميس',
              loc?.dayFriday ?? 'الجمعة',
              loc?.daySaturday ?? 'السبت',
            ];
            final workHours = (_data!['work_hours'] ?? {})[days[i]] ?? {'from': '', 'to': ''};
            return Row(
              children: [
                SizedBox(width: 70, child: Text(days[i]))
                ,Expanded(
                  child: TextFormField(
                    initialValue: workHours['from'],
                    decoration: InputDecoration(labelText: loc?.fromLabel ?? 'من'),
                    onChanged: (val) {
                      final wh = Map<String, dynamic>.from(_data!['work_hours'] ?? {});
                      wh[days[i]] = {'from': val, 'to': workHours['to']};
                      _data!['work_hours'] = wh;
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    initialValue: workHours['to'],
                    decoration: InputDecoration(labelText: loc?.toLabel ?? 'إلى'),
                    onChanged: (val) {
                      final wh = Map<String, dynamic>.from(_data!['work_hours'] ?? {});
                      wh[days[i]] = {'from': workHours['from'], 'to': val};
                      _data!['work_hours'] = wh;
                    },
                  ),
                ),
              ],
            );
          }),
          const SizedBox(height: 12),
          TextFormField(
            initialValue: _data!['whatsapp'] ?? '',
            decoration: InputDecoration(labelText: loc?.whatsappLinkOptional ?? 'رابط واتساب (اختياري)'),
            onChanged: (val) => _data!['whatsapp'] = val,
          ),
          const SizedBox(height: 12),
          TextFormField(
            initialValue: _data!['facebook'] ?? '',
            decoration: InputDecoration(labelText: loc?.facebookLinkOptional ?? 'رابط فيسبوك (اختياري)'),
            onChanged: (val) => _data!['facebook'] = val,
          ),
          const SizedBox(height: 12),
          TextFormField(
            initialValue: _data!['instagram'] ?? '',
            decoration: InputDecoration(labelText: loc?.instagramLinkOptional ?? 'رابط إنستغرام (اختياري)'),
            onChanged: (val) => _data!['instagram'] = val,
          ),
          const SizedBox(height: 12),
          TextFormField(
            initialValue: _data!['description'] ?? '',
            decoration: InputDecoration(labelText: loc?.shortDescriptionLabel ?? 'وصف قصير عن المتجر (اختياري)'),
            maxLines: 2,
            onChanged: (val) => _data!['description'] = val,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  initialValue: _data!['location'] is Map
                      ? 'Lat: ' + (_data!['location']['lat']?.toStringAsFixed(5) ?? '-') + ', Lng: ' + (_data!['location']['lng']?.toStringAsFixed(5) ?? '-')
                      : (_data!['location'] ?? ''),
                  decoration: InputDecoration(labelText: loc?.mapLocationLabel ?? 'الموقع (إحداثيات أو عنوان)'),
                  onChanged: (val) => _data!['location'] = val,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.map, color: Colors.deepPurple),
                tooltip: loc?.pickLocationTooltip ?? 'تحديد الموقع على الخريطة',
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(loc?.mapPickSoon ?? 'سيتم دعم اختيار الموقع من الخريطة قريباً.')),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _saveSettings,
            icon: const Icon(Icons.save),
            label: Text(loc?.saveChanges ?? 'حفظ التغييرات'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple, foregroundColor: Colors.white),
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: _deleteAccount,
            icon: const Icon(Icons.delete, color: Colors.red),
            label: Text(loc?.deleteAccountButton ?? 'حذف الحساب', style: const TextStyle(color: Colors.red)),
          ),
          const SizedBox(height: 24),
          Text(loc?.servicesSectionTitle ?? 'أقسام/خدمات المحل', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          ...List.generate((_data!['services'] ?? []).length, (i) {
            final service = (_data!['services'] ?? [])[i];
            return Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: service,
                    decoration: InputDecoration(labelText: (loc?.serviceNumberLabel(i + 1) ?? 'خدمة/قسم رقم ${i + 1}')),
                    onChanged: (val) {
                      final services = List<String>.from(_data!['services'] ?? []);
                      services[i] = val;
                      _data!['services'] = services;
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    final services = List<String>.from(_data!['services'] ?? []);
                    services.removeAt(i);
                    setState(() => _data!['services'] = services);
                  },
                ),
              ],
            );
          }),
          TextButton.icon(
            onPressed: () {
              final services = List<String>.from(_data!['services'] ?? []);
              services.add('');
              setState(() => _data!['services'] = services);
            },
            icon: const Icon(Icons.add),
            label: Text(loc?.addServiceButton ?? 'إضافة خدمة/قسم'),
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            title: Text(loc?.adsEnabledTitle ?? 'تفعيل الإعلانات داخل التطبيق'),
            value: _data!['ads_enabled'] ?? true,
            onChanged: (val) {
              setState(() => _data!['ads_enabled'] = val);
            },
            activeColor: Colors.deepPurple,
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            title: Text(loc?.visibleInStoreTitle ?? 'إظهار المحل في المتجر للعملاء'),
            value: _data!['visible_in_store'] ?? true,
            onChanged: (val) {
              setState(() => _data!['visible_in_store'] = val);
            },
            activeColor: Colors.deepPurple,
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            title: Text(loc?.disableContactTitle ?? 'تعطيل التواصل مع المحل (واتساب/فيسبوك/إنستغرام)'),
            value: _data!['disable_contact'] ?? false,
            onChanged: (val) {
              setState(() => _data!['disable_contact'] = val);
            },
            activeColor: Colors.deepPurple,
          ),
          const SizedBox(height: 24),
          Text(loc?.socialAccountsTitle ?? 'ربط المحل بحسابات الوصول الاجتماعي', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(loc?.linkGoogleSoon ?? 'سيتم دعم ربط Google قريباً.')),
                  );
                },
                icon: const Icon(Icons.account_circle, color: Colors.red),
                label: const Text('Google'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(loc?.linkFacebookSoon ?? 'سيتم دعم ربط Facebook قريباً.')),
                  );
                },
                icon: const Icon(Icons.facebook, color: Colors.blue),
                label: const Text('Facebook'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(loc?.linkInstagramSoon ?? 'سيتم دعم ربط Instagram قريباً.')),
                  );
                },
                icon: const Icon(Icons.camera_alt, color: Colors.purple),
                label: const Text('Instagram'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black),
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoTile({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.deepPurple.withOpacity(0.08),
            borderRadius: BorderRadius.circular(8),
          ),
            padding: const EdgeInsets.all(8),
          child: Icon(icon, color: Colors.deepPurple, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87)),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(fontSize: 15, color: Colors.black87), overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ],
    );
  }
}

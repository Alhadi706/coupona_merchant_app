import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
// import 'package:supabase_flutter/supabase_flutter.dart'; // إزالة الاعتماد على حزمة supabase
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:hive/hive.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _loading = true;
  Map<String, dynamic>? _data;
  File? _logoFile;
  String? _fetchError; // متغير جديد لتخزين رسالة الخطأ

  // قائمة الفئات المقترحة
  final List<String> activityTypes = [
    'متجر ملابس', // تصحيح: توحيد القيمة مع ما هو موجود في قاعدة البيانات
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
      _fetchError = null; // إعادة تعيين الخطأ عند كل محاولة
    });
    final user = FirebaseAuth.instance.currentUser;
    print('DEBUG: Attempting to fetch data for user: ${user?.uid}');

    if (user == null) {
      print('DEBUG: No user is logged in.');
      setState(() {
        _data = null;
        _loading = false;
        _fetchError = 'المستخدم غير مسجل دخوله. يرجى إعادة تسجيل الدخول.';
      });
      return;
    }

    try {
      final merchantDoc = await FirebaseFirestore.instance
          .collection('merchants')
          .doc(user.uid)
          .get();

      if (merchantDoc.exists) {
        print('DEBUG: Data found for user: ${user.uid}');
        setState(() {
          _data = merchantDoc.data();
          _data!['id'] = merchantDoc.id;
          _loading = false;
        });
      } else {
        print('DEBUG: No data for user ${user.uid}. Creating a new profile.');
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
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم إنشاء ملف تعريفي جديد. يرجى تعبئة بيانات متجرك.')),
          );
        }
      }
    } catch (e, stack) {
      final errorMessage =
          'فشل الاتصال بقاعدة البيانات. تحقق من اتصالك بالإنترنت أو إعدادات Firestore.';
      print('!!! FETCH ERROR: $e\n$stack');
      setState(() {
        _data = null;
        _fetchError = '$errorMessage\n\nتفاصيل الخطأ الفني:\n$e'; // تخزين الخطأ لعرضه
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
    // استخدام Firebase Auth
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final fileName = 'merchant_logos/${user.uid}_${DateTime.now().millisecondsSinceEpoch}.png';
    // استخدام Firebase Storage
    final storageRef = FirebaseStorage.instance.ref().child(fileName);

    try {
      final uploadTask = await storageRef.putFile(_logoFile!);
      final url = await uploadTask.ref.getDownloadURL();
      setState(() => _data!['logo_url'] = url);
      await _saveSettings(showMsg: false);
    } catch (e) {
      print('Error uploading logo: $e');
      // معالجة الخطأ هنا إذا لزم الأمر
    }
  }

  Future<void> _saveSettings({bool showMsg = true}) async {
    // استخدام Firebase Auth
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && _data != null) {
      try {
        // لا حاجة لتحديث user_id لأنه معرّف المستند
        final dataToSave = Map<String, dynamic>.from(_data!);
        dataToSave.remove('id'); // إزالة المعرف قبل الحفظ

        // استخدام Firestore للتحديث أو الإنشاء
        await FirebaseFirestore.instance
            .collection('merchants')
            .doc(user.uid)
            .set(dataToSave, SetOptions(merge: true)); // استخدام .set مع merge

        // مزامنة اسم المحل مع جدول users (إذا كان موجوداً)
        if (dataToSave['store_name'] != null && (dataToSave['store_name'] as String).isNotEmpty) {
          // هذا الجزء يفترض وجود collection اسمها users بنفس الـ uid
           await FirebaseFirestore.instance.collection('users').doc(user.uid).set({'store_name': dataToSave['store_name']}, SetOptions(merge: true));
          
          var settingsBox = await Hive.openBox('settingsBox');
          await settingsBox.put('store_name', dataToSave['store_name']);
        }

        if (showMsg) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم حفظ الإعدادات بنجاح!')));
        }
      } catch (e, stack) {
        print('خطأ أثناء حفظ الإعدادات: $e\n$stack');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('حدث خطأ أثناء حفظ الإعدادات: $e')),
        );
      }
    }
  }

  Future<void> _deleteAccount() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('حذف الحساب'),
        content: const Text('هل أنت متأكد من حذف حسابك نهائياً؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('حذف'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          ),
        ],
      ),
    );
    if (confirm == true) {
      // استخدام Firebase Auth
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // حذف البيانات من Firestore
        await FirebaseFirestore.instance.collection('merchants').doc(user.uid).delete();
        // تسجيل الخروج من Firebase
        await FirebaseAuth.instance.signOut();
        if (mounted) {
          Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    print('DEBUG: build() called, user = \${user?.uid}');
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // -- هذا هو الجزء الجديد لتشخيص المشكلة --
    // إذا كان هناك خطأ، اعرضه بوضوح مع زر إعادة المحاولة
    if (_fetchError != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('خطأ في البيانات')),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 60),
                const SizedBox(height: 20),
                const Text(
                  'حدث خطأ أثناء استجلاب بيانات المتجر',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                    _fetchError!, // عرض رسالة الخطأ التي تم تخزينها
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red, fontSize: 14),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: _fetchData,
                  icon: const Icon(Icons.refresh),
                  label: const Text('إعادة المحاولة'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // إذا لم يكن هناك خطأ، استمر في عرض الواجهة كالمعتاد
    // هذا المنطق يعالج حالة التاجر الجديد الذي ليس لديه بيانات بعد
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
      // This case should now only be hit if the user is not logged in.
      return Scaffold(
        appBar: AppBar(title: const Text('الإعدادات')),
        body: const Center(child: Text('يرجى تسجيل الدخول لعرض الإعدادات.')),
      );
    }

    final storeName = (_data!['store_name'] != null && (_data!['store_name'] as String).isNotEmpty)
        ? _data!['store_name']
        : '';
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text('لوحة تحكم تاجر'),
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
          // معلومات المتجر مرتبة تحت الصورة مباشرة
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
                    label: 'اسم المتجر',
                    value: (_data!['store_name'] ?? '').toString(),
                  ),
                  const Divider(),
                  _InfoTile(
                    icon: Icons.category,
                    label: 'نوع النشاط',
                    value: (_data!['activity_type'] ?? '').toString(),
                  ),
                  const Divider(),
                  _InfoTile(
                    icon: Icons.location_on,
                    label: 'الموقع',
                    value: _data!['location'] is Map
                        ? 'Lat: ' + (_data!['location']['lat']?.toStringAsFixed(5) ?? '-') + ', Lng: ' + (_data!['location']['lng']?.toStringAsFixed(5) ?? '-')
                        : (_data!['location'] ?? '').toString(),
                  ),
                  const Divider(),
                  _InfoTile(
                    icon: Icons.email,
                    label: 'البريد الإلكتروني',
                    value: (_data!['email'] ?? '').toString(),
                  ),
                  const Divider(),
                  _InfoTile(
                    icon: Icons.phone,
                    label: 'رقم الهاتف',
                    value: (_data!['phone'] ?? '').toString(),
                  ),
                  const Divider(),
                  _InfoTile(
                    icon: Icons.calendar_today,
                    label: 'تاريخ الإنشاء',
                    value: (_data!['created_at'] is Timestamp)
                        ? ((_data!['created_at'] as Timestamp).toDate().toIso8601String().split('T').first)
                        : 'غير محدد',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            initialValue: (_data!['store_name'] != null && (_data!['store_name'] as String).isNotEmpty) ? _data!['store_name'] : '',
            decoration: const InputDecoration(labelText: 'اسم المحل'),
            onChanged: (val) => _data!['store_name'] = val,
          ),
          const SizedBox(height: 12),
          // اختيار الفئة من قائمة
          DropdownButtonFormField<String>(
            value: _data!['activity_type'],
            items: activityTypes.map((type) => DropdownMenuItem(value: type, child: Text(type))).toList(),
            decoration: const InputDecoration(labelText: 'نوع النشاط'),
            onChanged: (val) => setState(() => _data!['activity_type'] = val),
          ),
          const SizedBox(height: 12),
          // رقم الهاتف
          TextFormField(
            initialValue: _data!['phone'] ?? '',
            decoration: const InputDecoration(labelText: 'رقم الهاتف'),
            keyboardType: TextInputType.phone,
            onChanged: (val) => _data!['phone'] = val,
          ),
          const SizedBox(height: 12),
          // روابط الاتصال
          TextFormField(
            initialValue: _data!['whatsapp'] ?? '',
            decoration: const InputDecoration(labelText: 'رابط واتساب (اختياري)'),
            onChanged: (val) => _data!['whatsapp'] = val,
          ),
          const SizedBox(height: 12),
          TextFormField(
            initialValue: _data!['facebook'] ?? '',
            decoration: const InputDecoration(labelText: 'رابط فيسبوك (اختياري)'),
            onChanged: (val) => _data!['facebook'] = val,
          ),
          const SizedBox(height: 12),
          TextFormField(
            initialValue: _data!['instagram'] ?? '',
            decoration: const InputDecoration(labelText: 'رابط إنستغرام (اختياري)'),
            onChanged: (val) => _data!['instagram'] = val,
          ),
          const SizedBox(height: 12),
          // وصف قصير
          TextFormField(
            initialValue: _data!['description'] ?? '',
            decoration: const InputDecoration(labelText: 'وصف قصير عن المتجر (اختياري)'),
            maxLines: 2,
            onChanged: (val) => _data!['description'] = val,
          ),
          const SizedBox(height: 12),
          // الموقع على الخريطة
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  initialValue: _data!['location'] is Map
                      ? 'Lat: ' + (_data!['location']['lat']?.toStringAsFixed(5) ?? '-') + ', Lng: ' + (_data!['location']['lng']?.toStringAsFixed(5) ?? '-')
                      : (_data!['location'] ?? ''),
                  decoration: const InputDecoration(labelText: 'الموقع (إحداثيات أو عنوان)'),
                  onChanged: (val) => _data!['location'] = val,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.map, color: Colors.deepPurple),
                tooltip: 'تحديد الموقع على الخريطة',
                onPressed: () {
                  // TODO: ربط شاشة اختيار الموقع
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('سيتم دعم اختيار الموقع من الخريطة قريباً.')),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _saveSettings,
            icon: const Icon(Icons.save),
            label: const Text('حفظ التغييرات'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple, foregroundColor: Colors.white),
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: _deleteAccount,
            icon: const Icon(Icons.delete, color: Colors.red),
            label: const Text('حذف الحساب', style: TextStyle(color: Colors.red)),
          ),
          const SizedBox(height: 24),
          // تم حذف أيقونة معلومات المتجر نهائياً
        ],
      ),
    );
  }
}

// إضافة ويدجت لعرض صف معلومات بشكل أنيق
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

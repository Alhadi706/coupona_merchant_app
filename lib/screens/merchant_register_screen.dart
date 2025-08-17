import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'pick_location_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';
import 'package:collection/collection.dart';

class MerchantRegisterScreen extends StatefulWidget {
  const MerchantRegisterScreen({Key? key}) : super(key: key);

  @override
  State<MerchantRegisterScreen> createState() => _MerchantRegisterScreenState();
}

class _MerchantRegisterScreenState extends State<MerchantRegisterScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _activityTypeOtherController = TextEditingController();
  final TextEditingController _storeNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final List<String> activityTypes = [
    'مقهى',
    'مطعم',
    'متجر ملابس',
    'صيدلية',
    'سوبرماركت',
    'أخرى...'
  ];
  String selectedActivity = 'مقهى';
  bool useOtherActivity = false;
  bool _loading = false;
  LatLng? pickedLocation;

  // خريطة رموز النشاط بالإنجليزي
  final Map<String, String> activityTypeCodes = {
    'مقهى': 'CF',
    'مطعم': 'TR',
    'متجر ملابس': 'CL',
    'صيدلية': 'PH',
    'سوبرماركت': 'SM',
    'أخرى...': 'OT',
  };

  Future<void> _register() async {
    setState(() => _loading = true);
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();
    final storeName = _storeNameController.text.trim();
    final phone = _phoneController.text.trim();
    final activityType = useOtherActivity ? _activityTypeOtherController.text.trim() : selectedActivity;

    if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty || storeName.isEmpty || activityType.isEmpty || phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى تعبئة جميع الحقول المطلوبة')),
      );
      setState(() => _loading = false);
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('كلمتا المرور غير متطابقتين')),
      );
      setState(() => _loading = false);
      return;
    }

    final emailRegex = RegExp(r'^[\w\.-]+@[\w\.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى إدخال بريد إلكتروني صحيح')),
      );
      setState(() => _loading = false);
      return;
    }

    if (pickedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى اختيار موقع المحل على الخريطة')),
      );
      setState(() => _loading = false);
      return;
    }

    try {
      final fbUserCred = await fb_auth.FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
      // إنشاء مستخدم في Supabase بنفس البريد وكلمة المرور إن لم يوجد
      try {
        await SupabaseService.client.auth.signUp(email: email, password: password);
      } catch (e) {
        debugPrint('Supabase signUp (قد يكون موجود مسبقاً): $e');
      }
      // تسجيل الدخول Supabase لضمان توفر auth.uid()
      try {
        await SupabaseService.ensureLogin(email: email, password: password);
      } catch (e) {
        debugPrint('Supabase signIn failed: $e');
      }
      // جلب المستخدم الحالي بشكل موثوق بعد الإنشاء
      final user = await fb_auth.FirebaseAuth.instance.authStateChanges().first;
      debugPrint('Firebase user after registration (authStateChanges): ${user?.uid}');
      if (user != null) {
        // ملاحظة: لا يمكن مزامنة جلسة Firebase مع Supabase مباشرة في Flutter، سيتم الاعتماد فقط على Firebase Auth هنا.
        // توليد رمز مختصر للتاجر بالإنجليزي
        String cityCode = 'TRP'; // رمز ثابت أو استنتاج من المدينة لاحقاً
        String typeCode = activityTypeCodes[activityType] ?? 'OT';
        final merchantCode = await SupabaseService.generateMerchantCode(cityCode, typeCode);
        // تحقق من أن user.uid ليس null
        debugPrint('Firebase user.uid: \\${user.uid}');
        if (user.uid == null || user.uid.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تعذر الحصول على معرف المستخدم (user.uid)!')),
          );
          setState(() => _loading = false);
          return;
        }
        // إضافة بيانات التاجر في جدول merchants في Supabase مباشرة
        try {
          final supaUid = SupabaseService.client.auth.currentUser?.id; // قد يكون UUID مختلف عن Firebase UID
          final merchantData = {
            'id': supaUid ?? user.uid,
            'store_name': storeName,
            'location': '${pickedLocation!.latitude},${pickedLocation!.longitude}',
            'email': email,
            'phone': phone,
            'logo_url': 'https://cdn-icons-png.flaticon.com/512/3135/3135715.png',
            'role': 'merchant',
            'activity_type': activityType,
            'created_at': DateTime.now().toIso8601String(),
            'user_id': supaUid ?? user.uid,
            'merchant_code': merchantCode,
            // تمت إزالة firebase_uid لأن العمود غير موجود في جدول merchants في Supabase
          };
          debugPrint('merchantData to insert: $merchantData');
          await SupabaseService.client.from('merchants').insert([merchantData]);
          // ملاحظة: إنشاء قروب المحل أصبح يدويًا من شاشة المجتمع
        } catch (e) {
          debugPrint('خطأ أثناء إضافة بيانات التاجر في Supabase: $e');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('خطأ أثناء إضافة بيانات التاجر في Supabase: $e')),
          );
        }
        // تخزين بيانات التاجر في مجموعة users (مطابقة مع تطبيق الزبون)
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'id': user.uid,
          'email': email,
          'phone': phone,
          'store_name': storeName,
          'activity_type': activityType,
          'location': {'lat': pickedLocation!.latitude, 'lng': pickedLocation!.longitude},
          'logo_url': 'https://cdn-icons-png.flaticon.com/512/3135/3135715.png',
          'role': 'merchant',
          'created_at': DateTime.now().toIso8601String(),
        });
        // يمكن إبقاء التخزين في merchants إذا كان هناك منطق خاص للتجار
        await FirebaseFirestore.instance.collection('merchants').doc(user.uid).set({
          'id': user.uid,
          'email': email,
          'phone': phone,
          'store_name': storeName,
          'activity_type': activityType,
          'location': {'lat': pickedLocation!.latitude, 'lng': pickedLocation!.longitude},
          'logo_url': 'https://cdn-icons-png.flaticon.com/512/3135/3135715.png',
          'role': 'merchant',
          'created_at': DateTime.now().toIso8601String(),
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم إنشاء الحساب بنجاح!')),
          );
          debugPrint('تم إنشاء الحساب بنجاح، سيتم الانتقال إلى /dashboard');
          context.go('/dashboard');
          setState(() => _loading = false);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('فشل إنشاء الحساب. حاول مرة أخرى.')),
          );
        }
      }
    } on fb_auth.FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل إنشاء الحساب: ${e.message}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('حدث خطأ غير متوقع: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    testSupabaseRead();
  }

  void testSupabaseRead() async {
    try {
      final response = await SupabaseService.client.from('merchants').select().limit(1);
      debugPrint('Test read merchants: ' + response.toString());
    } catch (e) {
      debugPrint('Test read merchants ERROR: ' + e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تسجيل تاجر جديد')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            const SizedBox(height: 32),
            TextField(
              controller: _emailController, // تغيير اسم المتحكم
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'البريد الإلكتروني', // تغيير النص
                prefixIcon: Icon(Icons.email),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'رقم الهاتف',
                prefixIcon: Icon(Icons.phone),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'كلمة المرور',
                prefixIcon: Icon(Icons.lock),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _confirmPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'تأكيد كلمة المرور',
                prefixIcon: Icon(Icons.lock_outline),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _storeNameController,
              decoration: const InputDecoration(
                labelText: 'اسم المحل',
                prefixIcon: Icon(Icons.store),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: selectedActivity,
              items: activityTypes
                  .map((type) => DropdownMenuItem(
                        value: type,
                        child: Text(type),
                      ))
                  .toList(),
              onChanged: (val) {
                setState(() {
                  if (val == 'أخرى...') {
                    useOtherActivity = true;
                  } else {
                    useOtherActivity = false;
                    selectedActivity = val ?? activityTypes[0];
                  }
                });
              },
              decoration: const InputDecoration(
                labelText: 'نوع النشاط',
                prefixIcon: Icon(Icons.storefront),
                border: OutlineInputBorder(),
              ),
            ),
            if (useOtherActivity)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: TextField(
                  controller: _activityTypeOtherController,
                  decoration: const InputDecoration(
                    labelText: 'حدد نوع النشاط الآخر',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            const SizedBox(height: 16),
            TextButton.icon(
              icon: const Icon(Icons.location_on, color: Colors.deepPurple),
              label: Text(pickedLocation == null ? 'حدد موقع المحل على الخريطة' : 'تم اختيار الموقع'),
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
            const SizedBox(height: 32),
            _loading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _register,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('تسجيل', style: TextStyle(fontSize: 18)),
                  ),
          ],
        ),
      ),
    );
  }
}

import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'pick_location_screen.dart';
import '../services/supabase_service.dart';
import '../services/session_guard.dart';
import 'package:geolocator/geolocator.dart';
import 'package:coupona_merchant/gen_l10n/app_localizations.dart';

class MerchantRegisterScreen extends StatefulWidget {
  const MerchantRegisterScreen({Key? key}) : super(key: key);

  @override
  State<MerchantRegisterScreen> createState() => _MerchantRegisterScreenState();
}

class _MerchantRegisterScreenState extends State<MerchantRegisterScreen> {
  AppLocalizations? get loc => AppLocalizations.of(context);
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _activityTypeOtherController = TextEditingController();
  final TextEditingController _storeNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final List<String> activityTypes = [
    'Cafe',
    'Restaurant',
    'Clothing Store',
    'Pharmacy',
    'Supermarket',
    'Other'
  ];
  String selectedActivity = 'Cafe';
  bool useOtherActivity = false;
  bool _loading = false;
  LatLng? pickedLocation;
  bool _gettingLocation = false;

  // خريطة رموز النشاط بالإنجليزي
  final Map<String, String> activityTypeCodes = {
    'Cafe': 'CF',
    'Restaurant': 'TR',
    'Clothing Store': 'CL',
    'Pharmacy': 'PH',
    'Supermarket': 'SM',
    'Other': 'OT',
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
  final loc = AppLocalizations.of(context);
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(loc?.fillAllFields ?? 'Fill all fields')));
      setState(() => _loading = false);
      return;
    }

    if (password != confirmPassword) {
  final loc = AppLocalizations.of(context);
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(loc?.passwordsNotMatch ?? 'Passwords do not match')));
      setState(() => _loading = false);
      return;
    }

    final emailRegex = RegExp(r'^[\w\.-]+@[\w\.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(email)) {
  final loc = AppLocalizations.of(context);
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(loc?.invalidEmail ?? 'Invalid email')));
      setState(() => _loading = false);
      return;
    }

    if (pickedLocation == null) {
      final loc = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(loc?.pickStoreOnMap ?? 'Pick store location')));
      setState(() => _loading = false);
      return;
    }

    try {
      // فحص مسبق: هل البريد مستخدم في Firebase؟
      final existingMethods = await fb_auth.FirebaseAuth.instance.fetchSignInMethodsForEmail(email);
      if (existingMethods.isNotEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context)?.emailAlreadyUsed ?? 'Email already used')),
          );
        }
        setState(() => _loading = false);
        return;
      }

      // إنشاء المستخدم Firebase أولاً
      final fbUserCred = await fb_auth.FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
      SessionGuard.remember(email, password);
      // محاولة جسر تلقائي (ينشئ أو يسجّل مستخدم Supabase بكلمة مشتقة)
      bool bridged = await SupabaseService.ensureBridgedSessionFromFirebase();
      if (!bridged) {
        // fallback: استعمال نفس البريد/كلمة المرور مباشرة (حساب Supabase يدوي)
        var supaOk = await SupabaseService.ensureLogin(email: email, password: password);
        if (!supaOk) {
          try {
            await SupabaseService.client.auth.signUp(email: email, password: password);
            supaOk = await SupabaseService.ensureLogin(email: email, password: password);
          } catch (e) {
            debugPrint('Supabase manual signUp/login failed: $e');
          }
        }
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
            SnackBar(content: Text(AppLocalizations.of(context)?.unexpectedError ?? 'Unexpected error')),
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
          final loc = AppLocalizations.of(context);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${loc?.unexpectedError ?? 'Unexpected error'}: $e')));
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
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)?.accountCreatedSuccess ?? 'Account created')));
          debugPrint('تم إنشاء الحساب بنجاح، سيتم الانتقال إلى /dashboard');
          context.go('/dashboard');
          setState(() => _loading = false);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)?.accountCreateFailed ?? 'Account creation failed')));
        }
      }
    } on fb_auth.FirebaseAuthException catch (e) {
      if (mounted) {
  final loc = AppLocalizations.of(context);
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${loc?.accountCreateFailed ?? 'Account creation failed'}: ${e.message}')));
      }
    } catch (e) {
      if (mounted) {
  final loc = AppLocalizations.of(context);
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${loc?.unexpectedError ?? 'Unexpected error'}: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _getCurrentLocationAuto() async {
    if (_gettingLocation) return; setState(()=>_gettingLocation=true);
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        final loc = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(loc?.locationServiceDisabled ?? 'Location disabled')));
        return;
      }
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          final loc = AppLocalizations.of(context);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(loc?.locationPermissionDenied ?? 'Location permission denied')));
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        final loc = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(loc?.locationPermissionDeniedForever ?? 'Permission permanently denied')));
        return;
      }
      final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      setState(()=>pickedLocation = LatLng(pos.latitude, pos.longitude));
      final loc = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(loc?.locationAutoCaptured ?? 'Location captured')));
    } catch (e) {
      final loc = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(loc?.locationFailed(e.toString()) ?? 'Location failed: $e')));
    } finally { if(mounted) setState(()=>_gettingLocation=false); }
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
    final loc = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(loc?.registerNewMerchantTitle ?? 'Register')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            const SizedBox(height: 32),
            TextField(
              controller: _emailController, // تغيير اسم المتحكم
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: loc?.emailLabel ?? 'Email',
                prefixIcon: const Icon(Icons.email),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: loc?.phoneLabel ?? 'Phone',
                prefixIcon: const Icon(Icons.phone),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: loc?.passwordLabel ?? 'Password',
                prefixIcon: const Icon(Icons.lock),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _confirmPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: loc?.confirmPasswordLabel ?? 'Confirm Password',
                prefixIcon: const Icon(Icons.lock_outline),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _storeNameController,
              decoration: InputDecoration(
                labelText: loc?.storeNameLabel ?? 'Store Name',
                prefixIcon: const Icon(Icons.store),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: selectedActivity,
              items: activityTypes
                  .map((type) => DropdownMenuItem(
                        value: type,
                        child: Text(_localizedActivity(type, loc)),
                      ))
                  .toList(),
              onChanged: (val) {
                setState(() {
                  if (val == 'Other') {
                    useOtherActivity = true;
                  } else {
                    useOtherActivity = false;
                    selectedActivity = val ?? activityTypes[0];
                  }
                });
              },
              decoration: InputDecoration(
                labelText: loc?.activityTypeLabel ?? 'Activity Type',
                prefixIcon: const Icon(Icons.storefront),
                border: const OutlineInputBorder(),
              ),
            ),
            if (useOtherActivity)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: TextField(
                  controller: _activityTypeOtherController,
                  decoration: InputDecoration(
                    labelText: loc?.activityOtherPrompt ?? 'Specify other activity',
                    border: const OutlineInputBorder(),
                  ),
                ),
              ),
            const SizedBox(height: 16),
            TextButton.icon(
              icon: const Icon(Icons.location_on, color: Colors.deepPurple),
              label: Text(pickedLocation == null ? (loc?.pickStoreOnMap ?? 'Pick store location') : (loc?.storeLocationPicked ?? 'Location selected')),
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
            const SizedBox(height:8),
            OutlinedButton.icon(
              icon: _gettingLocation ? const SizedBox(width:16,height:16,child:CircularProgressIndicator(strokeWidth:2)) : const Icon(Icons.my_location, color: Colors.deepPurple),
              label: Text(_gettingLocation ? (loc?.autoLocating ?? 'Locating...') : (loc?.autoLocateButton ?? 'Auto locate')),
              onPressed: _gettingLocation ? null : _getCurrentLocationAuto,
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
                    child: Text(loc?.submitRegister ?? 'Register', style: const TextStyle(fontSize: 18)),
                  ),
          ],
        ),
      ),
    );
  }

  String _localizedActivity(String key, AppLocalizations? loc) {
    if (loc == null) return key;
    switch (key) {
      case 'Cafe':
        return loc.activityCafe;
      case 'Restaurant':
        return loc.activityRestaurant;
      case 'Clothing Store':
        return loc.activityClothingStore;
      case 'Pharmacy':
        return loc.activityPharmacy;
      case 'Supermarket':
        return loc.activitySupermarket;
      case 'Other':
        return loc.activityOther;
    }
    return key;
  }
}

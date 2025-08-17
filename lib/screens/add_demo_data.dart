// سكريبت لإضافة بيانات تجريبية إلى Firestore (يعمل من تطبيق التاجر أو عبر زر مخفي)
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive/hive.dart';
import 'dart:math';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

Future<String> ensureDemoMerchantUser() async {
  const email = 'demo_merchant@demo.com';
  const password = '123456';
  final auth = FirebaseAuth.instance;
  UserCredential userCredential;
  try {
    userCredential = await auth.signInWithEmailAndPassword(email: email, password: password);
  } on FirebaseAuthException catch (e) {
    if (e.code == 'user-not-found') {
      userCredential = await auth.createUserWithEmailAndPassword(email: email, password: password);
      // إضافة بيانات المستخدم في Firestore مع role: merchant
      await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
        'email': email,
        'role': 'merchant',
        'createdAt': FieldValue.serverTimestamp(),
      });
    } else {
      rethrow;
    }
  }
  return userCredential.user!.uid;
}

// دالة مساعدة لتحويل Timestamp إلى String
Map<String, dynamic> fixTimestamps(Map<String, dynamic> data) {
  return data.map((key, value) {
    if (value is Timestamp) {
      return MapEntry(key, value.toDate().toIso8601String());
    } else if (value is Map) {
      return MapEntry(key, fixTimestamps(Map<String, dynamic>.from(value)));
    } else if (value is List) {
      return MapEntry(key, value.map((e) => e is Map ? fixTimestamps(Map<String, dynamic>.from(e)) : e).toList());
    } else {
      return MapEntry(key, value);
    }
  });
}

Future<void> addDemoDataForMerchant([String? merchantId]) async {
  try {
    if (kIsWeb) {
      merchantId = 'demo_merchant_uid';
    } else if (merchantId == null || merchantId.isEmpty) {
      merchantId = await ensureDemoMerchantUser();
    }
    final firestore = FirebaseFirestore.instance;
    final now = DateTime.now();
    final random = Random();
    final products = [
      {'name': 'قهوة عربية', 'price': 15.0},
      {'name': 'شاي مغربي', 'price': 10.0},
      {'name': 'كيك شوكولاتة', 'price': 25.0},
      {'name': 'عصير برتقال', 'price': 12.0},
      {'name': 'ساندويتش دجاج', 'price': 30.0},
      {'name': 'بيتزا صغيرة', 'price': 35.0},
      {'name': 'ماء', 'price': 5.0},
    ];  // إضافة 5 طلبات فقط (لتسريع التجربة)
    // تحديث كاش المنتجات
    final productsBox = await Hive.openBox('merchant_products_${merchantId}');
    await productsBox.clear();
    for (final p in products) {
      final data = {'merchantId': merchantId, ...p, 'createdAt': Timestamp.now()};
      await productsBox.add(fixTimestamps(data));
    }
    for (int i = 0; i < 5; i++) {
      final date = now.subtract(Duration(days: i));
      final orderProducts = List.generate(random.nextInt(3) + 1, (j) {
        final p = products[random.nextInt(products.length)];
        return {'name': p['name'], 'price': p['price']};
      });
      final total = orderProducts.fold(0.0, (sum, p) => sum + (p['price'] as double));
      final orderData = {
        'merchantId': merchantId,
        'createdAt': Timestamp.fromDate(date),
        'total': total,
        'products': orderProducts,
        'customerId': 'demo_customer_${random.nextInt(5) + 1}',
        'status': random.nextBool() ? 'completed' : 'redeemed',
      };
      await firestore.collection('orders').add(orderData);
      // تحديث كاش الطلبات
      final ordersBox = await Hive.openBox('orders_${merchantId}');
      await ordersBox.add(fixTimestamps(orderData));
    }
    // إضافة عروض تجريبية
    final offer1 = {
      'merchantId': merchantId,
      'isActive': true,
      'title': 'خصم 20% على القهوة',
      'createdAt': Timestamp.now(),
    };
    await firestore.collection('offers').add(offer1);
    final offersBox = await Hive.openBox('offers_${merchantId}');
    await offersBox.add(fixTimestamps(offer1));
    final expiredDate = DateTime.now().subtract(const Duration(days: 10));
    final offer2 = {
      'merchantId': merchantId,
      'isActive': false,
      'title': 'عرض منتهي',
      'createdAt': Timestamp.fromDate(expiredDate),
    };
    await firestore.collection('offers').add(offer2);
    await offersBox.add(fixTimestamps(offer2));

    // إضافة زبائن تجريبيين
    final customers = [
      {'name': 'أحمد محمد', 'phone': '0911111111'},
      {'name': 'سارة علي', 'phone': '0922222222'},
      {'name': 'خالد يوسف', 'phone': '0933333333'},
      {'name': 'ليلى إبراهيم', 'phone': '0944444444'},
      {'name': 'مروان سالم', 'phone': '0955555555'},
    ];
    final customersBox = await Hive.openBox('customers_${merchantId}');
    await customersBox.clear();
    for (final c in customers) {
      final doc = await firestore.collection('customers').add({
        ...c,
        'merchantId': merchantId,
        'createdAt': Timestamp.now(),
      });
      await customersBox.add({...c, 'id': doc.id, 'createdAt': DateTime.now().toIso8601String()});
    }

    // إضافة رسائل مجتمع تجريبية
    final communityBox = await Hive.openBox('community_${merchantId}');
    await communityBox.clear();
    for (int i = 0; i < 5; i++) {
      final msg = {
        'merchantId': merchantId,
        'user': customers[i % customers.length]['name'],
        'message': 'رسالة ترحيب ${i + 1}',
        'createdAt': Timestamp.now(),
      };
      await firestore.collection('community').add(msg);
      await communityBox.add(fixTimestamps(msg));
    }

    // إضافة فواتير تجريبية
    final receiptsBox = await Hive.openBox('receipts_${merchantId}');
    await receiptsBox.clear();
    for (int i = 0; i < 5; i++) {
      final receipt = {
        'merchantId': merchantId,
        'customer': customers[i % customers.length]['name'],
        'total': 50 + random.nextInt(100),
        'createdAt': Timestamp.now(),
        'status': i % 2 == 0 ? 'مدفوع' : 'معلق',
      };
      await firestore.collection('receipts').add(receipt);
      await receiptsBox.add(fixTimestamps(receipt));
    }

    // إضافة جوائز تجريبية
    final rewardsBox = await Hive.openBox('rewards_${merchantId}');
    await rewardsBox.clear();
    for (int i = 0; i < 3; i++) {
      final reward = {
        'merchantId': merchantId,
        'title': 'جائزة رقم ${i + 1}',
        'points': 10 * (i + 1),
        'createdAt': Timestamp.now(),
        'isActive': i != 2,
      };
      await firestore.collection('rewards').add(reward);
      await rewardsBox.add(fixTimestamps(reward));
    }

    // إضافة رسائل دردشة تجريبية
    final chatBox = await Hive.openBox('chat_${merchantId}');
    await chatBox.clear();
    for (int i = 0; i < 5; i++) {
      final chatMsg = {
        'merchantId': merchantId,
        'sender': i % 2 == 0 ? 'تاجر' : customers[i % customers.length]['name'],
        'message': 'رسالة دردشة ${i + 1}',
        'createdAt': Timestamp.now(),
      };
      await firestore.collection('chats').add(chatMsg);
      await chatBox.add(fixTimestamps(chatMsg));
    }

    // إضافة بلاغات دعم تجريبية
    final supportBox = await Hive.openBox('support_${merchantId}');
    await supportBox.clear();
    for (int i = 0; i < 2; i++) {
      final support = {
        'merchantId': merchantId,
        'subject': 'طلب دعم ${i + 1}',
        'message': 'أحتاج مساعدة في ${i == 0 ? 'الدفع' : 'النقاط'}',
        'createdAt': Timestamp.now(),
        'status': i == 0 ? 'مفتوح' : 'مغلق',
      };
      await firestore.collection('support').add(support);
      await supportBox.add(fixTimestamps(support));
    }

    // إضافة بيانات فرع تجريبي
    final branchesBox = await Hive.openBox('branches_${merchantId}');
    await branchesBox.clear();
    final branch = {
      'merchantId': merchantId,
      'name': 'الفرع الرئيسي',
      'location': {'lat': 32.8872, 'lng': 13.1913},
      'address': 'طرابلس - شارع عمر المختار',
      'createdAt': Timestamp.now(),
    };
    await firestore.collection('branches').add(branch);
    await branchesBox.add(fixTimestamps(branch));
  } catch (e, st) {
    print('خطأ أثناء إضافة البيانات التجريبية: $e');
    print(st);
    rethrow;
  }
}

// دالة مركزية لإنشاء المستخدم التجريبي وإضافة البيانات التجريبية إذا لم تكن موجودة
Future<void> ensureDemoMerchantAndData() async {
  String merchantId = 'demo_merchant_uid';
  if (!kIsWeb) {
    merchantId = await ensureDemoMerchantUser();
  }
  final firestore = FirebaseFirestore.instance;
  final products = await firestore.collection('merchant_products')
      .where('merchantId', isEqualTo: merchantId)
      .limit(1).get();
  if (products.docs.isEmpty) {
    await addDemoDataForMerchant(merchantId);
  }
}

// شاشة لإضافة بيانات تجريبية
class DemoDataScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إضافة بيانات تجريبية'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            await addDemoDataForMerchant(FirebaseAuth.instance.currentUser!.uid);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('تمت إضافة البيانات التجريبية بنجاح')),
            );
          },
          child: const Text('إضافة بيانات تجريبية'),
        ),
      ),
    );
  }
}

// يمكنك استدعاء addDemoDataForMerchant(FirebaseAuth.instance.currentUser!.uid) من زر مخفي أو شاشة الإعدادات لإضافة البيانات التجريبية.

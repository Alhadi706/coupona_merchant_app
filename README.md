# كوبونا تاجر (Coupona Merchant)

تطبيق Flutter مخصص للتجار لإدارة العروض والاطلاع على سجل النشاطات، مرتبط بنفس قاعدة بيانات كوبونا (Firebase/Firestore).

## الميزات الأساسية:
- تسجيل دخول وتسجيل تاجر جديد
- لوحة تحكم لإدارة العروض الخاصة بالتاجر
- استعراض وتعديل وحذف العروض
- سجل النشاطات
- ربط كامل مع Firebase Auth وFirestore

## الربط مع قاعدة البيانات
- استخدم نفس مشروع Firebase الخاص بتطبيق الزبون
- يجب تمييز التاجر عبر حقل role في users (role: merchant)

## بدء التشغيل
1. تأكد من وجود ملف google-services.json في android/app
2. نفذ:
   ```
   flutter pub get
   flutter run
   ```

## ملاحظات
- جميع العمليات يجب أن تتم عبر Firestore وFirebase Auth فقط.
- واجهات التطبيق مخصصة للتاجر وليست للزبون.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

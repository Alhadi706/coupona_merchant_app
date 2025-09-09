// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'تطبيق التاجر';

  @override
  String get login => 'تسجيل الدخول';

  @override
  String get logout => 'تسجيل خروج';

  @override
  String get settings => 'الإعدادات';

  @override
  String get language => 'اللغة';

  @override
  String get noMerchantCode => 'لا يوجد رمز';

  @override
  String get copied => 'تم النسخ';

  @override
  String get merchantCode => 'رمز التاجر';

  @override
  String get home => 'الرئيسية';

  @override
  String get offers => 'العروض';

  @override
  String get customers => 'الزبائن';

  @override
  String get products => 'المنتجات';

  @override
  String get receipts => 'الإيصالات';

  @override
  String get copiedMerchantCode => 'تم نسخ رمز التاجر';

  @override
  String get close => 'إغلاق';

  @override
  String get merchantLoginTitle => 'دخول التاجر';

  @override
  String get enterEmailPassword => 'يرجى إدخال البريد الإلكتروني وكلمة المرور';

  @override
  String get loginFailed => 'فشل تسجيل الدخول';

  @override
  String get loginButton => 'دخول';

  @override
  String get createMerchantAccount => 'إنشاء حساب تاجر جديد';

  @override
  String get forgotPassword => 'نسيت كلمة المرور؟';

  @override
  String get sendResetLink => 'سيتم إرسال رابط استرجاع كلمة المرور';

  @override
  String get supabaseSessionFailed =>
      'تعذّر إنشاء جلسة Supabase، لن تعمل بعض الميزات';

  @override
  String get emailLabel => 'البريد الإلكتروني';

  @override
  String get passwordLabel => 'كلمة المرور';

  @override
  String get registerTitle => 'تسجيل تاجر';

  @override
  String get fillAllFields => 'يرجى تعبئة جميع الحقول المطلوبة';

  @override
  String get passwordsNotMatch => 'كلمتا المرور غير متطابقتين';

  @override
  String get invalidEmail => 'يرجى إدخال بريد إلكتروني صحيح';

  @override
  String get pickStoreLocation => 'يرجى اختيار موقع المحل على الخريطة';

  @override
  String get emailAlreadyUsed => 'هذا البريد مسجل مسبقاً، استخدم تسجيل الدخول.';

  @override
  String get accountCreatedSuccess => 'تم إنشاء الحساب بنجاح!';

  @override
  String get accountCreateFailed => 'فشل إنشاء الحساب';

  @override
  String get unexpectedError => 'حدث خطأ غير متوقع';

  @override
  String get confirmPasswordLabel => 'تأكيد كلمة المرور';

  @override
  String get storeNameLabel => 'اسم المحل';

  @override
  String get phoneLabel => 'رقم الهاتف';

  @override
  String get activityTypeLabel => 'نوع النشاط';

  @override
  String get otherActivityLabel => 'نشاط آخر';

  @override
  String get locationLabel => 'الموقع';

  @override
  String get registerButton => 'إنشاء حساب';

  @override
  String get selectLocationButton => 'اختيار الموقع';

  @override
  String get getAutoLocationButton => 'تحديد موقعي تلقائياً';

  @override
  String get locatingMessage => 'جاري تحديد الموقع...';

  @override
  String get manageOffersTitle => 'إدارة العروض';

  @override
  String get addNewOffer => 'إضافة عرض جديد';

  @override
  String get migrateOldOffers => 'مزامنة/ترحيل العروض القديمة';

  @override
  String get offerIdMissing => 'رقم العرض غير موجود!';

  @override
  String get offerDeleted => 'تم حذف العرض بنجاح.';

  @override
  String get offerDeleteFailed => 'فشل حذف العرض';

  @override
  String get offerStatusChanged => 'تم تغيير حالة العرض بنجاح.';

  @override
  String get offerStatusChangeFailed => 'فشل تغيير حالة العرض';

  @override
  String get autoMigrationFailed => 'فشل الترحيل التلقائي';

  @override
  String offersMigratedCount(int count) {
    return 'تم ترحيل $count عرض من Firestore';
  }

  @override
  String get productsScreenTitle => 'منتجات المحل';

  @override
  String get importCsv => 'استيراد CSV';

  @override
  String get csvTemplate => 'نموذج';

  @override
  String get exportCsv => 'تصدير CSV';

  @override
  String get refresh => 'تحديث';

  @override
  String get searchHintProducts => 'بحث سريع / غامض عن اسم المنتج...';

  @override
  String get debugProductsBanner =>
      '[DEBUG] شاشة المنتجات (يظهر فقط في التطوير)';

  @override
  String get noProductsYet => 'لا توجد منتجات بعد';

  @override
  String get addProductManual => 'إضافة منتج يدوي';

  @override
  String get addProduct => 'إضافة';

  @override
  String get addProductTitle => 'إضافة منتج جديد';

  @override
  String get productNameLabel => 'اسم المنتج';

  @override
  String get productPointsLabel => 'النقاط للمنتج';

  @override
  String get basisSelectionLabel => 'النقاط بناء على:';

  @override
  String get basisProductDirect => 'المنتج مباشرة';

  @override
  String get basisPrice => 'السعر';

  @override
  String get basisQuantity => 'الكمية';

  @override
  String get basisOperation => 'عملية الشراء';

  @override
  String get cancel => 'إلغاء';

  @override
  String get supabaseSessionMissing =>
      'جلسة Supabase غير متوفرة، أعد تسجيل الدخول';

  @override
  String get productAdded => 'تمت إضافة المنتج';

  @override
  String get productAddFailed => 'فشل الإضافة';

  @override
  String get editProductTitle => 'تعديل المنتج';

  @override
  String get productNameImmutable => 'اسم المنتج (غير قابل للتعديل)';

  @override
  String get productUpdated => 'تم التحديث';

  @override
  String get productUpdateFailed => 'فشل التحديث';

  @override
  String get emptyResults => 'لا نتائج';

  @override
  String get clear => 'مسح';

  @override
  String searchResultsCount(int count) {
    return 'نتائج البحث: $count';
  }

  @override
  String get tableMissingTitle => 'الجدول غير موجود';

  @override
  String get tableMissingMessage =>
      'أنشئ جدول merchant_products في Supabase ثم أعد فتح الصفحة.';

  @override
  String get recheck => 'إعادة الفحص';

  @override
  String get csvFileEmpty => 'ملف فارغ';

  @override
  String get missingName => 'اسم مفقود';

  @override
  String get invalidPoints => 'نقاط غير صالحة';

  @override
  String get noProcessableRows => 'لا صفوف قابلة للمعالجة';

  @override
  String get parseFailed => 'فشل التحليل';

  @override
  String get importReviewTitle => 'مراجعة الاستيراد';

  @override
  String validInvalidCount(int valid, int invalid) {
    return 'صالحة: $valid | أخطاء: $invalid';
  }

  @override
  String get skipDuplicateProducts => 'تخطي المنتجات ذات الاسم المكرر';

  @override
  String get importingEllipsis => 'جارٍ الإدراج...';

  @override
  String importProductsButton(int count) {
    return 'استيراد $count';
  }

  @override
  String get sessionMissing => 'جلسة مفقودة';

  @override
  String get noNewItemsAfterDuplicates => 'لا عناصر جديدة بعد تطبيق المكررات';

  @override
  String insertedProductsResult(int inserted, int rejected) {
    return 'تم إدراج $inserted منتجاً (مرفوض $rejected)';
  }

  @override
  String get importFailed => 'فشل الاستيراد';

  @override
  String get csvExportCreated => 'تم إنشاء CSV - انسخ النص';

  @override
  String get exportFailed => 'فشل التصدير';

  @override
  String priceRuleFormat(String value, int points) {
    return 'السعر $value = $points نقطة';
  }

  @override
  String quantityRuleFormat(String value, int points) {
    return 'الكمية $value = $points نقطة';
  }

  @override
  String operationRuleFormat(String value, int points) {
    return 'عدد العمليات $value = $points نقطة';
  }

  @override
  String pointsRuleFormat(int points) {
    return 'النقاط: $points';
  }

  @override
  String get editPointsTooltip => 'تعديل النقاط';

  @override
  String get ruleValuePriceLabel => 'السعر المحدد';

  @override
  String get ruleValueQuantityLabel => 'الكمية المحددة';

  @override
  String get ruleValueOperationLabel => 'عدد العمليات';

  @override
  String get rulePointsLabel => 'عدد النقاط';

  @override
  String get ruleExamplePrice => 'مثال: 10 دينار = 1 نقطة';

  @override
  String get ruleExampleQuantity => 'مثال: 5 قطع = 2 نقطة';

  @override
  String get ruleExampleOperation => 'مثال: 1 عملية = 3 نقاط';

  @override
  String similarityFormat(String sim) {
    return 'تشابه: $sim';
  }

  @override
  String get noOffersYet => 'لا توجد عروض بعد';

  @override
  String get noMatchingResults => 'لا نتائج مطابقة';

  @override
  String get notSpecified => 'غير محدد';

  @override
  String get storeNameUnavailable => 'اسم المحل غير متوفر';

  @override
  String get noTitle => 'بلا عنوان';

  @override
  String get noDescription => 'لا يوجد وصف';

  @override
  String get deliveryAvailable => 'خدمة التوصيل متوفرة';

  @override
  String get deliveryNotAvailable => 'خدمة التوصيل غير متوفرة';

  @override
  String get endsAtPrefix => 'ينتهي في:';

  @override
  String get activeLabel => 'مفعل';

  @override
  String get manageCustomersTitle => 'إدارة الزبائن';

  @override
  String get loadingCustomers => 'جاري تحميل الزبائن...';

  @override
  String get customersFetchError => 'فشل جلب الزبائن';

  @override
  String get noCustomersYet => 'لا يوجد زبائن بعد';

  @override
  String pointsLabel(int points) {
    return 'النقاط: $points';
  }

  @override
  String get customerDetailsTitle => 'تفاصيل الزبون';

  @override
  String get customerNotFound => 'الزبون غير موجود';

  @override
  String totalPoints(int points) {
    return 'مجموع النقاط: $points';
  }

  @override
  String get purchaseHistory => 'تاريخه الشرائي';

  @override
  String get redeemedRewards => 'الجوائز المستلمة';

  @override
  String get receiptsHistory => 'سجل الفواتير';

  @override
  String get customerOffers => 'عروض الزبون';

  @override
  String get noPurchasesYet => 'لا يوجد مشتريات بعد';

  @override
  String get noRewardsYet => 'لا يوجد جوائز مستلمة';

  @override
  String get noReceiptsYet => 'لا توجد فواتير بعد';

  @override
  String get noOffersForCustomer => 'لا يوجد عروض لهذا الزبون';

  @override
  String orderNumber(String id) {
    return 'طلب رقم: $id';
  }

  @override
  String invoiceNumber(String id) {
    return 'فاتورة رقم: $id';
  }

  @override
  String dateLabel(String date) {
    return 'التاريخ: $date';
  }

  @override
  String amountLabel(String amount) {
    return 'المبلغ: $amount';
  }

  @override
  String get supportOffer => 'دعم العرض';

  @override
  String get offerSupported => 'تم دعم العرض';

  @override
  String get customerReportsTitle => 'بلاغات الزبائن';

  @override
  String get unknownDate => 'تاريخ غير معروف';

  @override
  String reportDate(String date) {
    return 'تاريخ البلاغ: $date';
  }

  @override
  String get noMessage => 'لا يوجد نص';

  @override
  String get receiptsLogTitle => 'سجل الفواتير';

  @override
  String get statusPending => 'قيد المراجعة';

  @override
  String get statusAccepted => 'مقبولة';

  @override
  String get statusRejected => 'مرفوضة';

  @override
  String statusLabel(String value) {
    return 'الحالة: $value';
  }

  @override
  String invoiceNumberShort(String num) {
    return 'فاتورة رقم: $num';
  }

  @override
  String createdAtLabel(String date) {
    return 'التاريخ: $date';
  }

  @override
  String quantityPrice(int qty, String price) {
    return 'الكمية: $qty | السعر: $price';
  }

  @override
  String get noProductDetails => 'لا توجد تفاصيل منتجات';

  @override
  String get noActiveRewards => 'لا توجد جوائز مفعلة';

  @override
  String get noRedeemedRewards => 'لا توجد جوائز تم استبدالها';

  @override
  String get manageRewardsTitle => 'إدارة الجوائز';

  @override
  String get activeRewardsTab => 'الجوائز المفعلة';

  @override
  String get redeemedRewardsTab => 'سجل الاستبدال';

  @override
  String get addNewReward => 'إضافة جائزة جديدة';

  @override
  String get syncRewards => 'مزامنة جوائز Firestore';

  @override
  String get scanQrReward => 'مسح QR لاسترداد';

  @override
  String get syncingDone => 'تمت المزامنة';

  @override
  String get syncFailed => 'فشل المزامنة';

  @override
  String get loginFirstSupabase =>
      'سجّل الدخول أولاً (جلسة Supabase غير موجودة)';

  @override
  String get deleteRewardError => 'فشل حذف الجائزة';

  @override
  String get rewardNoTitle => 'جائزة بدون عنوان';

  @override
  String get qrRewardTitle => 'QR لاستلام الجائزة';

  @override
  String get closeLower => 'إغلاق';

  @override
  String get unknownDateShort => 'تاريخ غير معروف';

  @override
  String rewardTitleLabel(String title) {
    return 'جائزة: $title';
  }

  @override
  String customerLabel(String name) {
    return 'زبون: $name';
  }

  @override
  String get registerNewMerchantTitle => 'تسجيل تاجر جديد';

  @override
  String get activityOtherPrompt => 'حدد نشاط آخر';

  @override
  String get pickStoreOnMap => 'حدد موقع المحل على الخريطة';

  @override
  String get storeLocationPicked => 'تم اختيار الموقع';

  @override
  String get autoLocating => 'جارٍ تحديد الموقع...';

  @override
  String get autoLocateButton => 'تحديد الموقع تلقائياً';

  @override
  String get submitRegister => 'تسجيل';

  @override
  String get locationServiceDisabled => 'خدمة الموقع معطلة';

  @override
  String get locationPermissionDenied => 'تم رفض إذن الموقع';

  @override
  String get locationPermissionDeniedForever =>
      'تم رفض إذن الموقع نهائياً. افتح الإعدادات.';

  @override
  String get locationAutoCaptured => 'تم التقاط الموقع تلقائياً';

  @override
  String locationFailed(String error) {
    return 'فشل جلب الموقع: $error';
  }

  @override
  String get completeProfileTitle => 'إكمال الملف الشخصي';

  @override
  String get mustLoginFirst => 'يجب تسجيل الدخول أولاً';

  @override
  String get profileSavedSuccess => 'تم حفظ الملف بنجاح!';

  @override
  String genericErrorWithMessage(String message) {
    return 'خطأ: $message';
  }

  @override
  String get requiredField => 'الحقل مطلوب';

  @override
  String get save => 'حفظ';

  @override
  String get pointsSystemTitle => 'نظام النقاط';

  @override
  String get pointsMechanismTitle => 'آلية الحساب';

  @override
  String get pointsSimplifiedDescription =>
      'النظام مبسّط: إجمالي النقاط = مجموع (النقاط المحددة للمنتج × الكمية في الفاتورة). لا إعدادات إضافية حالياً.';

  @override
  String get pointsSimplificationBenefitsTitle => 'مزايا التبسيط:';

  @override
  String get pointsSimplificationBenefitsBullet =>
      '• أداء أسرع وأسهل للفهم\n• تجنب التعقيد للحالات الخاصة\n• تغيير نقاط المنتج يُطبق فوراً بدون أثر رجعي إلا إذا طُبق يدوياً';

  @override
  String get addOfferTitle => 'إضافة عرض جديد';

  @override
  String get offerImagePlaceholderOptional => 'صورة العرض (اختيارية)';

  @override
  String get pickFromGallery => 'من الاستوديو';

  @override
  String get captureWithCamera => 'التقاط بالكاميرا';

  @override
  String get imageOptionalNote =>
      'يمكن ترك الصورة فارغة، أو اختيار/التقاط صورة جديدة.';

  @override
  String get offerTitleLabel => 'عنوان العرض';

  @override
  String get offerDescriptionLabel => 'وصف العرض';

  @override
  String get originalPriceLabel => 'السعر الأصلي';

  @override
  String get discountPercentageLabel => 'نسبة الخصم (%)';

  @override
  String get discountPercentageInvalid => 'ادخل نسبة بين 1-99';

  @override
  String get startDateLabel => 'تاريخ البدء';

  @override
  String get endDateLabel => 'تاريخ الانتهاء';

  @override
  String get chooseGeneric => 'اختيار';

  @override
  String get pickOfferLocation => 'حدد موقع العرض على الخريطة';

  @override
  String get offerLocationPicked => 'تم اختيار الموقع';

  @override
  String get offerTypeLabel => 'نوع العرض';

  @override
  String get offerTypeDiscount => 'خصم مباشر';

  @override
  String get offerTypeGift => 'هدية مع الشراء';

  @override
  String get offerTypeCoupon => 'كوبون';

  @override
  String get offerTypeLimitedTime => 'عرض لفترة محدودة';

  @override
  String get offerTypeOther => 'آخر...';

  @override
  String get selectStartEndDates => 'الرجاء تحديد تاريخ البدء والانتهاء';

  @override
  String get offerLocationRequired => 'يرجى اختيار موقع العرض على الخريطة';

  @override
  String get offerTypeRequired => 'يرجى اختيار نوع العرض';

  @override
  String get offerAddedSynced => 'تم إضافة العرض ومزامنته';

  @override
  String get offerUpdatedSynced => 'تم تحديث العرض ومزامنته';

  @override
  String imagePickFailed(String error) {
    return 'تعذر التقاط/اختيار الصورة: $error';
  }

  @override
  String savedWithSupabaseWarning(String error) {
    return 'تم الحفظ (تحذير مزامنة Supabase: $error)';
  }

  @override
  String offerEndsAt(String date) {
    return 'ينتهي في: $date';
  }

  @override
  String get active => 'مفعل';

  @override
  String get storeNameNotAvailable => 'اسم المحل غير متوفر';

  @override
  String get cashierScreen => 'شاشة الكاشير';

  @override
  String get reportsAndAnalytics => 'التقارير والتحليلات';

  @override
  String get community => 'المجتمع';

  @override
  String get activityCafe => 'مقهى';

  @override
  String get activityRestaurant => 'مطعم';

  @override
  String get activityClothingStore => 'متجر ملابس';

  @override
  String get activityPharmacy => 'صيدلية';

  @override
  String get activitySupermarket => 'سوبرماركت';

  @override
  String get activityOther => 'آخر';
}

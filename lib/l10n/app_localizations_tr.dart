// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appTitle => 'Tüccar Uygulaması';

  @override
  String get login => 'Giriş';

  @override
  String get logout => 'Çıkış';

  @override
  String get settings => 'Ayarlar';

  @override
  String get language => 'Dil';

  @override
  String get noMerchantCode => 'Kod yok';

  @override
  String get copied => 'Kopyalandı';

  @override
  String get merchantCode => 'Tüccar Kodu';

  @override
  String get home => 'Ana Sayfa';

  @override
  String get offers => 'Teklifler';

  @override
  String get customers => 'Müşteriler';

  @override
  String get products => 'Ürünler';

  @override
  String get receipts => 'Fişler';

  @override
  String get copiedMerchantCode => 'Tüccar kodu kopyalandı';

  @override
  String get close => 'Kapat';

  @override
  String get merchantLoginTitle => 'Tüccar Girişi';

  @override
  String get enterEmailPassword => 'Lütfen e-posta ve şifre girin';

  @override
  String get loginFailed => 'Giriş başarısız';

  @override
  String get loginButton => 'Giriş';

  @override
  String get createMerchantAccount => 'Yeni hesap oluştur';

  @override
  String get forgotPassword => 'Şifreyi mi unuttun?';

  @override
  String get sendResetLink => 'Sıfırlama bağlantısı gönderilecek';

  @override
  String get supabaseSessionFailed => 'Supabase oturumu oluşturulamadı';

  @override
  String get emailLabel => 'E-posta';

  @override
  String get passwordLabel => 'Şifre';

  @override
  String get registerTitle => 'Tüccar Kaydı';

  @override
  String get fillAllFields => 'Tüm alanları doldurun';

  @override
  String get passwordsNotMatch => 'Şifreler uyuşmuyor';

  @override
  String get invalidEmail => 'Geçersiz e-posta';

  @override
  String get pickStoreLocation => 'Haritada mağaza konumu seçin';

  @override
  String get emailAlreadyUsed => 'E-posta zaten kayıtlı, giriş yapın.';

  @override
  String get accountCreatedSuccess => 'Hesap başarıyla oluşturuldu!';

  @override
  String get accountCreateFailed => 'Hesap oluşturma başarısız';

  @override
  String get unexpectedError => 'Beklenmeyen hata';

  @override
  String get confirmPasswordLabel => 'Şifreyi Onayla';

  @override
  String get storeNameLabel => 'Mağaza Adı';

  @override
  String get phoneLabel => 'Telefon';

  @override
  String get activityTypeLabel => 'Faaliyet Türü';

  @override
  String get otherActivityLabel => 'Diğer';

  @override
  String get locationLabel => 'Konum';

  @override
  String get registerButton => 'Kayıt Ol';

  @override
  String get selectLocationButton => 'Konum seç';

  @override
  String get getAutoLocationButton => 'Otomatik konum';

  @override
  String get locatingMessage => 'Konum alınıyor...';

  @override
  String get manageOffersTitle => 'Teklifleri Yönet';

  @override
  String get addNewOffer => 'Yeni teklif';

  @override
  String get migrateOldOffers => 'Eski teklifleri taşı';

  @override
  String get offerIdMissing => 'Teklif kimliği yok!';

  @override
  String get offerDeleted => 'Teklif silindi.';

  @override
  String get offerDeleteFailed => 'Silme başarısız';

  @override
  String get offerStatusChanged => 'Teklif durumu değişti.';

  @override
  String get offerStatusChangeFailed => 'Durum değişimi başarısız';

  @override
  String get autoMigrationFailed => 'Otomatik taşıma başarısız';

  @override
  String offersMigratedCount(int count) {
    return 'Firestore\'dan $count teklif taşındı';
  }

  @override
  String get productsScreenTitle => 'Mağaza Ürünleri';

  @override
  String get importCsv => 'CSV İçe Aktar';

  @override
  String get csvTemplate => 'Şablon';

  @override
  String get exportCsv => 'CSV Dışa Aktar';

  @override
  String get refresh => 'Yenile';

  @override
  String get searchHintProducts => 'Hızlı / bulanık ürün adı...';

  @override
  String get debugProductsBanner => '[DEBUG] Ürün ekranı';

  @override
  String get noProductsYet => 'Henüz ürün yok';

  @override
  String get addProductManual => 'Manuel ürün ekle';

  @override
  String get addProduct => 'Ekle';

  @override
  String get addProductTitle => 'Yeni Ürün';

  @override
  String get productNameLabel => 'Ürün Adı';

  @override
  String get productPointsLabel => 'Ürün puanı';

  @override
  String get basisSelectionLabel => 'Puan temeli:';

  @override
  String get basisProductDirect => 'Doğrudan ürün';

  @override
  String get basisPrice => 'Fiyat';

  @override
  String get basisQuantity => 'Miktar';

  @override
  String get basisOperation => 'Alım işlemi';

  @override
  String get cancel => 'İptal';

  @override
  String get supabaseSessionMissing => 'Supabase oturumu yok';

  @override
  String get productAdded => 'Ürün eklendi';

  @override
  String get productAddFailed => 'Ekleme başarısız';

  @override
  String get editProductTitle => 'Ürünü Düzenle';

  @override
  String get productNameImmutable => 'İsim (değişmez)';

  @override
  String get productUpdated => 'Güncellendi';

  @override
  String get productUpdateFailed => 'Güncelleme başarısız';

  @override
  String get emptyResults => 'Sonuç yok';

  @override
  String get clear => 'Temizle';

  @override
  String searchResultsCount(int count) {
    return 'Sonuç: $count';
  }

  @override
  String get tableMissingTitle => 'Tablo eksik';

  @override
  String get tableMissingMessage =>
      'Supabase\'de merchant_products tablosu oluşturun ve yeniden açın.';

  @override
  String get recheck => 'Tekrar kontrol';

  @override
  String get csvFileEmpty => 'Dosya boş';

  @override
  String get missingName => 'İsim eksik';

  @override
  String get invalidPoints => 'Geçersiz puan';

  @override
  String get noProcessableRows => 'İşlenecek satır yok';

  @override
  String get parseFailed => 'Ayrıştırma başarısız';

  @override
  String get importReviewTitle => 'İçe aktarma inceleme';

  @override
  String validInvalidCount(int valid, int invalid) {
    return 'Geçerli: $valid | Hata: $invalid';
  }

  @override
  String get skipDuplicateProducts => 'Aynı isimlileri atla';

  @override
  String get importingEllipsis => 'İçe aktarılıyor...';

  @override
  String importProductsButton(int count) {
    return 'İçe aktar $count';
  }

  @override
  String get sessionMissing => 'Oturum yok';

  @override
  String get noNewItemsAfterDuplicates => 'Kopyalardan sonra yeni yok';

  @override
  String insertedProductsResult(int inserted, int rejected) {
    return 'Eklendi $inserted (Reddedildi $rejected)';
  }

  @override
  String get importFailed => 'İçe aktarma başarısız';

  @override
  String get csvExportCreated => 'CSV oluşturuldu - kopyala';

  @override
  String get exportFailed => 'Dışa aktarma başarısız';

  @override
  String priceRuleFormat(String value, int points) {
    return 'Fiyat $value = $points puan';
  }

  @override
  String quantityRuleFormat(String value, int points) {
    return 'Miktar $value = $points puan';
  }

  @override
  String operationRuleFormat(String value, int points) {
    return 'İşlemler $value = $points puan';
  }

  @override
  String pointsRuleFormat(int points) {
    return 'Puan: $points';
  }

  @override
  String get editPointsTooltip => 'Puan düzenle';

  @override
  String get ruleValuePriceLabel => 'Hedef fiyat';

  @override
  String get ruleValueQuantityLabel => 'Hedef miktar';

  @override
  String get ruleValueOperationLabel => 'İşlem sayısı';

  @override
  String get rulePointsLabel => 'Puan';

  @override
  String get ruleExamplePrice => 'Örn: 10 fiyat = 1 puan';

  @override
  String get ruleExampleQuantity => 'Örn: 5 ad = 2 puan';

  @override
  String get ruleExampleOperation => 'Örn: 1 iş = 3 puan';

  @override
  String similarityFormat(String sim) {
    return 'Benzerlik: $sim';
  }

  @override
  String get noOffersYet => 'Henüz teklif yok';

  @override
  String get noMatchingResults => 'Eşleşme yok';

  @override
  String get notSpecified => 'Belirtilmemiş';

  @override
  String get storeNameUnavailable => 'Mağaza adı yok';

  @override
  String get noTitle => 'Başlıksız';

  @override
  String get noDescription => 'Açıklama yok';

  @override
  String get deliveryAvailable => 'Teslimat var';

  @override
  String get deliveryNotAvailable => 'Teslimat yok';

  @override
  String get endsAtPrefix => 'Bitiş:';

  @override
  String get activeLabel => 'Aktif';

  @override
  String get manageCustomersTitle => 'Müşterileri Yönet';

  @override
  String get loadingCustomers => 'Müşteriler yükleniyor...';

  @override
  String get customersFetchError => 'Müşteriler alınamadı';

  @override
  String get noCustomersYet => 'Henüz müşteri yok';

  @override
  String pointsLabel(int points) {
    return 'Puan: $points';
  }

  @override
  String get customerDetailsTitle => 'Müşteri Detayları';

  @override
  String get customerNotFound => 'Müşteri bulunamadı';

  @override
  String totalPoints(int points) {
    return 'Toplam puan: $points';
  }

  @override
  String get purchaseHistory => 'Satın alma geçmişi';

  @override
  String get redeemedRewards => 'Kullanılan ödüller';

  @override
  String get receiptsHistory => 'Fiş geçmişi';

  @override
  String get customerOffers => 'Müşteri teklifleri';

  @override
  String get noPurchasesYet => 'Satın alma yok';

  @override
  String get noRewardsYet => 'Ödül yok';

  @override
  String get noReceiptsYet => 'Fiş yok';

  @override
  String get noOffersForCustomer => 'Bu müşteri için teklif yok';

  @override
  String orderNumber(String id) {
    return 'Sipariş #: $id';
  }

  @override
  String invoiceNumber(String id) {
    return 'Fatura #: $id';
  }

  @override
  String dateLabel(String date) {
    return 'Tarih: $date';
  }

  @override
  String amountLabel(String amount) {
    return 'Tutar: $amount';
  }

  @override
  String get supportOffer => 'Teklifi destekle';

  @override
  String get offerSupported => 'Teklif desteklendi';

  @override
  String get customerReportsTitle => 'Müşteri Raporları';

  @override
  String get unknownDate => 'Bilinmeyen tarih';

  @override
  String reportDate(String date) {
    return 'Rapor tarihi: $date';
  }

  @override
  String get noMessage => 'Mesaj yok';

  @override
  String get receiptsLogTitle => 'Fiş geçmişi';

  @override
  String get statusPending => 'İncelemede';

  @override
  String get statusAccepted => 'Kabul';

  @override
  String get statusRejected => 'Reddedildi';

  @override
  String statusLabel(String value) {
    return 'Durum: $value';
  }

  @override
  String invoiceNumberShort(String num) {
    return 'Fiş #: $num';
  }

  @override
  String createdAtLabel(String date) {
    return 'Oluşturuldu: $date';
  }

  @override
  String quantityPrice(int qty, String price) {
    return 'Adet: $qty | Fiyat: $price';
  }

  @override
  String get noProductDetails => 'Ürün detayı yok';

  @override
  String get noActiveRewards => 'Aktif ödül yok';

  @override
  String get noRedeemedRewards => 'Kullanılan ödül yok';

  @override
  String get manageRewardsTitle => 'Ödülleri Yönet';

  @override
  String get activeRewardsTab => 'Aktif';

  @override
  String get redeemedRewardsTab => 'Geçmiş';

  @override
  String get addNewReward => 'Yeni ödül';

  @override
  String get syncRewards => 'Ödülleri senkronize et';

  @override
  String get scanQrReward => 'QR tara';

  @override
  String get syncingDone => 'Senkronize edildi';

  @override
  String get syncFailed => 'Sync başarısız';

  @override
  String get loginFirstSupabase => 'Önce giriş yap (Supabase yok)';

  @override
  String get deleteRewardError => 'Ödül silme başarısız';

  @override
  String get rewardNoTitle => 'Başlıksız ödül';

  @override
  String get qrRewardTitle => 'Ödül QR';

  @override
  String get closeLower => 'Kapat';

  @override
  String get unknownDateShort => 'Bilinmeyen tarih';

  @override
  String rewardTitleLabel(String title) {
    return 'Ödül: $title';
  }

  @override
  String customerLabel(String name) {
    return 'Müşteri: $name';
  }

  @override
  String get registerNewMerchantTitle => 'Yeni Mağaza Kaydı';

  @override
  String get activityOtherPrompt => 'Diğer faaliyeti belirt';

  @override
  String get pickStoreOnMap => 'Haritada konumu seç';

  @override
  String get storeLocationPicked => 'Konum seçildi';

  @override
  String get autoLocating => 'Konum alınıyor...';

  @override
  String get autoLocateButton => 'Oto konum';

  @override
  String get submitRegister => 'Kayıt ol';

  @override
  String get locationServiceDisabled => 'Konum servisi kapalı';

  @override
  String get locationPermissionDenied => 'Konum izni reddedildi';

  @override
  String get locationPermissionDeniedForever =>
      'Konum izni kalıcı reddedildi. Ayarları açın.';

  @override
  String get locationAutoCaptured => 'Konum otomatik alındı';

  @override
  String locationFailed(String error) {
    return 'Konum alınamadı: $error';
  }

  @override
  String get completeProfileTitle => 'Profili Tamamla';

  @override
  String get mustLoginFirst => 'Önce giriş yapmalısın';

  @override
  String get profileSavedSuccess => 'Profil başarıyla kaydedildi!';

  @override
  String genericErrorWithMessage(String message) {
    return 'Hata: $message';
  }

  @override
  String get requiredField => 'Zorunlu alan';

  @override
  String get save => 'Kaydet';

  @override
  String get pointsSystemTitle => 'Puan Sistemi';

  @override
  String get pointsMechanismTitle => 'Hesaplama Mekanizması';

  @override
  String get pointsSimplifiedDescription =>
      'Basitleştirilmiş sistem: toplam puan = toplam(ürün puanı × fişteki miktar). Şimdilik ek ayar yok.';

  @override
  String get pointsSimplificationBenefitsTitle => 'Basitleştirmenin Faydaları:';

  @override
  String get pointsSimplificationBenefitsBullet =>
      '• Daha hızlı performans & anlaşılır\n• Özel durum karmaşıklığını önler\n• Ürün puanı değişimi anında etkili geriye dönük etki yok (manuel hariç)';

  @override
  String get addOfferTitle => 'Yeni teklif';

  @override
  String get offerImagePlaceholderOptional => 'Teklif resmi (opsiyonel)';

  @override
  String get pickFromGallery => 'Galeriden';

  @override
  String get captureWithCamera => 'Kamera ile';

  @override
  String get imageOptionalNote =>
      'Resim boş bırakılabilir veya yeni seçilebilir/çekilebilir.';

  @override
  String get offerTitleLabel => 'Teklif başlığı';

  @override
  String get offerDescriptionLabel => 'Teklif açıklaması';

  @override
  String get originalPriceLabel => 'Orijinal fiyat';

  @override
  String get discountPercentageLabel => 'İndirim (%)';

  @override
  String get discountPercentageInvalid => '1-99 arası girin';

  @override
  String get startDateLabel => 'Başlangıç tarihi';

  @override
  String get endDateLabel => 'Bitiş tarihi';

  @override
  String get chooseGeneric => 'Seç';

  @override
  String get pickOfferLocation => 'Haritada teklif konumu seç';

  @override
  String get offerLocationPicked => 'Konum seçildi';

  @override
  String get offerTypeLabel => 'Teklif türü';

  @override
  String get offerTypeDiscount => 'Doğrudan indirim';

  @override
  String get offerTypeGift => 'Alışverişe hediye';

  @override
  String get offerTypeCoupon => 'Kupon';

  @override
  String get offerTypeLimitedTime => 'Süreli teklif';

  @override
  String get offerTypeOther => 'Diğer...';

  @override
  String get selectStartEndDates =>
      'Lütfen başlangıç ve bitiş tarihlerini seçin';

  @override
  String get offerLocationRequired => 'Lütfen teklif konumunu seçin';

  @override
  String get offerTypeRequired => 'Lütfen teklif türünü seçin';

  @override
  String get offerAddedSynced => 'Teklif eklendi & senkron';

  @override
  String get offerUpdatedSynced => 'Teklif güncellendi & senkron';

  @override
  String imagePickFailed(String error) {
    return 'Resim seçilemedi: $error';
  }

  @override
  String savedWithSupabaseWarning(String error) {
    return 'Kaydedildi (Supabase uyarısı: $error)';
  }

  @override
  String offerEndsAt(String date) {
    return 'Biter: $date';
  }

  @override
  String get active => 'Aktif';

  @override
  String get storeNameNotAvailable => 'Mağaza adı mevcut değil';
}

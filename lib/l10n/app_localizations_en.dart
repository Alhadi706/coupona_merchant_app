// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Merchant App';

  @override
  String get login => 'Login';

  @override
  String get logout => 'Logout';

  @override
  String get settings => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get noMerchantCode => 'No code';

  @override
  String get copied => 'Copied';

  @override
  String get merchantCode => 'Merchant Code';

  @override
  String get home => 'Home';

  @override
  String get offers => 'Offers';

  @override
  String get customers => 'Customers';

  @override
  String get products => 'Products';

  @override
  String get receipts => 'Receipts';

  @override
  String get copiedMerchantCode => 'Merchant code copied';

  @override
  String get close => 'Close';

  @override
  String get merchantLoginTitle => 'Merchant Login';

  @override
  String get enterEmailPassword => 'Please enter email and password';

  @override
  String get loginFailed => 'Login failed';

  @override
  String get loginButton => 'Login';

  @override
  String get createMerchantAccount => 'Create new merchant account';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get sendResetLink => 'Reset link will be sent';

  @override
  String get supabaseSessionFailed =>
      'Could not create Supabase session. Some features may not work';

  @override
  String get emailLabel => 'Email';

  @override
  String get passwordLabel => 'Password';

  @override
  String get registerTitle => 'Merchant Registration';

  @override
  String get fillAllFields => 'Please fill all required fields';

  @override
  String get passwordsNotMatch => 'Passwords do not match';

  @override
  String get invalidEmail => 'Please enter a valid email';

  @override
  String get pickStoreLocation => 'Please select store location on map';

  @override
  String get emailAlreadyUsed => 'Email already registered, use login.';

  @override
  String get accountCreatedSuccess => 'Account created successfully!';

  @override
  String get accountCreateFailed => 'Account creation failed';

  @override
  String get unexpectedError => 'Unexpected error occurred';

  @override
  String get confirmPasswordLabel => 'Confirm Password';

  @override
  String get storeNameLabel => 'Store Name';

  @override
  String get phoneLabel => 'Phone';

  @override
  String get activityTypeLabel => 'Activity Type';

  @override
  String get otherActivityLabel => 'Other Activity';

  @override
  String get locationLabel => 'Location';

  @override
  String get registerButton => 'Register';

  @override
  String get selectLocationButton => 'Select Location';

  @override
  String get getAutoLocationButton => 'Get auto location';

  @override
  String get locatingMessage => 'Locating...';

  @override
  String get manageOffersTitle => 'Manage Offers';

  @override
  String get addNewOffer => 'Add New Offer';

  @override
  String get migrateOldOffers => 'Sync/Migrate old offers';

  @override
  String get offerIdMissing => 'Offer ID missing!';

  @override
  String get offerDeleted => 'Offer deleted successfully.';

  @override
  String get offerDeleteFailed => 'Failed to delete offer';

  @override
  String get offerStatusChanged => 'Offer status changed successfully.';

  @override
  String get offerStatusChangeFailed => 'Failed to change offer status';

  @override
  String get autoMigrationFailed => 'Auto migration failed';

  @override
  String offersMigratedCount(int count) {
    return 'Migrated $count offers from Firestore';
  }

  @override
  String get productsScreenTitle => 'Store Products';

  @override
  String get importCsv => 'Import CSV';

  @override
  String get csvTemplate => 'Template';

  @override
  String get exportCsv => 'Export CSV';

  @override
  String get refresh => 'Refresh';

  @override
  String get searchHintProducts => 'Fast / fuzzy search product name...';

  @override
  String get debugProductsBanner => '[DEBUG] Products screen (dev only)';

  @override
  String get noProductsYet => 'No products yet';

  @override
  String get addProductManual => 'Add product manually';

  @override
  String get addProduct => 'Add';

  @override
  String get addProductTitle => 'Add New Product';

  @override
  String get productNameLabel => 'Product Name';

  @override
  String get productPointsLabel => 'Points for product';

  @override
  String get basisSelectionLabel => 'Points based on:';

  @override
  String get basisProductDirect => 'Direct product';

  @override
  String get basisPrice => 'Price';

  @override
  String get basisQuantity => 'Quantity';

  @override
  String get basisOperation => 'Purchase operation';

  @override
  String get cancel => 'Cancel';

  @override
  String get supabaseSessionMissing =>
      'Supabase session unavailable, login again';

  @override
  String get productAdded => 'Product added';

  @override
  String get productAddFailed => 'Add failed';

  @override
  String get editProductTitle => 'Edit Product';

  @override
  String get productNameImmutable => 'Product name (immutable)';

  @override
  String get productUpdated => 'Updated';

  @override
  String get productUpdateFailed => 'Update failed';

  @override
  String get emptyResults => 'No results';

  @override
  String get clear => 'Clear';

  @override
  String searchResultsCount(int count) {
    return 'Search results: $count';
  }

  @override
  String get tableMissingTitle => 'Table missing';

  @override
  String get tableMissingMessage =>
      'Create merchant_products table in Supabase then reopen page.';

  @override
  String get recheck => 'Recheck';

  @override
  String get csvFileEmpty => 'Empty file';

  @override
  String get missingName => 'Missing name';

  @override
  String get invalidPoints => 'Invalid points';

  @override
  String get noProcessableRows => 'No processable rows';

  @override
  String get parseFailed => 'Parsing failed';

  @override
  String get importReviewTitle => 'Import Review';

  @override
  String validInvalidCount(int valid, int invalid) {
    return 'Valid: $valid | Errors: $invalid';
  }

  @override
  String get skipDuplicateProducts => 'Skip duplicate product names';

  @override
  String get importingEllipsis => 'Importing...';

  @override
  String importProductsButton(int count) {
    return 'Import $count';
  }

  @override
  String get sessionMissing => 'Session missing';

  @override
  String get noNewItemsAfterDuplicates =>
      'No new items after duplicates filter';

  @override
  String insertedProductsResult(int inserted, int rejected) {
    return 'Inserted $inserted products (Rejected $rejected)';
  }

  @override
  String get importFailed => 'Import failed';

  @override
  String get csvExportCreated => 'CSV created - copy the text';

  @override
  String get exportFailed => 'Export failed';

  @override
  String priceRuleFormat(String value, int points) {
    return 'Price $value = $points pts';
  }

  @override
  String quantityRuleFormat(String value, int points) {
    return 'Quantity $value = $points pts';
  }

  @override
  String operationRuleFormat(String value, int points) {
    return 'Operations $value = $points pts';
  }

  @override
  String pointsRuleFormat(int points) {
    return 'Points: $points';
  }

  @override
  String get editPointsTooltip => 'Edit points';

  @override
  String get ruleValuePriceLabel => 'Target price';

  @override
  String get ruleValueQuantityLabel => 'Target quantity';

  @override
  String get ruleValueOperationLabel => 'Operations count';

  @override
  String get rulePointsLabel => 'Points';

  @override
  String get ruleExamplePrice => 'Example: 10 price = 1 pt';

  @override
  String get ruleExampleQuantity => 'Example: 5 pcs = 2 pts';

  @override
  String get ruleExampleOperation => 'Example: 1 op = 3 pts';

  @override
  String similarityFormat(String sim) {
    return 'Similarity: $sim';
  }

  @override
  String get noOffersYet => 'No offers yet';

  @override
  String get noMatchingResults => 'No matching results';

  @override
  String get notSpecified => 'Not specified';

  @override
  String get storeNameUnavailable => 'Store name unavailable';

  @override
  String get noTitle => 'No title';

  @override
  String get noDescription => 'No description';

  @override
  String get deliveryAvailable => 'Delivery available';

  @override
  String get deliveryNotAvailable => 'Delivery not available';

  @override
  String get endsAtPrefix => 'Ends at:';

  @override
  String get activeLabel => 'Active';

  @override
  String get manageCustomersTitle => 'Manage Customers';

  @override
  String get loadingCustomers => 'Loading customers...';

  @override
  String get customersFetchError => 'Failed to load customers';

  @override
  String get noCustomersYet => 'No customers yet';

  @override
  String pointsLabel(int points) {
    return 'Points: $points';
  }

  @override
  String get customerDetailsTitle => 'Customer Details';

  @override
  String get customerNotFound => 'Customer not found';

  @override
  String totalPoints(int points) {
    return 'Total points: $points';
  }

  @override
  String get purchaseHistory => 'Purchase History';

  @override
  String get redeemedRewards => 'Redeemed Rewards';

  @override
  String get receiptsHistory => 'Receipts History';

  @override
  String get customerOffers => 'Customer Offers';

  @override
  String get noPurchasesYet => 'No purchases yet';

  @override
  String get noRewardsYet => 'No redeemed rewards';

  @override
  String get noReceiptsYet => 'No receipts yet';

  @override
  String get noOffersForCustomer => 'No offers for this customer';

  @override
  String orderNumber(String id) {
    return 'Order #: $id';
  }

  @override
  String invoiceNumber(String id) {
    return 'Invoice #: $id';
  }

  @override
  String dateLabel(String date) {
    return 'Date: $date';
  }

  @override
  String amountLabel(String amount) {
    return 'Amount: $amount';
  }

  @override
  String get supportOffer => 'Support offer';

  @override
  String get offerSupported => 'Offer supported';

  @override
  String get customerReportsTitle => 'Customer Reports';

  @override
  String get unknownDate => 'Unknown date';

  @override
  String reportDate(String date) {
    return 'Report date: $date';
  }

  @override
  String get noMessage => 'No message';

  @override
  String get receiptsLogTitle => 'Receipts Log';

  @override
  String get statusPending => 'Pending';

  @override
  String get statusAccepted => 'Accepted';

  @override
  String get statusRejected => 'Rejected';

  @override
  String statusLabel(String value) {
    return 'Status: $value';
  }

  @override
  String invoiceNumberShort(String num) {
    return 'Receipt #: $num';
  }

  @override
  String createdAtLabel(String date) {
    return 'Created: $date';
  }

  @override
  String quantityPrice(int qty, String price) {
    return 'Qty: $qty | Price: $price';
  }

  @override
  String get noProductDetails => 'No product details';

  @override
  String get noActiveRewards => 'No active rewards';

  @override
  String get noRedeemedRewards => 'No redeemed rewards';

  @override
  String get manageRewardsTitle => 'Manage Rewards';

  @override
  String get activeRewardsTab => 'Active Rewards';

  @override
  String get redeemedRewardsTab => 'Redeemed History';

  @override
  String get addNewReward => 'Add new reward';

  @override
  String get syncRewards => 'Sync Firestore rewards';

  @override
  String get scanQrReward => 'Scan QR to redeem';

  @override
  String get syncingDone => 'Synced';

  @override
  String get syncFailed => 'Sync failed';

  @override
  String get loginFirstSupabase => 'Login first (Supabase session missing)';

  @override
  String get deleteRewardError => 'Failed to delete reward';

  @override
  String get rewardNoTitle => 'Untitled reward';

  @override
  String get qrRewardTitle => 'QR to redeem reward';

  @override
  String get closeLower => 'Close';

  @override
  String get unknownDateShort => 'Unknown date';

  @override
  String rewardTitleLabel(String title) {
    return 'Reward: $title';
  }

  @override
  String customerLabel(String name) {
    return 'Customer: $name';
  }

  @override
  String get registerNewMerchantTitle => 'New Merchant Registration';

  @override
  String get activityOtherPrompt => 'Specify other activity';

  @override
  String get pickStoreOnMap => 'Pick store location on map';

  @override
  String get storeLocationPicked => 'Location selected';

  @override
  String get autoLocating => 'Locating...';

  @override
  String get autoLocateButton => 'Auto locate';

  @override
  String get submitRegister => 'Register';

  @override
  String get locationServiceDisabled => 'Location service disabled';

  @override
  String get locationPermissionDenied => 'Location permission denied';

  @override
  String get locationPermissionDeniedForever =>
      'Location permission permanently denied. Open settings.';

  @override
  String get locationAutoCaptured => 'Location captured automatically';

  @override
  String locationFailed(String error) {
    return 'Failed to get location: $error';
  }

  @override
  String get completeProfileTitle => 'Complete Profile';

  @override
  String get mustLoginFirst => 'You must login first';

  @override
  String get profileSavedSuccess => 'Profile saved successfully!';

  @override
  String genericErrorWithMessage(String message) {
    return 'Error: $message';
  }

  @override
  String get requiredField => 'Field is required';

  @override
  String get save => 'Save';

  @override
  String get pointsSystemTitle => 'Points System';

  @override
  String get pointsMechanismTitle => 'Calculation Mechanism';

  @override
  String get pointsSimplifiedDescription =>
      'The system is simplified: total points = sum(product assigned points × quantity in receipt). No extra settings for now.';

  @override
  String get pointsSimplificationBenefitsTitle => 'Simplification Benefits:';

  @override
  String get pointsSimplificationBenefitsBullet =>
      '• Faster performance & easier to understand\n• Avoid special-case complexity\n• Change per-product points instantly without retroactive effect unless manually applied';

  @override
  String get addOfferTitle => 'Add New Offer';

  @override
  String get offerImagePlaceholderOptional => 'Offer image (optional)';

  @override
  String get pickFromGallery => 'From Gallery';

  @override
  String get captureWithCamera => 'Capture with Camera';

  @override
  String get imageOptionalNote =>
      'Image can be left empty or you can pick/capture a new one.';

  @override
  String get offerTitleLabel => 'Offer Title';

  @override
  String get offerDescriptionLabel => 'Offer Description';

  @override
  String get originalPriceLabel => 'Original Price';

  @override
  String get discountPercentageLabel => 'Discount (%)';

  @override
  String get discountPercentageInvalid => 'Enter percentage 1-99';

  @override
  String get startDateLabel => 'Start Date';

  @override
  String get endDateLabel => 'End Date';

  @override
  String get chooseGeneric => 'Choose';

  @override
  String get pickOfferLocation => 'Pick offer location on map';

  @override
  String get offerLocationPicked => 'Location selected';

  @override
  String get offerTypeLabel => 'Offer Type';

  @override
  String get offerTypeDiscount => 'Direct Discount';

  @override
  String get offerTypeGift => 'Gift with Purchase';

  @override
  String get offerTypeCoupon => 'Coupon';

  @override
  String get offerTypeLimitedTime => 'Limited Time Offer';

  @override
  String get offerTypeOther => 'Other...';

  @override
  String get selectStartEndDates => 'Please select start and end dates';

  @override
  String get offerLocationRequired => 'Please pick offer location on map';

  @override
  String get offerTypeRequired => 'Please select offer type';

  @override
  String get offerAddedSynced => 'Offer added & synced';

  @override
  String get offerUpdatedSynced => 'Offer updated & synced';

  @override
  String imagePickFailed(String error) {
    return 'Failed to pick image: $error';
  }

  @override
  String savedWithSupabaseWarning(String error) {
    return 'Saved (Supabase sync warning: $error)';
  }

  @override
  String offerEndsAt(String date) {
    return 'Ends at: $date';
  }

  @override
  String get active => 'Active';

  @override
  String get storeNameNotAvailable => 'Store name not available';
}

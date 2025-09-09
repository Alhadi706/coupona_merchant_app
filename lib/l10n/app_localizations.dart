import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_it.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('it'),
    Locale('tr'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Merchant App'**
  String get appTitle;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @noMerchantCode.
  ///
  /// In en, this message translates to:
  /// **'No code'**
  String get noMerchantCode;

  /// No description provided for @copied.
  ///
  /// In en, this message translates to:
  /// **'Copied'**
  String get copied;

  /// No description provided for @merchantCode.
  ///
  /// In en, this message translates to:
  /// **'Merchant Code'**
  String get merchantCode;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @offers.
  ///
  /// In en, this message translates to:
  /// **'Offers'**
  String get offers;

  /// No description provided for @customers.
  ///
  /// In en, this message translates to:
  /// **'Customers'**
  String get customers;

  /// No description provided for @products.
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get products;

  /// No description provided for @receipts.
  ///
  /// In en, this message translates to:
  /// **'Receipts'**
  String get receipts;

  /// No description provided for @copiedMerchantCode.
  ///
  /// In en, this message translates to:
  /// **'Merchant code copied'**
  String get copiedMerchantCode;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @merchantLoginTitle.
  ///
  /// In en, this message translates to:
  /// **'Merchant Login'**
  String get merchantLoginTitle;

  /// No description provided for @enterEmailPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter email and password'**
  String get enterEmailPassword;

  /// No description provided for @loginFailed.
  ///
  /// In en, this message translates to:
  /// **'Login failed'**
  String get loginFailed;

  /// No description provided for @loginButton.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginButton;

  /// No description provided for @createMerchantAccount.
  ///
  /// In en, this message translates to:
  /// **'Create new merchant account'**
  String get createMerchantAccount;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @sendResetLink.
  ///
  /// In en, this message translates to:
  /// **'Reset link will be sent'**
  String get sendResetLink;

  /// No description provided for @supabaseSessionFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not create Supabase session. Some features may not work'**
  String get supabaseSessionFailed;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @registerTitle.
  ///
  /// In en, this message translates to:
  /// **'Merchant Registration'**
  String get registerTitle;

  /// No description provided for @fillAllFields.
  ///
  /// In en, this message translates to:
  /// **'Please fill all required fields'**
  String get fillAllFields;

  /// No description provided for @passwordsNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsNotMatch;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get invalidEmail;

  /// No description provided for @pickStoreLocation.
  ///
  /// In en, this message translates to:
  /// **'Please select store location on map'**
  String get pickStoreLocation;

  /// No description provided for @emailAlreadyUsed.
  ///
  /// In en, this message translates to:
  /// **'Email already registered, use login.'**
  String get emailAlreadyUsed;

  /// No description provided for @accountCreatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Account created successfully!'**
  String get accountCreatedSuccess;

  /// No description provided for @accountCreateFailed.
  ///
  /// In en, this message translates to:
  /// **'Account creation failed'**
  String get accountCreateFailed;

  /// No description provided for @unexpectedError.
  ///
  /// In en, this message translates to:
  /// **'Unexpected error occurred'**
  String get unexpectedError;

  /// No description provided for @confirmPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPasswordLabel;

  /// No description provided for @storeNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Store Name'**
  String get storeNameLabel;

  /// No description provided for @phoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phoneLabel;

  /// No description provided for @activityTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Activity Type'**
  String get activityTypeLabel;

  /// No description provided for @otherActivityLabel.
  ///
  /// In en, this message translates to:
  /// **'Other Activity'**
  String get otherActivityLabel;

  /// No description provided for @locationLabel.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get locationLabel;

  /// No description provided for @registerButton.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get registerButton;

  /// No description provided for @selectLocationButton.
  ///
  /// In en, this message translates to:
  /// **'Select Location'**
  String get selectLocationButton;

  /// No description provided for @getAutoLocationButton.
  ///
  /// In en, this message translates to:
  /// **'Get auto location'**
  String get getAutoLocationButton;

  /// No description provided for @locatingMessage.
  ///
  /// In en, this message translates to:
  /// **'Locating...'**
  String get locatingMessage;

  /// No description provided for @manageOffersTitle.
  ///
  /// In en, this message translates to:
  /// **'Manage Offers'**
  String get manageOffersTitle;

  /// No description provided for @addNewOffer.
  ///
  /// In en, this message translates to:
  /// **'Add New Offer'**
  String get addNewOffer;

  /// No description provided for @migrateOldOffers.
  ///
  /// In en, this message translates to:
  /// **'Sync/Migrate old offers'**
  String get migrateOldOffers;

  /// No description provided for @offerIdMissing.
  ///
  /// In en, this message translates to:
  /// **'Offer ID missing!'**
  String get offerIdMissing;

  /// No description provided for @offerDeleted.
  ///
  /// In en, this message translates to:
  /// **'Offer deleted successfully.'**
  String get offerDeleted;

  /// No description provided for @offerDeleteFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete offer'**
  String get offerDeleteFailed;

  /// No description provided for @offerStatusChanged.
  ///
  /// In en, this message translates to:
  /// **'Offer status changed successfully.'**
  String get offerStatusChanged;

  /// No description provided for @offerStatusChangeFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to change offer status'**
  String get offerStatusChangeFailed;

  /// No description provided for @autoMigrationFailed.
  ///
  /// In en, this message translates to:
  /// **'Auto migration failed'**
  String get autoMigrationFailed;

  /// No description provided for @offersMigratedCount.
  ///
  /// In en, this message translates to:
  /// **'Migrated {count} offers from Firestore'**
  String offersMigratedCount(int count);

  /// No description provided for @productsScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Store Products'**
  String get productsScreenTitle;

  /// No description provided for @importCsv.
  ///
  /// In en, this message translates to:
  /// **'Import CSV'**
  String get importCsv;

  /// No description provided for @csvTemplate.
  ///
  /// In en, this message translates to:
  /// **'Template'**
  String get csvTemplate;

  /// No description provided for @exportCsv.
  ///
  /// In en, this message translates to:
  /// **'Export CSV'**
  String get exportCsv;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @searchHintProducts.
  ///
  /// In en, this message translates to:
  /// **'Fast / fuzzy search product name...'**
  String get searchHintProducts;

  /// No description provided for @debugProductsBanner.
  ///
  /// In en, this message translates to:
  /// **'[DEBUG] Products screen (dev only)'**
  String get debugProductsBanner;

  /// No description provided for @noProductsYet.
  ///
  /// In en, this message translates to:
  /// **'No products yet'**
  String get noProductsYet;

  /// No description provided for @addProductManual.
  ///
  /// In en, this message translates to:
  /// **'Add product manually'**
  String get addProductManual;

  /// No description provided for @addProduct.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get addProduct;

  /// No description provided for @addProductTitle.
  ///
  /// In en, this message translates to:
  /// **'Add New Product'**
  String get addProductTitle;

  /// No description provided for @productNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Product Name'**
  String get productNameLabel;

  /// No description provided for @productPointsLabel.
  ///
  /// In en, this message translates to:
  /// **'Points for product'**
  String get productPointsLabel;

  /// No description provided for @basisSelectionLabel.
  ///
  /// In en, this message translates to:
  /// **'Points based on:'**
  String get basisSelectionLabel;

  /// No description provided for @basisProductDirect.
  ///
  /// In en, this message translates to:
  /// **'Direct product'**
  String get basisProductDirect;

  /// No description provided for @basisPrice.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get basisPrice;

  /// No description provided for @basisQuantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get basisQuantity;

  /// No description provided for @basisOperation.
  ///
  /// In en, this message translates to:
  /// **'Purchase operation'**
  String get basisOperation;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @supabaseSessionMissing.
  ///
  /// In en, this message translates to:
  /// **'Supabase session unavailable, login again'**
  String get supabaseSessionMissing;

  /// No description provided for @productAdded.
  ///
  /// In en, this message translates to:
  /// **'Product added'**
  String get productAdded;

  /// No description provided for @productAddFailed.
  ///
  /// In en, this message translates to:
  /// **'Add failed'**
  String get productAddFailed;

  /// No description provided for @editProductTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Product'**
  String get editProductTitle;

  /// No description provided for @productNameImmutable.
  ///
  /// In en, this message translates to:
  /// **'Product name (immutable)'**
  String get productNameImmutable;

  /// No description provided for @productUpdated.
  ///
  /// In en, this message translates to:
  /// **'Updated'**
  String get productUpdated;

  /// No description provided for @productUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Update failed'**
  String get productUpdateFailed;

  /// No description provided for @emptyResults.
  ///
  /// In en, this message translates to:
  /// **'No results'**
  String get emptyResults;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @searchResultsCount.
  ///
  /// In en, this message translates to:
  /// **'Search results: {count}'**
  String searchResultsCount(int count);

  /// No description provided for @tableMissingTitle.
  ///
  /// In en, this message translates to:
  /// **'Table missing'**
  String get tableMissingTitle;

  /// No description provided for @tableMissingMessage.
  ///
  /// In en, this message translates to:
  /// **'Create merchant_products table in Supabase then reopen page.'**
  String get tableMissingMessage;

  /// No description provided for @recheck.
  ///
  /// In en, this message translates to:
  /// **'Recheck'**
  String get recheck;

  /// No description provided for @csvFileEmpty.
  ///
  /// In en, this message translates to:
  /// **'Empty file'**
  String get csvFileEmpty;

  /// No description provided for @missingName.
  ///
  /// In en, this message translates to:
  /// **'Missing name'**
  String get missingName;

  /// No description provided for @invalidPoints.
  ///
  /// In en, this message translates to:
  /// **'Invalid points'**
  String get invalidPoints;

  /// No description provided for @noProcessableRows.
  ///
  /// In en, this message translates to:
  /// **'No processable rows'**
  String get noProcessableRows;

  /// No description provided for @parseFailed.
  ///
  /// In en, this message translates to:
  /// **'Parsing failed'**
  String get parseFailed;

  /// No description provided for @importReviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Import Review'**
  String get importReviewTitle;

  /// No description provided for @validInvalidCount.
  ///
  /// In en, this message translates to:
  /// **'Valid: {valid} | Errors: {invalid}'**
  String validInvalidCount(int valid, int invalid);

  /// No description provided for @skipDuplicateProducts.
  ///
  /// In en, this message translates to:
  /// **'Skip duplicate product names'**
  String get skipDuplicateProducts;

  /// No description provided for @importingEllipsis.
  ///
  /// In en, this message translates to:
  /// **'Importing...'**
  String get importingEllipsis;

  /// No description provided for @importProductsButton.
  ///
  /// In en, this message translates to:
  /// **'Import {count}'**
  String importProductsButton(int count);

  /// No description provided for @sessionMissing.
  ///
  /// In en, this message translates to:
  /// **'Session missing'**
  String get sessionMissing;

  /// No description provided for @noNewItemsAfterDuplicates.
  ///
  /// In en, this message translates to:
  /// **'No new items after duplicates filter'**
  String get noNewItemsAfterDuplicates;

  /// No description provided for @insertedProductsResult.
  ///
  /// In en, this message translates to:
  /// **'Inserted {inserted} products (Rejected {rejected})'**
  String insertedProductsResult(int inserted, int rejected);

  /// No description provided for @importFailed.
  ///
  /// In en, this message translates to:
  /// **'Import failed'**
  String get importFailed;

  /// No description provided for @csvExportCreated.
  ///
  /// In en, this message translates to:
  /// **'CSV created - copy the text'**
  String get csvExportCreated;

  /// No description provided for @exportFailed.
  ///
  /// In en, this message translates to:
  /// **'Export failed'**
  String get exportFailed;

  /// No description provided for @priceRuleFormat.
  ///
  /// In en, this message translates to:
  /// **'Price {value} = {points} pts'**
  String priceRuleFormat(String value, int points);

  /// No description provided for @quantityRuleFormat.
  ///
  /// In en, this message translates to:
  /// **'Quantity {value} = {points} pts'**
  String quantityRuleFormat(String value, int points);

  /// No description provided for @operationRuleFormat.
  ///
  /// In en, this message translates to:
  /// **'Operations {value} = {points} pts'**
  String operationRuleFormat(String value, int points);

  /// No description provided for @pointsRuleFormat.
  ///
  /// In en, this message translates to:
  /// **'Points: {points}'**
  String pointsRuleFormat(int points);

  /// No description provided for @editPointsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Edit points'**
  String get editPointsTooltip;

  /// No description provided for @ruleValuePriceLabel.
  ///
  /// In en, this message translates to:
  /// **'Target price'**
  String get ruleValuePriceLabel;

  /// No description provided for @ruleValueQuantityLabel.
  ///
  /// In en, this message translates to:
  /// **'Target quantity'**
  String get ruleValueQuantityLabel;

  /// No description provided for @ruleValueOperationLabel.
  ///
  /// In en, this message translates to:
  /// **'Operations count'**
  String get ruleValueOperationLabel;

  /// No description provided for @rulePointsLabel.
  ///
  /// In en, this message translates to:
  /// **'Points'**
  String get rulePointsLabel;

  /// No description provided for @ruleExamplePrice.
  ///
  /// In en, this message translates to:
  /// **'Example: 10 price = 1 pt'**
  String get ruleExamplePrice;

  /// No description provided for @ruleExampleQuantity.
  ///
  /// In en, this message translates to:
  /// **'Example: 5 pcs = 2 pts'**
  String get ruleExampleQuantity;

  /// No description provided for @ruleExampleOperation.
  ///
  /// In en, this message translates to:
  /// **'Example: 1 op = 3 pts'**
  String get ruleExampleOperation;

  /// No description provided for @similarityFormat.
  ///
  /// In en, this message translates to:
  /// **'Similarity: {sim}'**
  String similarityFormat(String sim);

  /// No description provided for @noOffersYet.
  ///
  /// In en, this message translates to:
  /// **'No offers yet'**
  String get noOffersYet;

  /// No description provided for @noMatchingResults.
  ///
  /// In en, this message translates to:
  /// **'No matching results'**
  String get noMatchingResults;

  /// No description provided for @notSpecified.
  ///
  /// In en, this message translates to:
  /// **'Not specified'**
  String get notSpecified;

  /// No description provided for @storeNameUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Store name unavailable'**
  String get storeNameUnavailable;

  /// No description provided for @noTitle.
  ///
  /// In en, this message translates to:
  /// **'No title'**
  String get noTitle;

  /// No description provided for @noDescription.
  ///
  /// In en, this message translates to:
  /// **'No description'**
  String get noDescription;

  /// No description provided for @deliveryAvailable.
  ///
  /// In en, this message translates to:
  /// **'Delivery available'**
  String get deliveryAvailable;

  /// No description provided for @deliveryNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Delivery not available'**
  String get deliveryNotAvailable;

  /// No description provided for @endsAtPrefix.
  ///
  /// In en, this message translates to:
  /// **'Ends at:'**
  String get endsAtPrefix;

  /// No description provided for @activeLabel.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get activeLabel;

  /// No description provided for @manageCustomersTitle.
  ///
  /// In en, this message translates to:
  /// **'Manage Customers'**
  String get manageCustomersTitle;

  /// No description provided for @loadingCustomers.
  ///
  /// In en, this message translates to:
  /// **'Loading customers...'**
  String get loadingCustomers;

  /// No description provided for @customersFetchError.
  ///
  /// In en, this message translates to:
  /// **'Failed to load customers'**
  String get customersFetchError;

  /// No description provided for @noCustomersYet.
  ///
  /// In en, this message translates to:
  /// **'No customers yet'**
  String get noCustomersYet;

  /// No description provided for @pointsLabel.
  ///
  /// In en, this message translates to:
  /// **'Points: {points}'**
  String pointsLabel(int points);

  /// No description provided for @customerDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Customer Details'**
  String get customerDetailsTitle;

  /// No description provided for @customerNotFound.
  ///
  /// In en, this message translates to:
  /// **'Customer not found'**
  String get customerNotFound;

  /// No description provided for @totalPoints.
  ///
  /// In en, this message translates to:
  /// **'Total points: {points}'**
  String totalPoints(int points);

  /// No description provided for @purchaseHistory.
  ///
  /// In en, this message translates to:
  /// **'Purchase History'**
  String get purchaseHistory;

  /// No description provided for @redeemedRewards.
  ///
  /// In en, this message translates to:
  /// **'Redeemed Rewards'**
  String get redeemedRewards;

  /// No description provided for @receiptsHistory.
  ///
  /// In en, this message translates to:
  /// **'Receipts History'**
  String get receiptsHistory;

  /// No description provided for @customerOffers.
  ///
  /// In en, this message translates to:
  /// **'Customer Offers'**
  String get customerOffers;

  /// No description provided for @noPurchasesYet.
  ///
  /// In en, this message translates to:
  /// **'No purchases yet'**
  String get noPurchasesYet;

  /// No description provided for @noRewardsYet.
  ///
  /// In en, this message translates to:
  /// **'No redeemed rewards'**
  String get noRewardsYet;

  /// No description provided for @noReceiptsYet.
  ///
  /// In en, this message translates to:
  /// **'No receipts yet'**
  String get noReceiptsYet;

  /// No description provided for @noOffersForCustomer.
  ///
  /// In en, this message translates to:
  /// **'No offers for this customer'**
  String get noOffersForCustomer;

  /// No description provided for @orderNumber.
  ///
  /// In en, this message translates to:
  /// **'Order #: {id}'**
  String orderNumber(String id);

  /// No description provided for @invoiceNumber.
  ///
  /// In en, this message translates to:
  /// **'Invoice #: {id}'**
  String invoiceNumber(String id);

  /// No description provided for @dateLabel.
  ///
  /// In en, this message translates to:
  /// **'Date: {date}'**
  String dateLabel(String date);

  /// No description provided for @amountLabel.
  ///
  /// In en, this message translates to:
  /// **'Amount: {amount}'**
  String amountLabel(String amount);

  /// No description provided for @supportOffer.
  ///
  /// In en, this message translates to:
  /// **'Support offer'**
  String get supportOffer;

  /// No description provided for @offerSupported.
  ///
  /// In en, this message translates to:
  /// **'Offer supported'**
  String get offerSupported;

  /// No description provided for @customerReportsTitle.
  ///
  /// In en, this message translates to:
  /// **'Customer Reports'**
  String get customerReportsTitle;

  /// No description provided for @unknownDate.
  ///
  /// In en, this message translates to:
  /// **'Unknown date'**
  String get unknownDate;

  /// No description provided for @reportDate.
  ///
  /// In en, this message translates to:
  /// **'Report date: {date}'**
  String reportDate(String date);

  /// No description provided for @noMessage.
  ///
  /// In en, this message translates to:
  /// **'No message'**
  String get noMessage;

  /// No description provided for @receiptsLogTitle.
  ///
  /// In en, this message translates to:
  /// **'Receipts Log'**
  String get receiptsLogTitle;

  /// No description provided for @statusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get statusPending;

  /// No description provided for @statusAccepted.
  ///
  /// In en, this message translates to:
  /// **'Accepted'**
  String get statusAccepted;

  /// No description provided for @statusRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get statusRejected;

  /// No description provided for @statusLabel.
  ///
  /// In en, this message translates to:
  /// **'Status: {value}'**
  String statusLabel(String value);

  /// No description provided for @invoiceNumberShort.
  ///
  /// In en, this message translates to:
  /// **'Receipt #: {num}'**
  String invoiceNumberShort(String num);

  /// No description provided for @createdAtLabel.
  ///
  /// In en, this message translates to:
  /// **'Created: {date}'**
  String createdAtLabel(String date);

  /// No description provided for @quantityPrice.
  ///
  /// In en, this message translates to:
  /// **'Qty: {qty} | Price: {price}'**
  String quantityPrice(int qty, String price);

  /// No description provided for @noProductDetails.
  ///
  /// In en, this message translates to:
  /// **'No product details'**
  String get noProductDetails;

  /// No description provided for @noActiveRewards.
  ///
  /// In en, this message translates to:
  /// **'No active rewards'**
  String get noActiveRewards;

  /// No description provided for @noRedeemedRewards.
  ///
  /// In en, this message translates to:
  /// **'No redeemed rewards'**
  String get noRedeemedRewards;

  /// No description provided for @manageRewardsTitle.
  ///
  /// In en, this message translates to:
  /// **'Manage Rewards'**
  String get manageRewardsTitle;

  /// No description provided for @activeRewardsTab.
  ///
  /// In en, this message translates to:
  /// **'Active Rewards'**
  String get activeRewardsTab;

  /// No description provided for @redeemedRewardsTab.
  ///
  /// In en, this message translates to:
  /// **'Redeemed History'**
  String get redeemedRewardsTab;

  /// No description provided for @addNewReward.
  ///
  /// In en, this message translates to:
  /// **'Add new reward'**
  String get addNewReward;

  /// No description provided for @syncRewards.
  ///
  /// In en, this message translates to:
  /// **'Sync Firestore rewards'**
  String get syncRewards;

  /// No description provided for @scanQrReward.
  ///
  /// In en, this message translates to:
  /// **'Scan QR to redeem'**
  String get scanQrReward;

  /// No description provided for @syncingDone.
  ///
  /// In en, this message translates to:
  /// **'Synced'**
  String get syncingDone;

  /// No description provided for @syncFailed.
  ///
  /// In en, this message translates to:
  /// **'Sync failed'**
  String get syncFailed;

  /// No description provided for @loginFirstSupabase.
  ///
  /// In en, this message translates to:
  /// **'Login first (Supabase session missing)'**
  String get loginFirstSupabase;

  /// No description provided for @deleteRewardError.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete reward'**
  String get deleteRewardError;

  /// No description provided for @rewardNoTitle.
  ///
  /// In en, this message translates to:
  /// **'Untitled reward'**
  String get rewardNoTitle;

  /// No description provided for @qrRewardTitle.
  ///
  /// In en, this message translates to:
  /// **'QR to redeem reward'**
  String get qrRewardTitle;

  /// No description provided for @closeLower.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get closeLower;

  /// No description provided for @unknownDateShort.
  ///
  /// In en, this message translates to:
  /// **'Unknown date'**
  String get unknownDateShort;

  /// No description provided for @rewardTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Reward: {title}'**
  String rewardTitleLabel(String title);

  /// No description provided for @customerLabel.
  ///
  /// In en, this message translates to:
  /// **'Customer: {name}'**
  String customerLabel(String name);

  /// No description provided for @registerNewMerchantTitle.
  ///
  /// In en, this message translates to:
  /// **'New Merchant Registration'**
  String get registerNewMerchantTitle;

  /// No description provided for @activityOtherPrompt.
  ///
  /// In en, this message translates to:
  /// **'Specify other activity'**
  String get activityOtherPrompt;

  /// No description provided for @pickStoreOnMap.
  ///
  /// In en, this message translates to:
  /// **'Pick store location on map'**
  String get pickStoreOnMap;

  /// No description provided for @storeLocationPicked.
  ///
  /// In en, this message translates to:
  /// **'Location selected'**
  String get storeLocationPicked;

  /// No description provided for @autoLocating.
  ///
  /// In en, this message translates to:
  /// **'Locating...'**
  String get autoLocating;

  /// No description provided for @autoLocateButton.
  ///
  /// In en, this message translates to:
  /// **'Auto locate'**
  String get autoLocateButton;

  /// No description provided for @submitRegister.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get submitRegister;

  /// No description provided for @locationServiceDisabled.
  ///
  /// In en, this message translates to:
  /// **'Location service disabled'**
  String get locationServiceDisabled;

  /// No description provided for @locationPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Location permission denied'**
  String get locationPermissionDenied;

  /// No description provided for @locationPermissionDeniedForever.
  ///
  /// In en, this message translates to:
  /// **'Location permission permanently denied. Open settings.'**
  String get locationPermissionDeniedForever;

  /// No description provided for @locationAutoCaptured.
  ///
  /// In en, this message translates to:
  /// **'Location captured automatically'**
  String get locationAutoCaptured;

  /// No description provided for @locationFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to get location: {error}'**
  String locationFailed(String error);

  /// No description provided for @completeProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Complete Profile'**
  String get completeProfileTitle;

  /// No description provided for @mustLoginFirst.
  ///
  /// In en, this message translates to:
  /// **'You must login first'**
  String get mustLoginFirst;

  /// No description provided for @profileSavedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Profile saved successfully!'**
  String get profileSavedSuccess;

  /// No description provided for @genericErrorWithMessage.
  ///
  /// In en, this message translates to:
  /// **'Error: {message}'**
  String genericErrorWithMessage(String message);

  /// No description provided for @requiredField.
  ///
  /// In en, this message translates to:
  /// **'Field is required'**
  String get requiredField;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @pointsSystemTitle.
  ///
  /// In en, this message translates to:
  /// **'Points System'**
  String get pointsSystemTitle;

  /// No description provided for @pointsMechanismTitle.
  ///
  /// In en, this message translates to:
  /// **'Calculation Mechanism'**
  String get pointsMechanismTitle;

  /// No description provided for @pointsSimplifiedDescription.
  ///
  /// In en, this message translates to:
  /// **'The system is simplified: total points = sum(product assigned points × quantity in receipt). No extra settings for now.'**
  String get pointsSimplifiedDescription;

  /// No description provided for @pointsSimplificationBenefitsTitle.
  ///
  /// In en, this message translates to:
  /// **'Simplification Benefits:'**
  String get pointsSimplificationBenefitsTitle;

  /// No description provided for @pointsSimplificationBenefitsBullet.
  ///
  /// In en, this message translates to:
  /// **'• Faster performance & easier to understand\n• Avoid special-case complexity\n• Change per-product points instantly without retroactive effect unless manually applied'**
  String get pointsSimplificationBenefitsBullet;

  /// No description provided for @addOfferTitle.
  ///
  /// In en, this message translates to:
  /// **'Add New Offer'**
  String get addOfferTitle;

  /// No description provided for @offerImagePlaceholderOptional.
  ///
  /// In en, this message translates to:
  /// **'Offer image (optional)'**
  String get offerImagePlaceholderOptional;

  /// No description provided for @pickFromGallery.
  ///
  /// In en, this message translates to:
  /// **'From Gallery'**
  String get pickFromGallery;

  /// No description provided for @captureWithCamera.
  ///
  /// In en, this message translates to:
  /// **'Capture with Camera'**
  String get captureWithCamera;

  /// No description provided for @imageOptionalNote.
  ///
  /// In en, this message translates to:
  /// **'Image can be left empty or you can pick/capture a new one.'**
  String get imageOptionalNote;

  /// No description provided for @offerTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Offer Title'**
  String get offerTitleLabel;

  /// No description provided for @offerDescriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Offer Description'**
  String get offerDescriptionLabel;

  /// No description provided for @originalPriceLabel.
  ///
  /// In en, this message translates to:
  /// **'Original Price'**
  String get originalPriceLabel;

  /// No description provided for @discountPercentageLabel.
  ///
  /// In en, this message translates to:
  /// **'Discount (%)'**
  String get discountPercentageLabel;

  /// No description provided for @discountPercentageInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter percentage 1-99'**
  String get discountPercentageInvalid;

  /// No description provided for @startDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Start Date'**
  String get startDateLabel;

  /// No description provided for @endDateLabel.
  ///
  /// In en, this message translates to:
  /// **'End Date'**
  String get endDateLabel;

  /// No description provided for @chooseGeneric.
  ///
  /// In en, this message translates to:
  /// **'Choose'**
  String get chooseGeneric;

  /// No description provided for @pickOfferLocation.
  ///
  /// In en, this message translates to:
  /// **'Pick offer location on map'**
  String get pickOfferLocation;

  /// No description provided for @offerLocationPicked.
  ///
  /// In en, this message translates to:
  /// **'Location selected'**
  String get offerLocationPicked;

  /// No description provided for @offerTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Offer Type'**
  String get offerTypeLabel;

  /// No description provided for @offerTypeDiscount.
  ///
  /// In en, this message translates to:
  /// **'Direct Discount'**
  String get offerTypeDiscount;

  /// No description provided for @offerTypeGift.
  ///
  /// In en, this message translates to:
  /// **'Gift with Purchase'**
  String get offerTypeGift;

  /// No description provided for @offerTypeCoupon.
  ///
  /// In en, this message translates to:
  /// **'Coupon'**
  String get offerTypeCoupon;

  /// No description provided for @offerTypeLimitedTime.
  ///
  /// In en, this message translates to:
  /// **'Limited Time Offer'**
  String get offerTypeLimitedTime;

  /// No description provided for @offerTypeOther.
  ///
  /// In en, this message translates to:
  /// **'Other...'**
  String get offerTypeOther;

  /// No description provided for @selectStartEndDates.
  ///
  /// In en, this message translates to:
  /// **'Please select start and end dates'**
  String get selectStartEndDates;

  /// No description provided for @offerLocationRequired.
  ///
  /// In en, this message translates to:
  /// **'Please pick offer location on map'**
  String get offerLocationRequired;

  /// No description provided for @offerTypeRequired.
  ///
  /// In en, this message translates to:
  /// **'Please select offer type'**
  String get offerTypeRequired;

  /// No description provided for @offerAddedSynced.
  ///
  /// In en, this message translates to:
  /// **'Offer added & synced'**
  String get offerAddedSynced;

  /// No description provided for @offerUpdatedSynced.
  ///
  /// In en, this message translates to:
  /// **'Offer updated & synced'**
  String get offerUpdatedSynced;

  /// No description provided for @imagePickFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to pick image: {error}'**
  String imagePickFailed(String error);

  /// No description provided for @savedWithSupabaseWarning.
  ///
  /// In en, this message translates to:
  /// **'Saved (Supabase sync warning: {error})'**
  String savedWithSupabaseWarning(String error);

  /// No description provided for @offerEndsAt.
  ///
  /// In en, this message translates to:
  /// **'Ends at: {date}'**
  String offerEndsAt(String date);

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @storeNameNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Store name not available'**
  String get storeNameNotAvailable;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'ar',
    'de',
    'en',
    'es',
    'fr',
    'it',
    'tr',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'it':
      return AppLocalizationsIt();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}

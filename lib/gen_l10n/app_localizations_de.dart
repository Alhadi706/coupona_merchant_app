// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Händler App';

  @override
  String get login => 'Anmelden';

  @override
  String get logout => 'Abmelden';

  @override
  String get settings => 'Einstellungen';

  @override
  String get language => 'Sprache';

  @override
  String get noMerchantCode => 'Kein Code';

  @override
  String get copied => 'Kopiert';

  @override
  String get merchantCode => 'Händlercode';

  @override
  String get home => 'Startseite';

  @override
  String get offers => 'Angebote';

  @override
  String get customers => 'Kunden';

  @override
  String get products => 'Produkte';

  @override
  String get receipts => 'Belege';

  @override
  String get copiedMerchantCode => 'Händlercode kopiert';

  @override
  String get close => 'Schließen';

  @override
  String get merchantLoginTitle => 'Händler Login';

  @override
  String get enterEmailPassword => 'Bitte E-Mail und Passwort eingeben';

  @override
  String get loginFailed => 'Login fehlgeschlagen';

  @override
  String get loginButton => 'Login';

  @override
  String get createMerchantAccount => 'Neues Händlerkonto';

  @override
  String get forgotPassword => 'Passwort vergessen?';

  @override
  String get sendResetLink => 'Link zum Zurücksetzen wird gesendet';

  @override
  String get supabaseSessionFailed => 'Supabase Sitzung fehlgeschlagen';

  @override
  String get emailLabel => 'E-Mail';

  @override
  String get passwordLabel => 'Passwort';

  @override
  String get registerTitle => 'Händler Registrierung';

  @override
  String get fillAllFields => 'Bitte alle Felder ausfüllen';

  @override
  String get passwordsNotMatch => 'Passwörter stimmen nicht überein';

  @override
  String get invalidEmail => 'Ungültige E-Mail';

  @override
  String get pickStoreLocation => 'Standort auswählen';

  @override
  String get emailAlreadyUsed => 'E-Mail bereits registriert, bitte einloggen.';

  @override
  String get accountCreatedSuccess => 'Konto erstellt!';

  @override
  String get accountCreateFailed => 'Kontoerstellung fehlgeschlagen';

  @override
  String get unexpectedError => 'Unerwarteter Fehler';

  @override
  String get confirmPasswordLabel => 'Passwort bestätigen';

  @override
  String get storeNameLabel => 'Shop Name';

  @override
  String get phoneLabel => 'Telefon';

  @override
  String get activityTypeLabel => 'Aktivitätstyp';

  @override
  String get otherActivityLabel => 'Andere';

  @override
  String get locationLabel => 'Standort';

  @override
  String get registerButton => 'Registrieren';

  @override
  String get selectLocationButton => 'Standort wählen';

  @override
  String get getAutoLocationButton => 'Automatisch lokalisieren';

  @override
  String get locatingMessage => 'Lokalisieren...';

  @override
  String get manageOffersTitle => 'Angebote verwalten';

  @override
  String get addNewOffer => 'Neues Angebot';

  @override
  String get migrateOldOffers => 'Alte Angebote migrieren';

  @override
  String get offerIdMissing => 'Angebots-ID fehlt!';

  @override
  String get offerDeleted => 'Angebot gelöscht.';

  @override
  String get offerDeleteFailed => 'Löschen fehlgeschlagen';

  @override
  String get offerStatusChanged => 'Status geändert.';

  @override
  String get offerStatusChangeFailed => 'Statusänderung fehlgeschlagen';

  @override
  String get autoMigrationFailed => 'Automatische Migration fehlgeschlagen';

  @override
  String offersMigratedCount(int count) {
    return '$count Angebote migriert';
  }

  @override
  String get productsScreenTitle => 'Shop Produkte';

  @override
  String get importCsv => 'CSV Import';

  @override
  String get csvTemplate => 'Vorlage';

  @override
  String get exportCsv => 'CSV Export';

  @override
  String get refresh => 'Aktualisieren';

  @override
  String get searchHintProducts => 'Schnellsuche / fuzzy Produktname...';

  @override
  String get debugProductsBanner => '[DEBUG] Produktbildschirm';

  @override
  String get noProductsYet => 'Noch keine Produkte';

  @override
  String get addProductManual => 'Produkt manuell hinzufügen';

  @override
  String get addProduct => 'Hinzufügen';

  @override
  String get addProductTitle => 'Neues Produkt';

  @override
  String get productNameLabel => 'Produktname';

  @override
  String get productPointsLabel => 'Punkte für Produkt';

  @override
  String get basisSelectionLabel => 'Punkte basierend auf:';

  @override
  String get basisProductDirect => 'Direktes Produkt';

  @override
  String get basisPrice => 'Preis';

  @override
  String get basisQuantity => 'Menge';

  @override
  String get basisOperation => 'Kaufvorgang';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get supabaseSessionMissing => 'Supabase Sitzung fehlt';

  @override
  String get productAdded => 'Produkt hinzugefügt';

  @override
  String get productAddFailed => 'Hinzufügen fehlgeschlagen';

  @override
  String get editProductTitle => 'Produkt bearbeiten';

  @override
  String get productNameImmutable => 'Name (fix)';

  @override
  String get productUpdated => 'Aktualisiert';

  @override
  String get productUpdateFailed => 'Aktualisierung fehlgeschlagen';

  @override
  String get emptyResults => 'Keine Ergebnisse';

  @override
  String get clear => 'Leeren';

  @override
  String searchResultsCount(int count) {
    return 'Treffer: $count';
  }

  @override
  String get tableMissingTitle => 'Tabelle fehlt';

  @override
  String get tableMissingMessage =>
      'Erstelle merchant_products Tabelle in Supabase und öffne erneut.';

  @override
  String get recheck => 'Prüfen';

  @override
  String get csvFileEmpty => 'Datei leer';

  @override
  String get missingName => 'Name fehlt';

  @override
  String get invalidPoints => 'Ungültige Punkte';

  @override
  String get noProcessableRows => 'Keine verarbeitbaren Zeilen';

  @override
  String get parseFailed => 'Parsing fehlgeschlagen';

  @override
  String get importReviewTitle => 'Importprüfung';

  @override
  String validInvalidCount(int valid, int invalid) {
    return 'Valide: $valid | Fehler: $invalid';
  }

  @override
  String get skipDuplicateProducts => 'Doppelte Namen überspringen';

  @override
  String get importingEllipsis => 'Importiere...';

  @override
  String importProductsButton(int count) {
    return 'Importiere $count';
  }

  @override
  String get sessionMissing => 'Session fehlt';

  @override
  String get noNewItemsAfterDuplicates =>
      'Keine neuen Einträge nach Duplikaten';

  @override
  String insertedProductsResult(int inserted, int rejected) {
    return 'Eingefügt $inserted (Abgelehnt $rejected)';
  }

  @override
  String get importFailed => 'Import fehlgeschlagen';

  @override
  String get csvExportCreated => 'CSV erstellt - kopieren';

  @override
  String get exportFailed => 'Export fehlgeschlagen';

  @override
  String priceRuleFormat(String value, int points) {
    return 'Preis $value = $points Pkt';
  }

  @override
  String quantityRuleFormat(String value, int points) {
    return 'Menge $value = $points Pkt';
  }

  @override
  String operationRuleFormat(String value, int points) {
    return 'Operationen $value = $points Pkt';
  }

  @override
  String pointsRuleFormat(int points) {
    return 'Punkte: $points';
  }

  @override
  String get editPointsTooltip => 'Punkte bearbeiten';

  @override
  String get ruleValuePriceLabel => 'Zielpreis';

  @override
  String get ruleValueQuantityLabel => 'Zielmenge';

  @override
  String get ruleValueOperationLabel => 'Anzahl Vorgänge';

  @override
  String get rulePointsLabel => 'Punkte';

  @override
  String get ruleExamplePrice => 'Bsp: 10 Preis = 1 Pkt';

  @override
  String get ruleExampleQuantity => 'Bsp: 5 Stk = 2 Pkt';

  @override
  String get ruleExampleOperation => 'Bsp: 1 Vorg = 3 Pkt';

  @override
  String similarityFormat(String sim) {
    return 'Ähnlichkeit: $sim';
  }

  @override
  String get noOffersYet => 'Noch keine Angebote';

  @override
  String get noMatchingResults => 'Keine Treffer';

  @override
  String get notSpecified => 'Nicht festgelegt';

  @override
  String get storeNameUnavailable => 'Shopname nicht verfügbar';

  @override
  String get noTitle => 'Kein Titel';

  @override
  String get noDescription => 'Keine Beschreibung';

  @override
  String get deliveryAvailable => 'Lieferung verfügbar';

  @override
  String get deliveryNotAvailable => 'Lieferung nicht verfügbar';

  @override
  String get endsAtPrefix => 'Endet am:';

  @override
  String get activeLabel => 'Aktiv';

  @override
  String get manageCustomersTitle => 'Kunden verwalten';

  @override
  String get loadingCustomers => 'Kunden laden...';

  @override
  String get customersFetchError => 'Kunden konnten nicht geladen werden';

  @override
  String get noCustomersYet => 'Noch keine Kunden';

  @override
  String pointsLabel(int points) {
    return 'Punkte: $points';
  }

  @override
  String get customerDetailsTitle => 'Kundendetails';

  @override
  String get customerNotFound => 'Kunde nicht gefunden';

  @override
  String totalPoints(int points) {
    return 'Gesamtpunkte: $points';
  }

  @override
  String get purchaseHistory => 'Kaufhistorie';

  @override
  String get redeemedRewards => 'Eingelöste Prämien';

  @override
  String get receiptsHistory => 'Belegverlauf';

  @override
  String get customerOffers => 'Kundenangebote';

  @override
  String get noPurchasesYet => 'Keine Käufe';

  @override
  String get noRewardsYet => 'Keine Prämien';

  @override
  String get noReceiptsYet => 'Keine Belege';

  @override
  String get noOffersForCustomer => 'Keine Angebote für diesen Kunden';

  @override
  String orderNumber(String id) {
    return 'Bestellung #: $id';
  }

  @override
  String invoiceNumber(String id) {
    return 'Rechnung #: $id';
  }

  @override
  String dateLabel(String date) {
    return 'Datum: $date';
  }

  @override
  String amountLabel(String amount) {
    return 'Betrag: $amount';
  }

  @override
  String get supportOffer => 'Angebot unterstützen';

  @override
  String get offerSupported => 'Angebot unterstützt';

  @override
  String get customerReportsTitle => 'Kundenberichte';

  @override
  String get unknownDate => 'Unbekanntes Datum';

  @override
  String reportDate(String date) {
    return 'Berichtsdatum: $date';
  }

  @override
  String get noMessage => 'Keine Nachricht';

  @override
  String get receiptsLogTitle => 'Belegverlauf';

  @override
  String get statusPending => 'Prüfung';

  @override
  String get statusAccepted => 'Akzeptiert';

  @override
  String get statusRejected => 'Abgelehnt';

  @override
  String statusLabel(String value) {
    return 'Status: $value';
  }

  @override
  String invoiceNumberShort(String num) {
    return 'Beleg #: $num';
  }

  @override
  String createdAtLabel(String date) {
    return 'Erstellt: $date';
  }

  @override
  String quantityPrice(int qty, String price) {
    return 'Menge: $qty | Preis: $price';
  }

  @override
  String get noProductDetails => 'Keine Produktdetails';

  @override
  String get noActiveRewards => 'Keine aktiven Prämien';

  @override
  String get noRedeemedRewards => 'Keine eingelösten Prämien';

  @override
  String get manageRewardsTitle => 'Prämien verwalten';

  @override
  String get activeRewardsTab => 'Aktiv';

  @override
  String get redeemedRewardsTab => 'Historie';

  @override
  String get addNewReward => 'Neue Prämie';

  @override
  String get syncRewards => 'Prämien synchronisieren';

  @override
  String get scanQrReward => 'QR scannen';

  @override
  String get syncingDone => 'Synchronisiert';

  @override
  String get syncFailed => 'Sync fehlgeschlagen';

  @override
  String get loginFirstSupabase => 'Erst einloggen (Supabase Sitzung fehlt)';

  @override
  String get deleteRewardError => 'Prämie löschen fehlgeschlagen';

  @override
  String get rewardNoTitle => 'Ohne Titel';

  @override
  String get qrRewardTitle => 'QR zum Einlösen';

  @override
  String get closeLower => 'Schließen';

  @override
  String get unknownDateShort => 'Unbekanntes Datum';

  @override
  String rewardTitleLabel(String title) {
    return 'Prämie: $title';
  }

  @override
  String customerLabel(String name) {
    return 'Kunde: $name';
  }
}

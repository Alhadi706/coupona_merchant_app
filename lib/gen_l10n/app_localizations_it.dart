// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appTitle => 'App Commerciante';

  @override
  String get login => 'Accesso';

  @override
  String get logout => 'Disconnetti';

  @override
  String get settings => 'Impostazioni';

  @override
  String get language => 'Lingua';

  @override
  String get noMerchantCode => 'Nessun codice';

  @override
  String get copied => 'Copiato';

  @override
  String get merchantCode => 'Codice Commerciante';

  @override
  String get home => 'Home';

  @override
  String get offers => 'Offerte';

  @override
  String get customers => 'Clienti';

  @override
  String get products => 'Prodotti';

  @override
  String get receipts => 'Ricevute';

  @override
  String get copiedMerchantCode => 'Codice commerciante copiato';

  @override
  String get close => 'Chiudi';

  @override
  String get merchantLoginTitle => 'Accesso Commerciante';

  @override
  String get enterEmailPassword => 'Inserisci email e password';

  @override
  String get loginFailed => 'Accesso fallito';

  @override
  String get loginButton => 'Accesso';

  @override
  String get createMerchantAccount => 'Crea nuovo account';

  @override
  String get forgotPassword => 'Password dimenticata?';

  @override
  String get sendResetLink => 'Link reset verrà inviato';

  @override
  String get supabaseSessionFailed => 'Impossibile creare sessione Supabase';

  @override
  String get emailLabel => 'Email';

  @override
  String get passwordLabel => 'Password';

  @override
  String get registerTitle => 'Registrazione Commerciante';

  @override
  String get fillAllFields => 'Compila tutti i campi richiesti';

  @override
  String get passwordsNotMatch => 'Le password non coincidono';

  @override
  String get invalidEmail => 'Email non valida';

  @override
  String get pickStoreLocation => 'Seleziona posizione negozio';

  @override
  String get emailAlreadyUsed => 'Email già registrata, fai login.';

  @override
  String get accountCreatedSuccess => 'Account creato con successo!';

  @override
  String get accountCreateFailed => 'Creazione account fallita';

  @override
  String get unexpectedError => 'Errore inatteso';

  @override
  String get confirmPasswordLabel => 'Conferma Password';

  @override
  String get storeNameLabel => 'Nome Negozio';

  @override
  String get phoneLabel => 'Telefono';

  @override
  String get activityTypeLabel => 'Tipo Attività';

  @override
  String get otherActivityLabel => 'Altro';

  @override
  String get locationLabel => 'Posizione';

  @override
  String get registerButton => 'Registrati';

  @override
  String get selectLocationButton => 'Seleziona posizione';

  @override
  String get getAutoLocationButton => 'Localizza automaticamente';

  @override
  String get locatingMessage => 'Localizzazione...';

  @override
  String get manageOffersTitle => 'Gestisci Offerte';

  @override
  String get addNewOffer => 'Nuova offerta';

  @override
  String get migrateOldOffers => 'Migra offerte vecchie';

  @override
  String get offerIdMissing => 'ID offerta mancante!';

  @override
  String get offerDeleted => 'Offerta eliminata.';

  @override
  String get offerDeleteFailed => 'Eliminazione offerta fallita';

  @override
  String get offerStatusChanged => 'Stato offerta cambiato.';

  @override
  String get offerStatusChangeFailed => 'Cambio stato fallito';

  @override
  String get autoMigrationFailed => 'Migrazione automatica fallita';

  @override
  String offersMigratedCount(int count) {
    return 'Migrati $count offerte da Firestore';
  }

  @override
  String get productsScreenTitle => 'Prodotti del negozio';

  @override
  String get importCsv => 'Importa CSV';

  @override
  String get csvTemplate => 'Modello';

  @override
  String get exportCsv => 'Esporta CSV';

  @override
  String get refresh => 'Aggiorna';

  @override
  String get searchHintProducts => 'Ricerca rapida / fuzzy nome...';

  @override
  String get debugProductsBanner => '[DEBUG] Schermata prodotti';

  @override
  String get noProductsYet => 'Nessun prodotto ancora';

  @override
  String get addProductManual => 'Aggiungi manuale';

  @override
  String get addProduct => 'Aggiungi';

  @override
  String get addProductTitle => 'Nuovo prodotto';

  @override
  String get productNameLabel => 'Nome prodotto';

  @override
  String get productPointsLabel => 'Punti prodotto';

  @override
  String get basisSelectionLabel => 'Punti basati su:';

  @override
  String get basisProductDirect => 'Prodotto diretto';

  @override
  String get basisPrice => 'Prezzo';

  @override
  String get basisQuantity => 'Quantità';

  @override
  String get basisOperation => 'Operazione acquisto';

  @override
  String get cancel => 'Annulla';

  @override
  String get supabaseSessionMissing => 'Sessione Supabase assente';

  @override
  String get productAdded => 'Prodotto aggiunto';

  @override
  String get productAddFailed => 'Aggiunta fallita';

  @override
  String get editProductTitle => 'Modifica prodotto';

  @override
  String get productNameImmutable => 'Nome (fisso)';

  @override
  String get productUpdated => 'Aggiornato';

  @override
  String get productUpdateFailed => 'Aggiornamento fallito';

  @override
  String get emptyResults => 'Nessun risultato';

  @override
  String get clear => 'Pulisci';

  @override
  String searchResultsCount(int count) {
    return 'Risultati: $count';
  }

  @override
  String get tableMissingTitle => 'Tabella mancante';

  @override
  String get tableMissingMessage =>
      'Crea tabella merchant_products in Supabase e riapri.';

  @override
  String get recheck => 'Ricontrolla';

  @override
  String get csvFileEmpty => 'File vuoto';

  @override
  String get missingName => 'Nome mancante';

  @override
  String get invalidPoints => 'Punti non validi';

  @override
  String get noProcessableRows => 'Nessuna riga elaborabile';

  @override
  String get parseFailed => 'Parsing fallito';

  @override
  String get importReviewTitle => 'Revisione import';

  @override
  String validInvalidCount(int valid, int invalid) {
    return 'Validi: $valid | Errori: $invalid';
  }

  @override
  String get skipDuplicateProducts => 'Salta nomi duplicati';

  @override
  String get importingEllipsis => 'Importazione...';

  @override
  String importProductsButton(int count) {
    return 'Importa $count';
  }

  @override
  String get sessionMissing => 'Sessione mancante';

  @override
  String get noNewItemsAfterDuplicates => 'Nessun nuovo dopo duplicati';

  @override
  String insertedProductsResult(int inserted, int rejected) {
    return 'Inseriti $inserted (Respinti $rejected)';
  }

  @override
  String get importFailed => 'Import fallito';

  @override
  String get csvExportCreated => 'CSV creato - copia';

  @override
  String get exportFailed => 'Export fallito';

  @override
  String priceRuleFormat(String value, int points) {
    return 'Prezzo $value = $points pt';
  }

  @override
  String quantityRuleFormat(String value, int points) {
    return 'Quantità $value = $points pt';
  }

  @override
  String operationRuleFormat(String value, int points) {
    return 'Operazioni $value = $points pt';
  }

  @override
  String pointsRuleFormat(int points) {
    return 'Punti: $points';
  }

  @override
  String get editPointsTooltip => 'Modifica punti';

  @override
  String get ruleValuePriceLabel => 'Prezzo target';

  @override
  String get ruleValueQuantityLabel => 'Quantità target';

  @override
  String get ruleValueOperationLabel => 'N° operazioni';

  @override
  String get rulePointsLabel => 'Punti';

  @override
  String get ruleExamplePrice => 'Es: 10 prezzo = 1 pt';

  @override
  String get ruleExampleQuantity => 'Es: 5 pz = 2 pt';

  @override
  String get ruleExampleOperation => 'Es: 1 op = 3 pt';

  @override
  String similarityFormat(String sim) {
    return 'Somiglianza: $sim';
  }

  @override
  String get noOffersYet => 'Ancora nessuna offerta';

  @override
  String get noMatchingResults => 'Nessuna corrispondenza';

  @override
  String get notSpecified => 'Non specificato';

  @override
  String get storeNameUnavailable => 'Nome negozio non disp.';

  @override
  String get noTitle => 'Senza titolo';

  @override
  String get noDescription => 'Nessuna descrizione';

  @override
  String get deliveryAvailable => 'Consegna disponibile';

  @override
  String get deliveryNotAvailable => 'Consegna non disponibile';

  @override
  String get endsAtPrefix => 'Termina il:';

  @override
  String get activeLabel => 'Attivo';

  @override
  String get manageCustomersTitle => 'Gestisci clienti';

  @override
  String get loadingCustomers => 'Caricamento clienti...';

  @override
  String get customersFetchError => 'Errore caricamento clienti';

  @override
  String get noCustomersYet => 'Nessun cliente ancora';

  @override
  String pointsLabel(int points) {
    return 'Punti: $points';
  }

  @override
  String get customerDetailsTitle => 'Dettagli cliente';

  @override
  String get customerNotFound => 'Cliente non trovato';

  @override
  String totalPoints(int points) {
    return 'Punti totali: $points';
  }

  @override
  String get purchaseHistory => 'Storico acquisti';

  @override
  String get redeemedRewards => 'Premi riscattati';

  @override
  String get receiptsHistory => 'Storico ricevute';

  @override
  String get customerOffers => 'Offerte cliente';

  @override
  String get noPurchasesYet => 'Nessun acquisto';

  @override
  String get noRewardsYet => 'Nessun premio';

  @override
  String get noReceiptsYet => 'Nessuna ricevuta';

  @override
  String get noOffersForCustomer => 'Nessuna offerta per questo cliente';

  @override
  String orderNumber(String id) {
    return 'Ordine #: $id';
  }

  @override
  String invoiceNumber(String id) {
    return 'Fattura #: $id';
  }

  @override
  String dateLabel(String date) {
    return 'Data: $date';
  }

  @override
  String amountLabel(String amount) {
    return 'Importo: $amount';
  }

  @override
  String get supportOffer => 'Supporta offerta';

  @override
  String get offerSupported => 'Offerta supportata';

  @override
  String get customerReportsTitle => 'Segnalazioni clienti';

  @override
  String get unknownDate => 'Data sconosciuta';

  @override
  String reportDate(String date) {
    return 'Data segnalazione: $date';
  }

  @override
  String get noMessage => 'Nessun messaggio';

  @override
  String get receiptsLogTitle => 'Storico ricevute';

  @override
  String get statusPending => 'In revisione';

  @override
  String get statusAccepted => 'Accettata';

  @override
  String get statusRejected => 'Rifiutata';

  @override
  String statusLabel(String value) {
    return 'Stato: $value';
  }

  @override
  String invoiceNumberShort(String num) {
    return 'Ricevuta #: $num';
  }

  @override
  String createdAtLabel(String date) {
    return 'Creato: $date';
  }

  @override
  String quantityPrice(int qty, String price) {
    return 'Qtà: $qty | Prezzo: $price';
  }

  @override
  String get noProductDetails => 'Nessun dettaglio prodotto';

  @override
  String get noActiveRewards => 'Nessun premio attivo';

  @override
  String get noRedeemedRewards => 'Nessun premio riscattato';

  @override
  String get manageRewardsTitle => 'Gestisci premi';

  @override
  String get activeRewardsTab => 'Attivi';

  @override
  String get redeemedRewardsTab => 'Storico';

  @override
  String get addNewReward => 'Nuovo premio';

  @override
  String get syncRewards => 'Sincronizza premi';

  @override
  String get scanQrReward => 'Scansiona QR';

  @override
  String get syncingDone => 'Sincronizzato';

  @override
  String get syncFailed => 'Sync fallito';

  @override
  String get loginFirstSupabase => 'Fai login (sessione Supabase assente)';

  @override
  String get deleteRewardError => 'Eliminazione premio fallita';

  @override
  String get rewardNoTitle => 'Senza titolo';

  @override
  String get qrRewardTitle => 'QR premio';

  @override
  String get closeLower => 'Chiudi';

  @override
  String get unknownDateShort => 'Data sconosciuta';

  @override
  String rewardTitleLabel(String title) {
    return 'Premio: $title';
  }

  @override
  String customerLabel(String name) {
    return 'Cliente: $name';
  }
}

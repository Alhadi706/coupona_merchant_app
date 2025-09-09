// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Application Marchand';

  @override
  String get login => 'Connexion';

  @override
  String get logout => 'Déconnexion';

  @override
  String get settings => 'Paramètres';

  @override
  String get language => 'Langue';

  @override
  String get noMerchantCode => 'Pas de code';

  @override
  String get copied => 'Copié';

  @override
  String get merchantCode => 'Code Marchand';

  @override
  String get home => 'Accueil';

  @override
  String get offers => 'Offres';

  @override
  String get customers => 'Clients';

  @override
  String get products => 'Produits';

  @override
  String get receipts => 'Reçus';

  @override
  String get copiedMerchantCode => 'Code marchand copié';

  @override
  String get close => 'Fermer';

  @override
  String get merchantLoginTitle => 'Connexion Marchand';

  @override
  String get enterEmailPassword => 'Veuillez entrer email et mot de passe';

  @override
  String get loginFailed => 'Échec de connexion';

  @override
  String get loginButton => 'Connexion';

  @override
  String get createMerchantAccount => 'Créer un compte marchand';

  @override
  String get forgotPassword => 'Mot de passe oublié ?';

  @override
  String get sendResetLink => 'Lien de réinitialisation sera envoyé';

  @override
  String get supabaseSessionFailed => 'Impossible de créer la session Supabase';

  @override
  String get emailLabel => 'Email';

  @override
  String get passwordLabel => 'Mot de passe';

  @override
  String get registerTitle => 'Inscription Marchand';

  @override
  String get fillAllFields => 'Veuillez remplir tous les champs requis';

  @override
  String get passwordsNotMatch => 'Les mots de passe ne correspondent pas';

  @override
  String get invalidEmail => 'Email non valide';

  @override
  String get pickStoreLocation => 'Veuillez choisir l\'emplacement du magasin';

  @override
  String get emailAlreadyUsed => 'Email déjà utilisé, connectez-vous.';

  @override
  String get accountCreatedSuccess => 'Compte créé avec succès !';

  @override
  String get accountCreateFailed => 'Échec de création du compte';

  @override
  String get unexpectedError => 'Erreur inattendue';

  @override
  String get confirmPasswordLabel => 'Confirmer le mot de passe';

  @override
  String get storeNameLabel => 'Nom du magasin';

  @override
  String get phoneLabel => 'Téléphone';

  @override
  String get activityTypeLabel => 'Type d\'activité';

  @override
  String get otherActivityLabel => 'Autre activité';

  @override
  String get locationLabel => 'Emplacement';

  @override
  String get registerButton => 'S\'inscrire';

  @override
  String get selectLocationButton => 'Choisir emplacement';

  @override
  String get getAutoLocationButton => 'Localiser auto';

  @override
  String get locatingMessage => 'Localisation...';

  @override
  String get manageOffersTitle => 'Gérer Offres';

  @override
  String get addNewOffer => 'Nouvelle offre';

  @override
  String get migrateOldOffers => 'Migrer anciennes offres';

  @override
  String get offerIdMissing => 'ID offre manquant !';

  @override
  String get offerDeleted => 'Offre supprimée.';

  @override
  String get offerDeleteFailed => 'Échec suppression offre';

  @override
  String get offerStatusChanged => 'Statut offre modifié.';

  @override
  String get offerStatusChangeFailed => 'Échec changement statut';

  @override
  String get autoMigrationFailed => 'Échec migration auto';

  @override
  String offersMigratedCount(int count) {
    return '$count offres migrées depuis Firestore';
  }

  @override
  String get productsScreenTitle => 'Produits du magasin';

  @override
  String get importCsv => 'Importer CSV';

  @override
  String get csvTemplate => 'Modèle';

  @override
  String get exportCsv => 'Exporter CSV';

  @override
  String get refresh => 'Rafraîchir';

  @override
  String get searchHintProducts => 'Recherche floue nom produit...';

  @override
  String get debugProductsBanner => '[DEBUG] Écran produits (dev)';

  @override
  String get noProductsYet => 'Aucun produit pour l\'instant';

  @override
  String get addProductManual => 'Ajouter produit manuellement';

  @override
  String get addProduct => 'Ajouter';

  @override
  String get addProductTitle => 'Ajouter un produit';

  @override
  String get productNameLabel => 'Nom du produit';

  @override
  String get productPointsLabel => 'Points pour produit';

  @override
  String get basisSelectionLabel => 'Points basés sur:';

  @override
  String get basisProductDirect => 'Produit direct';

  @override
  String get basisPrice => 'Prix';

  @override
  String get basisQuantity => 'Quantité';

  @override
  String get basisOperation => 'Opération d\'achat';

  @override
  String get cancel => 'Annuler';

  @override
  String get supabaseSessionMissing => 'Session Supabase indisponible';

  @override
  String get productAdded => 'Produit ajouté';

  @override
  String get productAddFailed => 'Échec ajout';

  @override
  String get editProductTitle => 'Modifier produit';

  @override
  String get productNameImmutable => 'Nom (non modifiable)';

  @override
  String get productUpdated => 'Mis à jour';

  @override
  String get productUpdateFailed => 'Échec mise à jour';

  @override
  String get emptyResults => 'Aucun résultat';

  @override
  String get clear => 'Effacer';

  @override
  String searchResultsCount(int count) {
    return 'Résultats: $count';
  }

  @override
  String get tableMissingTitle => 'Table manquante';

  @override
  String get tableMissingMessage =>
      'Créez la table merchant_products dans Supabase puis rouvrez.';

  @override
  String get recheck => 'Revérifier';

  @override
  String get csvFileEmpty => 'Fichier vide';

  @override
  String get missingName => 'Nom manquant';

  @override
  String get invalidPoints => 'Points invalides';

  @override
  String get noProcessableRows => 'Aucune ligne exploitable';

  @override
  String get parseFailed => 'Échec analyse';

  @override
  String get importReviewTitle => 'Revue import';

  @override
  String validInvalidCount(int valid, int invalid) {
    return 'Valides: $valid | Erreurs: $invalid';
  }

  @override
  String get skipDuplicateProducts => 'Ignorer doublons noms';

  @override
  String get importingEllipsis => 'Importation...';

  @override
  String importProductsButton(int count) {
    return 'Importer $count';
  }

  @override
  String get sessionMissing => 'Session manquante';

  @override
  String get noNewItemsAfterDuplicates => 'Aucun nouvel élément après doublons';

  @override
  String insertedProductsResult(int inserted, int rejected) {
    return 'Inséré $inserted (Rejeté $rejected)';
  }

  @override
  String get importFailed => 'Import échoué';

  @override
  String get csvExportCreated => 'CSV créé - copiez';

  @override
  String get exportFailed => 'Export échoué';

  @override
  String priceRuleFormat(String value, int points) {
    return 'Prix $value = $points pts';
  }

  @override
  String quantityRuleFormat(String value, int points) {
    return 'Quantité $value = $points pts';
  }

  @override
  String operationRuleFormat(String value, int points) {
    return 'Opérations $value = $points pts';
  }

  @override
  String pointsRuleFormat(int points) {
    return 'Points: $points';
  }

  @override
  String get editPointsTooltip => 'Modifier points';

  @override
  String get ruleValuePriceLabel => 'Prix cible';

  @override
  String get ruleValueQuantityLabel => 'Quantité cible';

  @override
  String get ruleValueOperationLabel => 'Nb opérations';

  @override
  String get rulePointsLabel => 'Points';

  @override
  String get ruleExamplePrice => 'Ex: 10 prix = 1 pt';

  @override
  String get ruleExampleQuantity => 'Ex: 5 pcs = 2 pts';

  @override
  String get ruleExampleOperation => 'Ex: 1 op = 3 pts';

  @override
  String similarityFormat(String sim) {
    return 'Similarité: $sim';
  }

  @override
  String get noOffersYet => 'Aucune offre pour l\'instant';

  @override
  String get noMatchingResults => 'Aucune correspondance';

  @override
  String get notSpecified => 'Non spécifié';

  @override
  String get storeNameUnavailable => 'Nom magasin indisponible';

  @override
  String get noTitle => 'Sans titre';

  @override
  String get noDescription => 'Pas de description';

  @override
  String get deliveryAvailable => 'Livraison disponible';

  @override
  String get deliveryNotAvailable => 'Livraison non disponible';

  @override
  String get endsAtPrefix => 'Se termine le:';

  @override
  String get activeLabel => 'Actif';

  @override
  String get manageCustomersTitle => 'Gérer Clients';

  @override
  String get loadingCustomers => 'Chargement clients...';

  @override
  String get customersFetchError => 'Échec chargement clients';

  @override
  String get noCustomersYet => 'Aucun client';

  @override
  String pointsLabel(int points) {
    return 'Points: $points';
  }

  @override
  String get customerDetailsTitle => 'Détails Client';

  @override
  String get customerNotFound => 'Client introuvable';

  @override
  String totalPoints(int points) {
    return 'Total points: $points';
  }

  @override
  String get purchaseHistory => 'Historique achats';

  @override
  String get redeemedRewards => 'Récompenses utilisées';

  @override
  String get receiptsHistory => 'Historique reçus';

  @override
  String get customerOffers => 'Offres du client';

  @override
  String get noPurchasesYet => 'Aucun achat';

  @override
  String get noRewardsYet => 'Aucune récompense';

  @override
  String get noReceiptsYet => 'Aucun reçu';

  @override
  String get noOffersForCustomer => 'Aucune offre pour ce client';

  @override
  String orderNumber(String id) {
    return 'Commande #: $id';
  }

  @override
  String invoiceNumber(String id) {
    return 'Facture #: $id';
  }

  @override
  String dateLabel(String date) {
    return 'Date: $date';
  }

  @override
  String amountLabel(String amount) {
    return 'Montant: $amount';
  }

  @override
  String get supportOffer => 'Soutenir offre';

  @override
  String get offerSupported => 'Offre soutenue';

  @override
  String get customerReportsTitle => 'Rapports Clients';

  @override
  String get unknownDate => 'Date inconnue';

  @override
  String reportDate(String date) {
    return 'Date rapport: $date';
  }

  @override
  String get noMessage => 'Pas de message';

  @override
  String get receiptsLogTitle => 'Journal des reçus';

  @override
  String get statusPending => 'En attente';

  @override
  String get statusAccepted => 'Acceptée';

  @override
  String get statusRejected => 'Rejetée';

  @override
  String statusLabel(String value) {
    return 'Statut: $value';
  }

  @override
  String invoiceNumberShort(String num) {
    return 'Reçu #: $num';
  }

  @override
  String createdAtLabel(String date) {
    return 'Créé: $date';
  }

  @override
  String quantityPrice(int qty, String price) {
    return 'Qté: $qty | Prix: $price';
  }

  @override
  String get noProductDetails => 'Pas de détails produits';

  @override
  String get noActiveRewards => 'Aucune récompense active';

  @override
  String get noRedeemedRewards => 'Aucune récompense utilisée';

  @override
  String get manageRewardsTitle => 'Gérer Récompenses';

  @override
  String get activeRewardsTab => 'Actives';

  @override
  String get redeemedRewardsTab => 'Historique';

  @override
  String get addNewReward => 'Ajouter récompense';

  @override
  String get syncRewards => 'Synchroniser récompenses';

  @override
  String get scanQrReward => 'Scanner QR';

  @override
  String get syncingDone => 'Synchronisé';

  @override
  String get syncFailed => 'Échec sync';

  @override
  String get loginFirstSupabase =>
      'Connectez-vous (session Supabase manquante)';

  @override
  String get deleteRewardError => 'Échec suppression récompense';

  @override
  String get rewardNoTitle => 'Sans titre';

  @override
  String get qrRewardTitle => 'QR pour récompense';

  @override
  String get closeLower => 'Fermer';

  @override
  String get unknownDateShort => 'Date inconnue';

  @override
  String rewardTitleLabel(String title) {
    return 'Récompense: $title';
  }

  @override
  String customerLabel(String name) {
    return 'Client: $name';
  }

  @override
  String get registerNewMerchantTitle => 'Inscription nouveau commerçant';

  @override
  String get activityOtherPrompt => 'Préciser autre activité';

  @override
  String get pickStoreOnMap => 'Choisir l\'emplacement sur la carte';

  @override
  String get storeLocationPicked => 'Emplacement sélectionné';

  @override
  String get autoLocating => 'Localisation...';

  @override
  String get autoLocateButton => 'Localiser auto';

  @override
  String get submitRegister => 'S\'inscrire';

  @override
  String get locationServiceDisabled => 'Service de localisation désactivé';

  @override
  String get locationPermissionDenied => 'Autorisation localisation refusée';

  @override
  String get locationPermissionDeniedForever =>
      'Autorisation localisation définit. refusée. Ouvrir paramètres.';

  @override
  String get locationAutoCaptured => 'Localisation capturée auto';

  @override
  String locationFailed(String error) {
    return 'Échec localisation: $error';
  }

  @override
  String get completeProfileTitle => 'Compléter le profil';

  @override
  String get mustLoginFirst => 'Vous devez d\'abord vous connecter';

  @override
  String get profileSavedSuccess => 'Profil enregistré avec succès!';

  @override
  String genericErrorWithMessage(String message) {
    return 'Erreur: $message';
  }

  @override
  String get requiredField => 'Champ requis';

  @override
  String get save => 'Enregistrer';

  @override
  String get pointsSystemTitle => 'Système de points';

  @override
  String get pointsMechanismTitle => 'Mécanisme de calcul';

  @override
  String get pointsSimplifiedDescription =>
      'Système simplifié: total des points = somme(points produit × quantité du reçu). Pas d\'autres réglages pour l\'instant.';

  @override
  String get pointsSimplificationBenefitsTitle => 'Avantages simplification:';

  @override
  String get pointsSimplificationBenefitsBullet =>
      '• Performance et compréhension rapides\n• Évite complexité des cas particuliers\n• Changer les points produit est instantané sans effet rétroactif sauf application manuelle';

  @override
  String get addOfferTitle => 'Ajouter une offre';

  @override
  String get offerImagePlaceholderOptional => 'Image de l\'offre (optionnel)';

  @override
  String get pickFromGallery => 'Depuis galerie';

  @override
  String get captureWithCamera => 'Prendre photo';

  @override
  String get imageOptionalNote =>
      'L\'image peut être vide ou choisie/capturée.';

  @override
  String get offerTitleLabel => 'Titre de l\'offre';

  @override
  String get offerDescriptionLabel => 'Description de l\'offre';

  @override
  String get originalPriceLabel => 'Prix original';

  @override
  String get discountPercentageLabel => 'Réduction (%)';

  @override
  String get discountPercentageInvalid => 'Entrez pourcentage 1-99';

  @override
  String get startDateLabel => 'Date début';

  @override
  String get endDateLabel => 'Date fin';

  @override
  String get chooseGeneric => 'Choisir';

  @override
  String get pickOfferLocation => 'Choisir emplacement sur la carte';

  @override
  String get offerLocationPicked => 'Emplacement sélectionné';

  @override
  String get offerTypeLabel => 'Type d\'offre';

  @override
  String get offerTypeDiscount => 'Réduction directe';

  @override
  String get offerTypeGift => 'Cadeau à l\'achat';

  @override
  String get offerTypeCoupon => 'Coupon';

  @override
  String get offerTypeLimitedTime => 'Offre limitée';

  @override
  String get offerTypeOther => 'Autre...';

  @override
  String get selectStartEndDates => 'Veuillez sélectionner dates début et fin';

  @override
  String get offerLocationRequired =>
      'Veuillez choisir l\'emplacement de l\'offre';

  @override
  String get offerTypeRequired => 'Veuillez choisir le type d\'offre';

  @override
  String get offerAddedSynced => 'Offre ajoutée & synchronisée';

  @override
  String get offerUpdatedSynced => 'Offre mise à jour & synchronisée';

  @override
  String imagePickFailed(String error) {
    return 'Échec sélection image: $error';
  }

  @override
  String savedWithSupabaseWarning(String error) {
    return 'Enregistré (avert. sync Supabase: $error)';
  }

  @override
  String offerEndsAt(String date) {
    return 'Se termine le: $date';
  }

  @override
  String get active => 'Actif';

  @override
  String get storeNameNotAvailable => 'Nom du magasin non disponible';
}

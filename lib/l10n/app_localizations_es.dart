// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'App Comerciante';

  @override
  String get login => 'Iniciar sesión';

  @override
  String get logout => 'Cerrar sesión';

  @override
  String get settings => 'Configuración';

  @override
  String get language => 'Idioma';

  @override
  String get noMerchantCode => 'Sin código';

  @override
  String get copied => 'Copiado';

  @override
  String get merchantCode => 'Código de Comerciante';

  @override
  String get home => 'Inicio';

  @override
  String get offers => 'Ofertas';

  @override
  String get customers => 'Clientes';

  @override
  String get products => 'Productos';

  @override
  String get receipts => 'Recibos';

  @override
  String get copiedMerchantCode => 'Código de comerciante copiado';

  @override
  String get close => 'Cerrar';

  @override
  String get merchantLoginTitle => 'Acceso Comerciante';

  @override
  String get enterEmailPassword => 'Ingrese correo y contraseña';

  @override
  String get loginFailed => 'Inicio fallido';

  @override
  String get loginButton => 'Entrar';

  @override
  String get createMerchantAccount => 'Crear nueva cuenta';

  @override
  String get forgotPassword => '¿Olvidó la contraseña?';

  @override
  String get sendResetLink => 'Se enviará enlace de reinicio';

  @override
  String get supabaseSessionFailed => 'No se pudo crear sesión Supabase';

  @override
  String get emailLabel => 'Correo';

  @override
  String get passwordLabel => 'Contraseña';

  @override
  String get registerTitle => 'Registro Comerciante';

  @override
  String get fillAllFields => 'Complete todos los campos';

  @override
  String get passwordsNotMatch => 'Las contraseñas no coinciden';

  @override
  String get invalidEmail => 'Correo inválido';

  @override
  String get pickStoreLocation => 'Seleccione ubicación de la tienda';

  @override
  String get emailAlreadyUsed => 'Correo ya registrado, use login.';

  @override
  String get accountCreatedSuccess => 'Cuenta creada!';

  @override
  String get accountCreateFailed => 'Fallo al crear cuenta';

  @override
  String get unexpectedError => 'Error inesperado';

  @override
  String get confirmPasswordLabel => 'Confirmar contraseña';

  @override
  String get storeNameLabel => 'Nombre tienda';

  @override
  String get phoneLabel => 'Teléfono';

  @override
  String get activityTypeLabel => 'Tipo de actividad';

  @override
  String get otherActivityLabel => 'Otro';

  @override
  String get locationLabel => 'Ubicación';

  @override
  String get registerButton => 'Registrar';

  @override
  String get selectLocationButton => 'Seleccionar ubicación';

  @override
  String get getAutoLocationButton => 'Ubicar automáticamente';

  @override
  String get locatingMessage => 'Localizando...';

  @override
  String get manageOffersTitle => 'Gestionar ofertas';

  @override
  String get addNewOffer => 'Nueva oferta';

  @override
  String get migrateOldOffers => 'Migrar ofertas antiguas';

  @override
  String get offerIdMissing => 'ID oferta faltante!';

  @override
  String get offerDeleted => 'Oferta eliminada.';

  @override
  String get offerDeleteFailed => 'Fallo al eliminar';

  @override
  String get offerStatusChanged => 'Estado de oferta cambiado.';

  @override
  String get offerStatusChangeFailed => 'Fallo cambio estado';

  @override
  String get autoMigrationFailed => 'Migración automática falló';

  @override
  String offersMigratedCount(int count) {
    return 'Migradas $count ofertas de Firestore';
  }

  @override
  String get productsScreenTitle => 'Productos de la tienda';

  @override
  String get importCsv => 'Importar CSV';

  @override
  String get csvTemplate => 'Plantilla';

  @override
  String get exportCsv => 'Exportar CSV';

  @override
  String get refresh => 'Refrescar';

  @override
  String get searchHintProducts => 'Búsqueda rápida / difusa nombre...';

  @override
  String get debugProductsBanner => '[DEBUG] Pantalla productos';

  @override
  String get noProductsYet => 'Aún sin productos';

  @override
  String get addProductManual => 'Agregar producto manual';

  @override
  String get addProduct => 'Agregar';

  @override
  String get addProductTitle => 'Agregar producto';

  @override
  String get productNameLabel => 'Nombre producto';

  @override
  String get productPointsLabel => 'Puntos del producto';

  @override
  String get basisSelectionLabel => 'Puntos basados en:';

  @override
  String get basisProductDirect => 'Producto directo';

  @override
  String get basisPrice => 'Precio';

  @override
  String get basisQuantity => 'Cantidad';

  @override
  String get basisOperation => 'Operación compra';

  @override
  String get cancel => 'Cancelar';

  @override
  String get supabaseSessionMissing => 'Sesion Supabase no disponible';

  @override
  String get productAdded => 'Producto agregado';

  @override
  String get productAddFailed => 'Fallo agregar';

  @override
  String get editProductTitle => 'Editar producto';

  @override
  String get productNameImmutable => 'Nombre (fijo)';

  @override
  String get productUpdated => 'Actualizado';

  @override
  String get productUpdateFailed => 'Fallo actualización';

  @override
  String get emptyResults => 'Sin resultados';

  @override
  String get clear => 'Limpiar';

  @override
  String searchResultsCount(int count) {
    return 'Resultados: $count';
  }

  @override
  String get tableMissingTitle => 'Falta tabla';

  @override
  String get tableMissingMessage =>
      'Cree tabla merchant_products en Supabase y reabra.';

  @override
  String get recheck => 'Revisar';

  @override
  String get csvFileEmpty => 'Archivo vacío';

  @override
  String get missingName => 'Nombre faltante';

  @override
  String get invalidPoints => 'Puntos inválidos';

  @override
  String get noProcessableRows => 'Sin filas procesables';

  @override
  String get parseFailed => 'Fallo parseo';

  @override
  String get importReviewTitle => 'Revisión import';

  @override
  String validInvalidCount(int valid, int invalid) {
    return 'Válidas: $valid | Errores: $invalid';
  }

  @override
  String get skipDuplicateProducts => 'Omitir nombres duplicados';

  @override
  String get importingEllipsis => 'Importando...';

  @override
  String importProductsButton(int count) {
    return 'Importar $count';
  }

  @override
  String get sessionMissing => 'Sesión faltante';

  @override
  String get noNewItemsAfterDuplicates => 'Sin nuevos tras duplicados';

  @override
  String insertedProductsResult(int inserted, int rejected) {
    return 'Insertados $inserted (Rechazados $rejected)';
  }

  @override
  String get importFailed => 'Importación falló';

  @override
  String get csvExportCreated => 'CSV creado - copie';

  @override
  String get exportFailed => 'Exportación falló';

  @override
  String priceRuleFormat(String value, int points) {
    return 'Precio $value = $points pts';
  }

  @override
  String quantityRuleFormat(String value, int points) {
    return 'Cantidad $value = $points pts';
  }

  @override
  String operationRuleFormat(String value, int points) {
    return 'Operaciones $value = $points pts';
  }

  @override
  String pointsRuleFormat(int points) {
    return 'Puntos: $points';
  }

  @override
  String get editPointsTooltip => 'Editar puntos';

  @override
  String get ruleValuePriceLabel => 'Precio objetivo';

  @override
  String get ruleValueQuantityLabel => 'Cantidad objetivo';

  @override
  String get ruleValueOperationLabel => 'Operaciones objetivo';

  @override
  String get rulePointsLabel => 'Puntos';

  @override
  String get ruleExamplePrice => 'Ej: 10 precio = 1 pt';

  @override
  String get ruleExampleQuantity => 'Ej: 5 uds = 2 pts';

  @override
  String get ruleExampleOperation => 'Ej: 1 op = 3 pts';

  @override
  String similarityFormat(String sim) {
    return 'Similitud: $sim';
  }

  @override
  String get noOffersYet => 'Sin ofertas aún';

  @override
  String get noMatchingResults => 'Sin coincidencias';

  @override
  String get notSpecified => 'No especificado';

  @override
  String get storeNameUnavailable => 'Nombre tienda no disp.';

  @override
  String get noTitle => 'Sin título';

  @override
  String get noDescription => 'Sin descripción';

  @override
  String get deliveryAvailable => 'Entrega disponible';

  @override
  String get deliveryNotAvailable => 'Entrega no disponible';

  @override
  String get endsAtPrefix => 'Termina el:';

  @override
  String get activeLabel => 'Activo';

  @override
  String get manageCustomersTitle => 'Gestionar clientes';

  @override
  String get loadingCustomers => 'Cargando clientes...';

  @override
  String get customersFetchError => 'Error al cargar clientes';

  @override
  String get noCustomersYet => 'Sin clientes aún';

  @override
  String pointsLabel(int points) {
    return 'Puntos: $points';
  }

  @override
  String get customerDetailsTitle => 'Detalles cliente';

  @override
  String get customerNotFound => 'Cliente no encontrado';

  @override
  String totalPoints(int points) {
    return 'Puntos totales: $points';
  }

  @override
  String get purchaseHistory => 'Historial compras';

  @override
  String get redeemedRewards => 'Recompensas canjeadas';

  @override
  String get receiptsHistory => 'Historial recibos';

  @override
  String get customerOffers => 'Ofertas del cliente';

  @override
  String get noPurchasesYet => 'Sin compras';

  @override
  String get noRewardsYet => 'Sin recompensas';

  @override
  String get noReceiptsYet => 'Sin recibos';

  @override
  String get noOffersForCustomer => 'Sin ofertas para este cliente';

  @override
  String orderNumber(String id) {
    return 'Pedido #: $id';
  }

  @override
  String invoiceNumber(String id) {
    return 'Factura #: $id';
  }

  @override
  String dateLabel(String date) {
    return 'Fecha: $date';
  }

  @override
  String amountLabel(String amount) {
    return 'Monto: $amount';
  }

  @override
  String get supportOffer => 'Apoyar oferta';

  @override
  String get offerSupported => 'Oferta apoyada';

  @override
  String get customerReportsTitle => 'Reportes clientes';

  @override
  String get unknownDate => 'Fecha desconocida';

  @override
  String reportDate(String date) {
    return 'Fecha reporte: $date';
  }

  @override
  String get noMessage => 'Sin mensaje';

  @override
  String get receiptsLogTitle => 'Historial recibos';

  @override
  String get statusPending => 'Pendiente';

  @override
  String get statusAccepted => 'Aceptada';

  @override
  String get statusRejected => 'Rechazada';

  @override
  String statusLabel(String value) {
    return 'Estado: $value';
  }

  @override
  String invoiceNumberShort(String num) {
    return 'Recibo #: $num';
  }

  @override
  String createdAtLabel(String date) {
    return 'Creado: $date';
  }

  @override
  String quantityPrice(int qty, String price) {
    return 'Cant: $qty | Precio: $price';
  }

  @override
  String get noProductDetails => 'Sin detalles de producto';

  @override
  String get noActiveRewards => 'Sin recompensas activas';

  @override
  String get noRedeemedRewards => 'Sin recompensas canjeadas';

  @override
  String get manageRewardsTitle => 'Gestionar recompensas';

  @override
  String get activeRewardsTab => 'Activas';

  @override
  String get redeemedRewardsTab => 'Historial';

  @override
  String get addNewReward => 'Nueva recompensa';

  @override
  String get syncRewards => 'Sincronizar recompensas';

  @override
  String get scanQrReward => 'Escanear QR';

  @override
  String get syncingDone => 'Sincronizado';

  @override
  String get syncFailed => 'Fallo sync';

  @override
  String get loginFirstSupabase => 'Inicie sesión (sin sesión Supabase)';

  @override
  String get deleteRewardError => 'Eliminar recompensa falló';

  @override
  String get rewardNoTitle => 'Sin título';

  @override
  String get qrRewardTitle => 'QR recompensa';

  @override
  String get closeLower => 'Cerrar';

  @override
  String get unknownDateShort => 'Fecha desconocida';

  @override
  String rewardTitleLabel(String title) {
    return 'Recompensa: $title';
  }

  @override
  String customerLabel(String name) {
    return 'Cliente: $name';
  }

  @override
  String get registerNewMerchantTitle => 'Registro nuevo comerciante';

  @override
  String get activityOtherPrompt => 'Especificar otra actividad';

  @override
  String get pickStoreOnMap => 'Elegir ubicación en el mapa';

  @override
  String get storeLocationPicked => 'Ubicación seleccionada';

  @override
  String get autoLocating => 'Localizando...';

  @override
  String get autoLocateButton => 'Auto localizar';

  @override
  String get submitRegister => 'Registrar';

  @override
  String get locationServiceDisabled => 'Servicio de ubicación desactivado';

  @override
  String get locationPermissionDenied => 'Permiso de ubicación denegado';

  @override
  String get locationPermissionDeniedForever =>
      'Permiso de ubicación denegado permanentemente. Abrir ajustes.';

  @override
  String get locationAutoCaptured => 'Ubicación capturada automáticamente';

  @override
  String locationFailed(String error) {
    return 'Fallo ubicación: $error';
  }

  @override
  String get completeProfileTitle => 'Completar perfil';

  @override
  String get mustLoginFirst => 'Debe iniciar sesión primero';

  @override
  String get profileSavedSuccess => 'Perfil guardado con éxito!';

  @override
  String genericErrorWithMessage(String message) {
    return 'Error: $message';
  }

  @override
  String get requiredField => 'Campo obligatorio';

  @override
  String get save => 'Guardar';

  @override
  String get pointsSystemTitle => 'Sistema de puntos';

  @override
  String get pointsMechanismTitle => 'Mecanismo de cálculo';

  @override
  String get pointsSimplifiedDescription =>
      'Sistema simplificado: puntos totales = suma(puntos del producto × cantidad en el recibo). Sin más ajustes por ahora.';

  @override
  String get pointsSimplificationBenefitsTitle =>
      'Beneficios de simplificación:';

  @override
  String get pointsSimplificationBenefitsBullet =>
      '• Rendimiento rápido y fácil de entender\n• Evita complejidad de casos especiales\n• Cambiar puntos de producto es instantáneo sin efecto retroactivo salvo manual';

  @override
  String get addOfferTitle => 'Añadir oferta';

  @override
  String get offerImagePlaceholderOptional => 'Imagen de la oferta (opcional)';

  @override
  String get pickFromGallery => 'Desde galería';

  @override
  String get captureWithCamera => 'Tomar foto';

  @override
  String get imageOptionalNote =>
      'La imagen puede dejarse vacía o elegir/tomar nueva.';

  @override
  String get offerTitleLabel => 'Título de la oferta';

  @override
  String get offerDescriptionLabel => 'Descripción de la oferta';

  @override
  String get originalPriceLabel => 'Precio original';

  @override
  String get discountPercentageLabel => 'Descuento (%)';

  @override
  String get discountPercentageInvalid => 'Ingrese porcentaje 1-99';

  @override
  String get startDateLabel => 'Fecha inicio';

  @override
  String get endDateLabel => 'Fecha fin';

  @override
  String get chooseGeneric => 'Elegir';

  @override
  String get pickOfferLocation => 'Elegir ubicación en el mapa';

  @override
  String get offerLocationPicked => 'Ubicación seleccionada';

  @override
  String get offerTypeLabel => 'Tipo de oferta';

  @override
  String get offerTypeDiscount => 'Descuento directo';

  @override
  String get offerTypeGift => 'Regalo con compra';

  @override
  String get offerTypeCoupon => 'Cupón';

  @override
  String get offerTypeLimitedTime => 'Oferta limitada';

  @override
  String get offerTypeOther => 'Otro...';

  @override
  String get selectStartEndDates => 'Seleccione fechas inicio y fin';

  @override
  String get offerLocationRequired => 'Seleccione ubicación de la oferta';

  @override
  String get offerTypeRequired => 'Seleccione tipo de oferta';

  @override
  String get offerAddedSynced => 'Oferta añadida y sincronizada';

  @override
  String get offerUpdatedSynced => 'Oferta actualizada y sincronizada';

  @override
  String imagePickFailed(String error) {
    return 'Error al seleccionar imagen: $error';
  }

  @override
  String savedWithSupabaseWarning(String error) {
    return 'Guardado (advertencia sync Supabase: $error)';
  }

  @override
  String offerEndsAt(String date) {
    return 'Termina: $date';
  }

  @override
  String get active => 'Activo';

  @override
  String get storeNameNotAvailable => 'Nombre de tienda no disponible';
}

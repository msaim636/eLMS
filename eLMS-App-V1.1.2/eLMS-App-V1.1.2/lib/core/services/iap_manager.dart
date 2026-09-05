// ============================================================================
// IAP MANAGER  —  Platform purchase coordinator
// ============================================================================
// Handles all communication with the platform store (Google Play / App Store).
//
// The backend product list is fetched separately via [FetchIapProductsCubit] +
// [IapRepository]. The product IDs from that response are passed to this
// manager when calling [buyProduct].
//
// HOW TO USE:
//   1. Initialize once at startup:
//        await IapManager.instance.initialize();
//
//   2. Fetch backend products in your screen:
//        BlocProvider(
//          create: (_) => FetchIapProductsCubit(IapRepository())..fetch(),
//          child: const YourIapScreen(),
//        )
//
//   3. When user taps "Buy", query store details then call:
//        await IapManager.instance.loadStoreProduct(productId);
//        await IapManager.instance.buyProduct(productId);
//
//   4. Listen to [purchaseStream] for outcomes.
//
// PLATFORM SETUP:
//   Android : Google Play Console → Monetize → Subscriptions / In-app products
//   iOS     : App Store Connect → Features → In-App Purchases
// ============================================================================

import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:elms/core/api/api_client.dart';
import 'package:elms/core/api/api_params.dart';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

// ─────────────────────────────────────────────────────────────────────────────
// VALUE OBJECTS
// ─────────────────────────────────────────────────────────────────────────────

/// App-layer representation of a store product.
///
/// Created from [ProductDetails] after querying the platform store.
/// Wrap this in your screen to show price, title, etc.
class IapStoreProduct {
  final String id;
  final String title;
  final String description;

  /// Localised price string: "₹499" / "$4.99" etc.
  final String price;

  /// Raw numeric price for calculations / sorting.
  final num rawPrice;
  final String currencyCode;

  /// Underlying store object — kept for [InAppPurchase] calls.
  final ProductDetails productDetails;

  const IapStoreProduct({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.rawPrice,
    required this.currencyCode,
    required this.productDetails,
  });

  factory IapStoreProduct.fromProductDetails(ProductDetails details) {
    return IapStoreProduct(
      id: details.id,
      title: details.title,
      description: details.description,
      price: details.price,
      rawPrice: details.rawPrice,
      currencyCode: details.currencyCode,
      productDetails: details,
    );
  }

  @override
  String toString() => 'IapStoreProduct(id: $id, price: $price)';
}

/// Outcome of a single purchase attempt.
class IapPurchaseResult {
  final bool success;

  /// The store product that was purchased (null when purchase failed early).
  final IapStoreProduct? storeProduct;

  /// Error message when [success] is false.
  final String? errorMessage;

  /// Raw details — use [verificationData] for server-side receipt validation.
  final PurchaseDetails? purchaseDetails;

  const IapPurchaseResult({
    required this.success,
    this.storeProduct,
    this.errorMessage,
    this.purchaseDetails,
  });

  const IapPurchaseResult.failure(String error)
    : success = false,
      storeProduct = null,
      purchaseDetails = null,
      errorMessage = error;

  @override
  String toString() =>
      'IapPurchaseResult(success: $success, '
      'product: ${storeProduct?.id}, error: $errorMessage)';
}

// ─────────────────────────────────────────────────────────────────────────────
// IAP MANAGER  (Singleton)
// ─────────────────────────────────────────────────────────────────────────────

/// Singleton that owns the platform store connection and coordinates purchases.
///
/// Product IDs are NOT hardcoded here — they come from the backend via
/// [IapRepository.fetchProducts()]. Pass the [IapProductModel.productId]
/// to [loadStoreProduct] and [buyProduct].
class IapManager {
  IapManager._();

  static final IapManager instance = IapManager._();

  // ── Private state ──────────────────────────────────────────────────────────

  final InAppPurchase _iap = InAppPurchase.instance;

  /// Store products successfully loaded from the platform.
  /// Key = product ID string.
  final Map<String, IapStoreProduct> _storeProducts = {};

  StreamSubscription<List<PurchaseDetails>>? _purchaseSubscription;

  final StreamController<IapPurchaseResult> _purchaseResultController =
      StreamController<IapPurchaseResult>.broadcast();

  bool _isAvailable = false;
  bool _isInitialized = false;

  // ── Public getters ─────────────────────────────────────────────────────────

  bool get isAvailable => _isAvailable;

  /// Currently loaded store products (populated after [loadStoreProducts]).
  List<IapStoreProduct> get storeProducts =>
      List.unmodifiable(_storeProducts.values);

  /// Subscribe to get notified about purchase outcomes.
  Stream<IapPurchaseResult> get purchaseStream =>
      _purchaseResultController.stream;

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  /// Connect to the store and subscribe to purchase updates.
  ///
  /// Call once at app startup. Safe to call again — subsequent calls no-op.
  Future<void> initialize() async {
    if (_isInitialized) return;
    _isInitialized = true;

    _isAvailable = await _iap.isAvailable();
    if (!_isAvailable) {
      log('[IapManager] Store not available on this device.');
      return;
    }

    _purchaseSubscription = _iap.purchaseStream.listen(
      _onPurchaseUpdated,
      onDone: _onStreamDone,
      onError: _onStreamError,
    );

    await restorePurchases();
  }

  void dispose() {
    _purchaseSubscription?.cancel();
    _purchaseResultController.close();
  }

  // ── Store product loading ──────────────────────────────────────────────────

  /// Query the platform store for details of the given [productIds].
  ///
  /// Call this after fetching product IDs from the backend via
  /// [IapRepository.fetchProducts()]:
  ///
  /// ```dart
  /// final ids = state.data
  ///     .map((p) => p.productId!)
  ///     .toSet();
  /// await IapManager.instance.loadStoreProducts(ids);
  /// ```
  Future<void> loadStoreProducts(Set<String> productIds) async {
    if (!_isAvailable || productIds.isEmpty) return;

    final ProductDetailsResponse response = await _iap.queryProductDetails(
      productIds,
    );

    if (response.error != null) {
      log('[IapManager] Store query error: ${response.error}');
      return;
    }

    if (response.notFoundIDs.isNotEmpty) {
      log('[IapManager] Products NOT found in store: ${response.notFoundIDs}');
    }

    for (final ProductDetails details in response.productDetails) {
      _storeProducts[details.id] = IapStoreProduct.fromProductDetails(details);
    }

    log('[IapManager] Loaded ${_storeProducts.length} store product(s).');
  }

  // ── Purchase actions ───────────────────────────────────────────────────────

  /// Initiate a purchase for the product with [productId].
  ///
  /// [isConsumable] — pass `true` for one-time credits, `false` for
  /// non-consumable / subscription products.
  ///
  /// The result arrives via [purchaseStream].
  Future<bool> buyProduct(String productId, {bool isConsumable = true}) async {
    if (!_isAvailable) {
      _emitFailure('Store is not available on this device.');
      return false;
    }

    final IapStoreProduct? product = _storeProducts[productId];
    if (product == null) {
      log(
        '[IapManager] Product not loaded: $productId. '
        'Call loadStoreProducts() first.',
      );
      _emitFailure('Product details not loaded yet.');
      return false;
    }

    final PurchaseParam param = PurchaseParam(
      productDetails: product.productDetails,
    );

    try {
      if (isConsumable) {
        return await _iap.buyConsumable(purchaseParam: param);
      } else {
        return await _iap.buyNonConsumable(purchaseParam: param);
      }
    } catch (e) {
      log('[IapManager] buyProduct error: $e');
      _emitFailure(e.toString());
      return false;
    }
  }

  /// Restore non-consumable / subscription purchases for the current user.
  Future<void> restorePurchases() async {
    if (!_isAvailable) return;
    try {
      await _iap.restorePurchases();
    } catch (e) {
      log('[IapManager] restorePurchases error: $e');
    }
  }

  // ── Purchase update handling ───────────────────────────────────────────────

  Future<void> _onPurchaseUpdated(List<PurchaseDetails> purchases) async {
    for (final PurchaseDetails purchase in purchases) {
      if (purchase.status == PurchaseStatus.pending) {
        log('[IapManager] Purchase pending: ${purchase.productID}');
        continue;
      }

      if (purchase.status == PurchaseStatus.purchased) {
        await _handleSuccessfulPurchase(purchase);
        continue;
      }

      if (purchase.status == PurchaseStatus.restored) {
        // For consumables, just complete the transaction and discard it —
        // they cannot be restored (each purchase is a new transaction).
        if (purchase.pendingCompletePurchase) {
          await _iap.completePurchase(purchase);
        }
        log(
          '[IapManager] Restored transaction discarded (consumable): ${purchase.productID}',
        );
        continue;
      }

      if (purchase.status == PurchaseStatus.error) {
        log('[IapManager] Purchase error: ${purchase.error?.message}');
        _emitFailure(purchase.error?.message ?? 'Purchase failed');
      }

      if (purchase.status == PurchaseStatus.canceled) {
        log('[IapManager] Purchase cancelled: ${purchase.productID}');
        _emitFailure('Purchase was cancelled');
      }

      if (purchase.pendingCompletePurchase) {
        await _iap.completePurchase(purchase);
      }
    }
  }

  Future<void> _handleSuccessfulPurchase(PurchaseDetails purchase) async {
    // ── SERVER-SIDE VERIFICATION (recommended for production) ──────────────
    // Send `purchase.verificationData.serverVerificationData` to your backend.
    // Only grant credits after your server validates with Apple / Google.
    //
    // Example:
    //   final bool ok = await YourApi.verifyReceipt(
    //     platform: Platform.isIOS ? 'ios' : 'android',
    //     receipt: purchase.verificationData.serverVerificationData,
    //     productId: purchase.productID,
    //   );
    //   if (!ok) { _emitFailure('Verification failed'); return; }
    // ──────────────────────────────────────────────────────────────────────
    log('[IapManager] ========== NATIVE IAP SUCCESS DATA ==========');
    log('[IapManager] Product ID: ${purchase.productID}');
    log('[IapManager] Purchase ID: ${purchase.purchaseID}');
    log('[IapManager] Status: ${purchase.status}');
    log('[IapManager] Transaction Date: ${purchase.transactionDate}');
    log(
      '[IapManager] Verification Source: ${purchase.verificationData.source}',
    );
    log(
      '[IapManager] Local Verification Data: ${purchase.verificationData.localVerificationData}',
    );
    log(
      '[IapManager] Server Verification Data: ${purchase.verificationData.serverVerificationData}',
    );
    log('[IapManager] ============================================');

    final bool verified = await _verifyLocally(purchase);

    if (purchase.pendingCompletePurchase) {
      await _iap.completePurchase(purchase);
    }

    if (verified) {
      _purchaseResultController.add(
        IapPurchaseResult(
          success: true,
          storeProduct: _storeProducts[purchase.productID],
          purchaseDetails: purchase,
        ),
      );
    } else {
      _emitFailure('Purchase could not be verified');
    }
  }

  /// Replaced placeholder with an actual server call for verification.
  Future<bool> _verifyLocally(PurchaseDetails purchase) async {
    log(
      '[IapManager] Verifying: ${purchase.productID} '
      '(source: ${purchase.verificationData.source}) '
      'transactionID: ${purchase.purchaseID}',
    );

    try {
      final response = await Api.post(
        Apis.verifyIapPurchase,
        data: {ApiParams.transactionId: purchase.purchaseID ?? ''},
      );

      if (response['error'] == false) {
        log(
          '[IapManager] Verification successful: ${response['message'] ?? ''}',
        );
        return true;
      } else {
        log(
          '[IapManager] Verification failed: ${response['message'] ?? 'Unknown error'}',
        );
        return false;
      }
    } catch (e) {
      log('[IapManager] Verification network error: $e');
      return false;
    }
  }

  void _onStreamDone() {
    log('[IapManager] Purchase stream closed.');
    _purchaseSubscription?.cancel();
  }

  void _onStreamError(Object error) {
    log('[IapManager] Purchase stream error: $error');
    _emitFailure(error.toString());
  }

  void _emitFailure(String message) {
    _purchaseResultController.add(IapPurchaseResult.failure(message));
  }

  // ── Platform helpers ───────────────────────────────────────────────────────

  static bool get isAndroid => !kIsWeb && Platform.isAndroid;
  static bool get isIos => !kIsWeb && Platform.isIOS;
}

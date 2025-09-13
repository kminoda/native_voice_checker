import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import 'revenuecat_keys.dart';

class PremiumService extends ChangeNotifier {
  PremiumService._internal();
  static final PremiumService instance = PremiumService._internal();

  static const String monthlyProductId = 'com.native_voice_check.premium.monthly';

  bool _isConfigured = false;
  bool _isPremium = false;
  bool _loading = false;
  String? _price; // localized price text

  bool get isPremium => _isPremium;
  bool get isLoading => _loading;
  String? get price => _price;

  Future<void> ensureConfigured() async {
    if (_isConfigured) return;
    final apiKey = Platform.isIOS ? revenueCatIosApiKey : revenueCatAndroidApiKey;
    if (apiKey.isEmpty) {
      debugPrint('[Premium] RevenueCat API key is empty. Skipping configuration.');
      return;
    }
    try {
      final config = PurchasesConfiguration(apiKey);
      await Purchases.configure(config);
      _isConfigured = true;

      // Listen for updates
      Purchases.addCustomerInfoUpdateListener((customerInfo) {
        _applyCustomerInfo(customerInfo);
      });

      // Initial fetch of customer info
      final info = await Purchases.getCustomerInfo();
      _applyCustomerInfo(info);

      // Preload price
      await _loadPrice();
    } catch (e) {
      debugPrint('[Premium][ERROR] configure failed: $e');
    }
  }

  void _applyCustomerInfo(CustomerInfo info) {
    final hasAnyEntitlement = info.entitlements.active.isNotEmpty;
    if (_isPremium != hasAnyEntitlement) {
      _isPremium = hasAnyEntitlement;
      notifyListeners();
    }
  }

  Future<void> _loadPrice() async {
    try {
      final prods = await Purchases.getProducts([monthlyProductId]);
      if (prods.isNotEmpty) {
        final p = prods.first;
        // StoreProduct has priceString; on older SDKs, use p.priceString too.
        _price = p.priceString;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('[Premium][WARN] load price failed: $e');
    }
  }

  Future<bool> purchaseMonthly() async {
    await ensureConfigured();
    _setLoading(true);
    try {
      // Prefer purchasing by product id directly to avoid Offering setup dependency
      final purchaserInfo = await Purchases.purchaseProduct(monthlyProductId);
      _applyCustomerInfo(purchaserInfo);
      return _isPremium;
    } on PlatformException catch (e) {
      try {
        final code = PurchasesErrorHelper.getErrorCode(e);
        if (code == PurchasesErrorCode.purchaseCancelledError) {
          return false; // user cancelled
        }
      } catch (_) {}
      debugPrint('[Premium][ERROR] purchase failed: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> restore() async {
    await ensureConfigured();
    _setLoading(true);
    try {
      final info = await Purchases.restorePurchases();
      _applyCustomerInfo(info);
      return _isPremium;
    } catch (e) {
      debugPrint('[Premium][ERROR] restore failed: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool v) {
    if (_loading != v) {
      _loading = v;
      notifyListeners();
    }
  }
}

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class PurchaseManager {
  static final PurchaseManager instance = PurchaseManager._init();
  PurchaseManager._init();

  static const String _apiKey = 'appl_hLoMhqnriHSyagYpjTeRASFcJfB';
  static const String premiumEntitlement = 'JumpLab JP Premium';

  bool _isPremium = false;
  bool get isPremium => _isPremium;

  Future<void> initialize() async {
    try {
      await Purchases.setLogLevel(LogLevel.debug);
      PurchasesConfiguration configuration;
      if (Platform.isIOS) {
        configuration = PurchasesConfiguration(_apiKey);
      } else {
        configuration = PurchasesConfiguration(_apiKey);
      }
      await Purchases.configure(configuration);
      await checkPremiumStatus();
    } catch (e) {
      debugPrint('RevenueCat初期化エラー: $e');
    }
  }

  Future<void> checkPremiumStatus() async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      _isPremium = customerInfo.entitlements.active.containsKey(premiumEntitlement);
    } catch (e) {
      debugPrint('プレミアム確認エラー: $e');
      _isPremium = false;
    }
  }

  Future<bool> purchasePremium() async {
    try {
      final offerings = await Purchases.getOfferings();
      if (offerings.current == null) return false;

      final package = offerings.current!.monthly;
      if (package == null) return false;

      final purchaseResult = await Purchases.purchasePackage(package);
      final customerInfo = purchaseResult.customerInfo;
      _isPremium = customerInfo.entitlements.active.containsKey(premiumEntitlement);
      return _isPremium;
    } catch (e) {
      debugPrint('購入エラー: $e');
      return false;
    }
  }

  Future<bool> restorePurchases() async {
    try {
      final customerInfo = await Purchases.restorePurchases();
      _isPremium = customerInfo.entitlements.active.containsKey(premiumEntitlement);
      return _isPremium;
    } catch (e) {
      debugPrint('復元エラー: $e');
      return false;
    }
  }
}

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

  Future<({bool success, String? error})> purchasePremium() async {
    try {
      final offerings = await Purchases.getOfferings();
      if (offerings.current == null) {
        return (success: false, error: '商品情報を取得できませんでした。しばらく後でお試しください。');
      }

      final package = offerings.current!.monthly;
      if (package == null) {
        return (success: false, error: 'プレミアムプランが見つかりませんでした。');
      }

      final result = await Purchases.purchase(PurchaseParams.package(package));
      _isPremium = result.customerInfo.entitlements.active.containsKey(premiumEntitlement);
      return (success: _isPremium, error: null);
    } on PurchasesErrorCode catch (e) {
      if (e == PurchasesErrorCode.purchaseCancelledError) {
        return (success: false, error: null);
      }
      debugPrint('購入エラー: $e');
      return (success: false, error: '購入処理でエラーが発生しました。');
    } catch (e) {
      debugPrint('購入エラー: $e');
      return (success: false, error: '購入処理でエラーが発生しました。');
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

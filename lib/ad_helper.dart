import 'dart:async';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/material.dart';
import 'purchase_manager.dart';
import 'share_manager.dart';

class AdHelper {
  static bool get isAdFree =>
      PurchaseManager.instance.isPremium || ShareManager.instance.hasShared;
  // 本番ID
  static const String bannerAdUnitId =
      'ca-app-pub-9251250149426348/5341111146';
  static const String interstitialAdUnitId =
      'ca-app-pub-9251250149426348/6794627761';

  static BannerAd? createBannerAd() {
    if (isAdFree) return null;
    return BannerAd(
      adUnitId: bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: const BannerAdListener(),
    );
  }

  static Future<InterstitialAd?> loadInterstitialAd() async {
    if (isAdFree) return null;
    InterstitialAd? ad;
    final completer = Completer<void>();

    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd loadedAd) {
          ad = loadedAd;
          completer.complete();
        },
        onAdFailedToLoad: (LoadAdError error) {
          debugPrint('広告の読み込み失敗: $error');
          completer.complete();
        },
      ),
    );
    await completer.future;
    return ad;
  }
}

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';

final adsManagerProvider = Provider<AdsManager>((ref) => AdsManager(ref));

class AdsManager {
  AdsManager(this._ref);
  final Ref _ref;

  BannerAd? _banner;
  DateTime? _lastInterstitial;

  Future<void> initialize() async {
    // Consent handled via platform UMP channel before loading ads.
    // For now, just prepare any state needed.
    if (kDebugMode) {
      debugPrint('AdsManager initialized');
    }
  }

  // Banner
  BannerAd? get banner => _banner;

  void loadBanner({required String adUnitId}) {
    _banner?.dispose();
    _banner = BannerAd(
      size: AdSize.banner,
      adUnitId: adUnitId,
      listener: BannerAdListener(
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          _banner = null;
        },
      ),
      request: const AdRequest(),
    )..load();
  }

  // Interstitial (opt-in, frequency capped)
  Future<bool> canShowInterstitial() async {
    final prefs = await SharedPreferences.getInstance();
    final last = prefs.getInt('ads_last_interstitial');
    final now = DateTime.now();
    if (last == null) return true;
    final delta = now.difference(DateTime.fromMillisecondsSinceEpoch(last));
    return delta.inMinutes >= 60; // 1 per hour
  }

  Future<void> markInterstitialShown() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('ads_last_interstitial', DateTime.now().millisecondsSinceEpoch);
    _lastInterstitial = DateTime.now();
  }
}


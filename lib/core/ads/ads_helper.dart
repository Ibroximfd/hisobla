import 'dart:io';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdsHelper {
  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      // Test ID - ishlab chiqishda
      return 'ca-app-pub-9217530480544704/5060118549';
      // return 'ca-app-pub-XXXXXXXXXXXXXXXX/YYYYYYYYYY';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/2934735716';
    }
    throw UnsupportedError('Unsupported platform');
  }

  static String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      // Test ID - ishlab chiqishda
      return 'ca-app-pub-9217530480544704/7592403807';
      // return 'ca-app-pub-XXXXXXXXXXXXXXXX/ZZZZZZZZZZ';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/4411468910';
    }
    throw UnsupportedError('Unsupported platform');
  }
}

class AdsManager {
  static final AdsManager _instance = AdsManager._internal();
  factory AdsManager() => _instance;
  AdsManager._internal();

  InterstitialAd? _interstitialAd;
  int _actionCounter = 0;
  bool _isInterstitialAdReady = false;

  // Interstitial ad har 2-3 ta amaldan keyin ko'rsatiladi
  static const int _maxActionsBeforeAd = 3;

  Future<void> initialize() async {
    await MobileAds.instance.initialize();
    _loadInterstitialAd();
  }

  void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: AdsHelper.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialAdReady = true;

          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _isInterstitialAdReady = false;
              _loadInterstitialAd(); // Yangi reklama yuklash
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              _isInterstitialAdReady = false;
              _loadInterstitialAd();
            },
          );
        },
        onAdFailedToLoad: (error) {
          _isInterstitialAdReady = false;
          // 5 soniyadan keyin qayta urinish
          Future.delayed(const Duration(seconds: 5), () {
            _loadInterstitialAd();
          });
        },
      ),
    );
  }

  void incrementActionCounter() {
    _actionCounter++;

    if (_actionCounter >= _maxActionsBeforeAd) {
      showInterstitialAd();
      _actionCounter = 0;
    }
  }

  void showInterstitialAd() {
    if (_isInterstitialAdReady && _interstitialAd != null) {
      _interstitialAd!.show();
      _isInterstitialAdReady = false;
      _interstitialAd = null;
    }
  }

  void dispose() {
    _interstitialAd?.dispose();
  }
}

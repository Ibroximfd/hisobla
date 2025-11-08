import 'dart:io';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdsHelper {
  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      // Faqat real ID
      return 'ca-app-pub-9217530480544704/5060118549';
    } else if (Platform.isIOS) {
      // Real iOS ID ni bu yerga qo'ying
      return 'ca-app-pub-9217530480544704/5060118549';
    }
    throw UnsupportedError('Unsupported platform');
  }

  static String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      // Test ID ca-app-pub-3940256099942544/6300978111
      // Faqat real ID 
      return 'ca-app-pub-9217530480544704/7592403807';
    } else if (Platform.isIOS) {
      // Real iOS ID ni bu yerga qo'ying
      return 'ca-app-pub-9217530480544704/7592403807';
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
  bool _isLoadingAd = false;

  // Interstitial ad har 3 ta amaldan keyin ko'rsatiladi
  static const int _maxActionsBeforeAd = 3;

  Future<void> initialize() async {
    try {
      final initResult = await MobileAds.instance.initialize();
      print('📱 AdMob initialized: ${initResult.adapterStatuses}');

      // Initialization tugashini kutish
      await Future.delayed(const Duration(milliseconds: 500));
      _loadInterstitialAd();
    } catch (e) {
      print('❌ AdMob initialization error: $e');
    }
  }

  void _loadInterstitialAd() {
    if (_isLoadingAd || _isInterstitialAdReady) {
      print('⏳ Ad already loading or ready, skipping...');
      return;
    }

    _isLoadingAd = true;
    print('🔄 Loading interstitial ad...');
    print('📍 Ad Unit ID: ${AdsHelper.interstitialAdUnitId}');

    InterstitialAd.load(
      adUnitId: AdsHelper.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          print('✅ Interstitial ad loaded successfully');
          _interstitialAd = ad;
          _isInterstitialAdReady = true;
          _isLoadingAd = false;

          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdShowedFullScreenContent: (ad) {
              print('📺 Ad showed full screen content');
            },
            onAdDismissedFullScreenContent: (ad) {
              print('👋 Ad dismissed');
              ad.dispose();
              _interstitialAd = null;
              _isInterstitialAdReady = false;
              _loadInterstitialAd(); // Yangi reklama yuklash
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              print('❌ Ad failed to show: $error');
              ad.dispose();
              _interstitialAd = null;
              _isInterstitialAdReady = false;
              _isLoadingAd = false;
              _loadInterstitialAd();
            },
            onAdImpression: (ad) {
              print('💰 Ad impression recorded');
            },
          );
        },
        onAdFailedToLoad: (error) {
          print('❌ Ad failed to load: ${error.code} - ${error.message}');
          print('🔍 Domain: ${error.domain}');
          _isInterstitialAdReady = false;
          _isLoadingAd = false;
          _interstitialAd = null;

          // Error code 3 = No fill (reklama mavjud emas)
          // Error code 0 = Internal error
          // Error code 1 = Invalid request
          // Error code 2 = Network error

          // Qayta urinish vaqti
          int retryDelay = 5;
          if (error.code == 3) {
            retryDelay = 30; // No fill uchun uzoqroq kutish
            print(
              '⚠️ No ad inventory available, retrying in $retryDelay seconds',
            );
          }

          Future.delayed(Duration(seconds: retryDelay), () {
            _loadInterstitialAd();
          });
        },
      ),
    );
  }

  void incrementActionCounter() {
    _actionCounter++;
    print('📊 Action counter: $_actionCounter/$_maxActionsBeforeAd');

    if (_actionCounter >= _maxActionsBeforeAd) {
      showInterstitialAd();
      _actionCounter = 0;
    }
  }

  void showInterstitialAd() {
    if (_isInterstitialAdReady && _interstitialAd != null) {
      print('🎬 Showing interstitial ad');
      _interstitialAd!.show();
      _isInterstitialAdReady = false;
      _interstitialAd = null;
    } else {
      print('⚠️ Interstitial ad not ready yet');
      // Agar tayyor bo'lmasa, hozir yuklash
      if (!_isLoadingAd) {
        _loadInterstitialAd();
      }
    }
  }

  void dispose() {
    print('🧹 Disposing ads manager');
    _interstitialAd?.dispose();
    _interstitialAd = null;
  }
}

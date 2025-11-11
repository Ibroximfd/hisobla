import 'dart:io';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdsHelper {
  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-9217530480544704/5060118549';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-9217530480544704/5060118549';
    }
    throw UnsupportedError('Unsupported platform');
  }

  static String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-9217530480544704/7592403807';
    } else if (Platform.isIOS) {
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
  bool _isInitialized = false;

  static const int _maxActionsBeforeAd = 3;

  Future<void> initialize() async {
    if (_isInitialized) {
      print('⚠️ AdMob already initialized');
      return;
    }

    try {
      final initResult = await MobileAds.instance.initialize();
      _isInitialized = true;
      print('📱 AdMob initialized: ${initResult.adapterStatuses}');

      // Birinchi reklamani yuklash
      Future.delayed(const Duration(milliseconds: 500), () {
        _loadInterstitialAd();
      });
    } catch (e) {
      print('❌ AdMob initialization error: $e');
    }
  }

  void _loadInterstitialAd() {
    if (!_isInitialized) {
      print('⚠️ AdMob not initialized yet');
      return;
    }

    if (_isLoadingAd || _isInterstitialAdReady) {
      print('⏳ Ad already loading or ready, skipping...');
      return;
    }

    _isLoadingAd = true;
    print('🔄 Loading interstitial ad...');

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
              _loadInterstitialAd();
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
          _isInterstitialAdReady = false;
          _isLoadingAd = false;
          _interstitialAd = null;

          int retryDelay = 5;
          if (error.code == 3) {
            retryDelay = 30;
            print('⚠️ No ad inventory, retrying in $retryDelay seconds');
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
      if (!_isLoadingAd && _isInitialized) {
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

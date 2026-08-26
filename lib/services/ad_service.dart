import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../config/ad_config.dart';

class AdService {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  InterstitialAd? _interstitialAd;
  bool _isInterstitialLoading = false;

  RewardedAd? _rewardedAd;
  bool _isRewardedLoading = false;

  /// Initializes Google Mobile Ads SDK and requests UMP consent
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Initialize UMP Consent Information
      final consentParams = ConsentRequestParameters();
      ConsentInformation.instance.requestConsentInfoUpdate(
        consentParams,
        () async {
          ConsentForm.loadAndShowConsentFormIfRequired((formError) async {
            await _initMobileAds();
          });
        },
        (FormError error) async {
          debugPrint('UMP Consent request failed: ${error.message}');
          await _initMobileAds();
        },
      );
    } catch (e) {
      debugPrint('AdMob Consent initialization error: $e');
      await _initMobileAds();
    }
  }

  Future<void> _initMobileAds() async {
    try {
      await MobileAds.instance.initialize();
      _isInitialized = true;
      debugPrint('AdMob SDK initialized successfully');

      // Preload initial interstitial and rewarded ads
      if (AdConfig.enableInterstitialAds) {
        loadInterstitial();
      }
      if (AdConfig.enableRewardedAds) {
        loadRewarded();
      }
    } catch (e) {
      debugPrint('MobileAds initialization failed: $e');
    }
  }

  /// Preloads an Interstitial Ad
  void loadInterstitial() {
    if (!_isInitialized ||
        _isInterstitialLoading ||
        _interstitialAd != null ||
        !AdConfig.enableInterstitialAds) {
      return;
    }

    _isInterstitialLoading = true;
    InterstitialAd.load(
      adUnitId: AdConfig.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialLoading = false;
          debugPrint('Interstitial ad loaded');

          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _interstitialAd = null;
              loadInterstitial(); // Preload next
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              _interstitialAd = null;
              loadInterstitial();
            },
          );
        },
        onAdFailedToLoad: (error) {
          _isInterstitialLoading = false;
          _interstitialAd = null;
          debugPrint('Interstitial ad failed to load: ${error.message}');
        },
      ),
    );
  }

  /// Shows an interstitial ad if available and eligible
  bool showInterstitialIfReady({VoidCallback? onClosed}) {
    if (_interstitialAd != null) {
      final ad = _interstitialAd!;
      _interstitialAd = null;

      ad.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          onClosed?.call();
          loadInterstitial();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          onClosed?.call();
          loadInterstitial();
        },
      );

      ad.show();
      return true;
    } else {
      loadInterstitial();
      onClosed?.call();
      return false;
    }
  }

  /// Preloads a Rewarded Ad
  void loadRewarded() {
    if (!_isInitialized ||
        _isRewardedLoading ||
        _rewardedAd != null ||
        !AdConfig.enableRewardedAds) {
      return;
    }

    _isRewardedLoading = true;
    RewardedAd.load(
      adUnitId: AdConfig.rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isRewardedLoading = false;
          debugPrint('Rewarded ad loaded');

          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _rewardedAd = null;
              loadRewarded(); // Preload next
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              _rewardedAd = null;
              loadRewarded();
            },
          );
        },
        onAdFailedToLoad: (error) {
          _isRewardedLoading = false;
          _rewardedAd = null;
          debugPrint('Rewarded ad failed to load: ${error.message}');
        },
      ),
    );
  }

  /// Shows a rewarded ad. Executes [onRewarded] only upon verified reward callback.
  void showRewardedAd({
    required VoidCallback onRewarded,
    VoidCallback? onFailed,
    VoidCallback? onDismissed,
  }) {
    if (_rewardedAd != null) {
      final ad = _rewardedAd!;
      _rewardedAd = null;
      bool userEarnedReward = false;

      ad.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          if (userEarnedReward) {
            onRewarded();
          } else {
            onDismissed?.call();
          }
          loadRewarded();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          onFailed?.call();
          loadRewarded();
        },
      );

      ad.show(
        onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
          userEarnedReward = true;
          debugPrint('User earned reward: ${reward.amount} ${reward.type}');
        },
      );
    } else {
      // Ad is not yet loaded, try loading for next time
      loadRewarded();
      onFailed?.call();
    }
  }

  bool get isRewardedAdReady => _rewardedAd != null;

  void dispose() {
    _interstitialAd?.dispose();
    _interstitialAd = null;
    _rewardedAd?.dispose();
    _rewardedAd = null;
  }
}

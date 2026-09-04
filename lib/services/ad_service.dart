import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../config/ad_config.dart';

class AdService {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  final Completer<void> _initCompleter = Completer<void>();

  /// Future that completes when the AdMob SDK is initialized.
  Future<void> get ensureInitialized => _initCompleter.future;

  InterstitialAd? _interstitialAd;
  bool _isInterstitialLoading = false;

  RewardedAd? _rewardedAd;
  bool _isRewardedLoading = false;

  /// Initializes Google Mobile Ads SDK and requests UMP consent
  Future<void> initialize() async {
    if (_isInitialized) {
      if (!_initCompleter.isCompleted) _initCompleter.complete();
      return;
    }

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
      if (!_initCompleter.isCompleted) _initCompleter.complete();
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
      if (!_initCompleter.isCompleted) _initCompleter.complete();
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

  /// Shows a rewarded ad. If the ad isn't ready yet, waits up to ~4.5 seconds
  /// (3 retries × 1.5s) for it to load before giving up.
  /// Executes [onRewarded] only upon verified reward callback.
  void showRewardedAd({
    required VoidCallback onRewarded,
    VoidCallback? onFailed,
    VoidCallback? onDismissed,
  }) {
    if (_rewardedAd != null) {
      _showRewardedAdNow(
        onRewarded: onRewarded,
        onFailed: onFailed,
        onDismissed: onDismissed,
      );
    } else {
      // Ad is not ready — kick off a load and wait for it
      loadRewarded();
      _waitForRewardedAd(
        onRewarded: onRewarded,
        onFailed: onFailed,
        onDismissed: onDismissed,
      );
    }
  }

  /// Internal: actually shows the loaded rewarded ad.
  void _showRewardedAdNow({
    required VoidCallback onRewarded,
    VoidCallback? onFailed,
    VoidCallback? onDismissed,
  }) {
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
  }

  /// Waits for the rewarded ad to load with retries.
  /// Retries up to [maxRetries] times with [retryDelay] between attempts.
  void _waitForRewardedAd({
    required VoidCallback onRewarded,
    VoidCallback? onFailed,
    VoidCallback? onDismissed,
    int maxRetries = 3,
    Duration retryDelay = const Duration(milliseconds: 1500),
  }) {
    int attempt = 0;

    void tryAgain() {
      attempt++;
      Future.delayed(retryDelay, () {
        if (_rewardedAd != null) {
          _showRewardedAdNow(
            onRewarded: onRewarded,
            onFailed: onFailed,
            onDismissed: onDismissed,
          );
        } else if (attempt < maxRetries) {
          // Ensure a load is in progress
          loadRewarded();
          tryAgain();
        } else {
          // Exhausted retries — give up
          debugPrint('Rewarded ad failed to load after $maxRetries retries');
          onFailed?.call();
        }
      });
    }

    tryAgain();
  }

  bool get isRewardedAdReady => _rewardedAd != null;

  void dispose() {
    _interstitialAd?.dispose();
    _interstitialAd = null;
    _rewardedAd?.dispose();
    _rewardedAd = null;
  }
}


class AdConfig {
  /// Set to false to use your real AdMob Ad Units (matching your AndroidManifest App ID)
  static const bool isTestMode = false;

  // Google's Official Test Ad Unit IDs for Android
  static const String testBannerAdUnitId =
      'ca-app-pub-3940256099942544/6300978111';
  static const String testInterstitialAdUnitId =
      'ca-app-pub-3940256099942544/1033173712';
  static const String testRewardedAdUnitId =
      'ca-app-pub-3940256099942544/5224354917';

  // Production Ad Unit IDs
  static const String prodBannerAdUnitId =
      'ca-app-pub-3021631976531996/8815401773';
  static const String prodInterstitialAdUnitId =
      'ca-app-pub-3021631976531996/4876156765';
  static const String prodRewardedAdUnitId =
      'ca-app-pub-3021631976531996/5536783111';

  /// Get active banner ad unit id based on test / production configuration
  static String get bannerAdUnitId =>
      isTestMode ? testBannerAdUnitId : prodBannerAdUnitId;

  /// Get active interstitial ad unit id
  static String get interstitialAdUnitId =>
      isTestMode ? testInterstitialAdUnitId : prodInterstitialAdUnitId;

  /// Get active rewarded ad unit id
  static String get rewardedAdUnitId =>
      isTestMode ? testRewardedAdUnitId : prodRewardedAdUnitId;

  // Ad Placement & Frequency Configuration
  static const int interstitialEveryNGames = 3;
  static const bool enableBannerAds = true;
  static const bool enableRewardedAds = true;
  static const bool enableInterstitialAds = true;

  // Privacy Policy URL - Replace with your live Privacy Policy URL
  static const String privacyPolicyUrl =
      'https://example.com/2048-privacy-policy';
}

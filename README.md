# 2048 Neo - Sliding Tile Puzzle with Google AdMob Monetization

A complete, polished, and production-ready mobile implementation of the classic **2048** puzzle game built with Flutter and Dart, featuring a unique **Neo-Aurora Glassmorphism** design and non-intrusive **Google AdMob monetization**.

---

## 🎮 Features

- **Unique Neo-Aurora Glassmorphism UI**: Ambient dark obsidian backdrop (`#090D16`), glowing jewel gradient tiles, frosted glass borders, and radiant lighting.
- **Built-in Theme Switcher**:
  - **Neo-Aurora (Default)**: Dark glassmorphic mode with luminous neon jewel tiles.
  - **Cyberpunk Synthwave**: Neon magenta, cyan laser grid, and electric yellow styling.
  - **Classic Warm**: Retro beige/brown 2048 aesthetic.
- **Strict 2048 Algorithm**: Non-cascading merge rules, random tile spawns (90% for 2, 10% for 4), score multiplier tracking, game-over, and win detection.
- **Smooth Animations**: Animated sliding tiles, scale merge pop, spawn scale/fade, and floating $+X$ score animations.
- **Non-Intrusive Google AdMob Monetization**:
  - **Adaptive Anchored Banner**: Automatically sizes to device width at the bottom of the screen without covering the board or tiles.
  - **Rewarded Ad for +1 Undo**: Players can watch a video ad to earn bonus Undos.
  - **Rewarded Ad for Game Over Continue**: Revives the game once per match so players can keep their progress.
  - **Capped Interstitials**: Frequency-controlled interstitial ads appearing only after every 3 completed games on "New Game".
  - **Remove Ads Option**: Built-in architecture to disable banners & interstitials.
- **Offline & Persistence**: 100% playable offline without crashing. Saves best score, board state, undo history, bonus undos, and audio settings via `shared_preferences`.

---

## 📂 Project Architecture

```text
lib/
 ├── config/
 │    └── ad_config.dart               # Centralized AdMob unit IDs, test mode switch, and frequency settings
 │
 ├── services/
 │    ├── ad_service.dart              # AdMob SDK init, UMP Consent, banner/interstitial/rewarded lifecycle
 │    ├── storage_service.dart         # Local storage with SharedPreferences
 │    └── audio_feedback_service.dart  # Sound & haptic triggers
 │
 ├── models/
 │    ├── tile.dart                    # Tile model with unique ID, position, and JSON serialization
 │    └── game_snapshot.dart           # Snapshot model for Undo and state persistence
 │
 ├── game/
 │    ├── game_logic.dart              # Pure Dart functional 2048 algorithm & tests
 │    └── game_controller.dart         # ChangeNotifier managing state, ads, score, and undos
 │
 ├── theme/
 │    └── app_theme.dart               # Multi-theme engine, jewel gradients, and typography
 │
 ├── widgets/
 │    ├── ad_banner.dart               # Anchored adaptive banner ad widget
 │    ├── game_board_widget.dart       # 4x4 grid board with swipe gestures & keyboard controls
 │    ├── game_tile_widget.dart        # Animated tile widget with sliding, scale pop, and glow
 │    ├── score_box.dart               # Glassmorphic score card with floating increment badges
 │    ├── game_overlays.dart           # Game Over (with Rewarded Continue) and You Win overlays
 │    └── settings_dialog.dart         # Settings with Theme Picker, Remove Ads, and Privacy Policy
 │
 └── screens/
      └── game_screen.dart             # Responsive main game screen
```

---

## 💰 AdMob Setup & Configuration Guide

### 1. Create AdMob Account & App
1. Go to [Google AdMob Console](https://admob.google.com/).
2. Click **Apps** → **Add App** → Select **Android** → Choose whether your app is listed on Google Play.
3. Name your app (e.g. `2048 Neo`) and copy your **AdMob App ID** (format: `ca-app-pub-XXXXXXXXXXXXXXXX~XXXXXXXXXX`).

### 2. Configure AndroidManifest.xml
Open `android/app/src/main/AndroidManifest.xml` and replace the test App ID with your real App ID:
```xml
<meta-data
    android:name="com.google.android.gms.ads.APPLICATION_ID"
    android:value="ca-app-pub-YOUR_APP_ID~YOUR_APP_ID"/>
```

### 3. Create Ad Units in AdMob Console
1. **Banner Ad Unit**:
   - Format: *Banner*
   - Name: `Main Screen Adaptive Banner`
   - Copy Ad Unit ID: `ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX`
2. **Interstitial Ad Unit**:
   - Format: *Interstitial*
   - Name: `Game Over Interstitial`
   - Copy Ad Unit ID: `ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX`
3. **Rewarded Ad Unit**:
   - Format: *Rewarded*
   - Name: `Rewarded Undo and Continue`
   - Copy Ad Unit ID: `ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX`

### 4. Update `lib/config/ad_config.dart`
Paste your production Ad Unit IDs and Privacy Policy URL into [lib/config/ad_config.dart](file:///g:/2048/game_2048/lib/config/ad_config.dart):
```dart
class AdConfig {
  // Set to false for production release builds:
  static const bool isTestMode = false;

  // Production Ad Unit IDs:
  static const String prodBannerAdUnitId = 'ca-app-pub-YOUR_PUBLISHER_ID/BANNER_ID';
  static const String prodInterstitialAdUnitId = 'ca-app-pub-YOUR_PUBLISHER_ID/INTERSTITIAL_ID';
  static const String prodRewardedAdUnitId = 'ca-app-pub-YOUR_PUBLISHER_ID/REWARDED_ID';

  // Live Privacy Policy URL:
  static const String privacyPolicyUrl = 'https://yourdomain.com/privacy-policy';
}
```

### 5. Testing Without Policy Violations
- During development and internal testing, leave `isTestMode = true` to use Google's official sample Ad Unit IDs.
- Never click or interact with live production ads on your personal devices.

---

## 🚀 Getting Started

### 1. Install Dependencies
```bash
flutter pub get
```

### 2. Run the App Locally
```bash
flutter run
```

### 3. Run Static Analysis & Tests
```bash
flutter analyze
flutter test
```

### 4. Build for Android Release
```bash
flutter build apk --release
flutter build appbundle --release
```

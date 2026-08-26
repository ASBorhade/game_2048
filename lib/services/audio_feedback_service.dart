import 'package:flutter/services.dart';

class AudioFeedbackService {
  bool isSoundEnabled;
  bool isVibrationEnabled;

  AudioFeedbackService({
    this.isSoundEnabled = true,
    this.isVibrationEnabled = true,
  });

  void playMove() {
    if (isSoundEnabled) {
      SystemSound.play(SystemSoundType.click);
    }
    if (isVibrationEnabled) {
      HapticFeedback.selectionClick();
    }
  }

  void playMerge() {
    if (isSoundEnabled) {
      SystemSound.play(SystemSoundType.click);
    }
    if (isVibrationEnabled) {
      HapticFeedback.lightImpact();
    }
  }

  void playWin() {
    if (isSoundEnabled) {
      SystemSound.play(SystemSoundType.alert);
    }
    if (isVibrationEnabled) {
      HapticFeedback.mediumImpact();
    }
  }

  void playGameOver() {
    if (isSoundEnabled) {
      SystemSound.play(SystemSoundType.alert);
    }
    if (isVibrationEnabled) {
      HapticFeedback.heavyImpact();
    }
  }
}

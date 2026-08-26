import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'game/game_controller.dart';
import 'screens/game_screen.dart';
import 'services/ad_service.dart';
import 'services/audio_feedback_service.dart';
import 'services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Google Mobile Ads & UMP Consent in background
  AdService().initialize();

  // Set portrait orientation lock
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style to match beige background
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF090D16),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  final storageService = await StorageService.init();
  final audioService = AudioFeedbackService();
  final gameController = GameController(
    storageService: storageService,
    audioService: audioService,
  )..init();

  runApp(Game2048App(controller: gameController));
}

class Game2048App extends StatelessWidget {
  final GameController controller;

  const Game2048App({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '2048 Neo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF090D16),
        fontFamily: 'sans-serif',
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF38BDF8),
          surface: Color(0xFF090D16),
        ),
      ),
      home: GameScreen(controller: controller),
    );
  }
}

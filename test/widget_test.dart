import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:game_2048/main.dart';
import 'package:game_2048/game/game_controller.dart';
import 'package:game_2048/services/storage_service.dart';
import 'package:game_2048/services/audio_feedback_service.dart';

void main() {
  testWidgets('2048 UI & Gamification smoke test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final storageService = StorageService(prefs);
    final audioService = AudioFeedbackService();
    final controller = GameController(
      storageService: storageService,
      audioService: audioService,
    )..init();

    await tester.pumpWidget(Game2048App(controller: controller));
    await tester.pumpAndSettle();

    // Verify 2048 Header title exists
    expect(find.text('2048'), findsOneWidget);

    // Verify Score and Best labels exist
    expect(find.text('SCORE'), findsOneWidget);
    expect(find.text('BEST'), findsOneWidget);

    // Verify Power-Up dock buttons exist
    expect(find.text('Undo'), findsOneWidget);
    expect(find.text('Hammer'), findsOneWidget);
    expect(find.text('Shuffle'), findsOneWidget);
    expect(find.text('AI Hint'), findsOneWidget);

    // Verify 2 starting tiles exist
    expect(controller.tiles.length, 2);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:led_scroller/main.dart';
import 'package:led_scroller/models/led_config.dart';
import 'package:led_scroller/screens/fullscreen_led_screen.dart';
import 'package:led_scroller/widgets/led_display_widget.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('LedScrollerApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const LedScrollerApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('Letrero LED Pro'), findsOneWidget);
    expect(find.text('INICIAR LETRERO EN PANTALLA COMPLETA'), findsOneWidget);
  });

  testWidgets('Open FullscreenLedScreen and verify HUD controls and exit',
      (WidgetTester tester) async {
    await tester.pumpWidget(const LedScrollerApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    final launchBtn = find.text('INICIAR LETRERO EN PANTALLA COMPLETA');
    expect(launchBtn, findsOneWidget);
    await tester.tap(launchBtn);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    // Fullscreen screen is present
    expect(find.byType(FullscreenLedScreen), findsOneWidget);

    // Verify HUD is visible and has controls
    final pauseBtn = find.byTooltip('Pausar');
    expect(pauseBtn, findsOneWidget);
    await tester.tap(pauseBtn);
    await tester.pump();

    // Verify pause changed to resume
    expect(find.byTooltip('Reanudar'), findsOneWidget);

    // Tap back exit button
    final exitBtn = find.byType(FloatingActionButton);
    expect(exitBtn, findsOneWidget);
    await tester.tap(exitBtn);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // Returned to studio
    expect(find.text('Letrero LED Pro'), findsOneWidget);
  });

  testWidgets('LedDisplayWidget renders all scroll directions & matrix styles',
      (WidgetTester tester) async {
    for (final dir in ScrollDirection.values) {
      for (final style in LedMatrixStyle.values) {
        final config = LedBannerConfig(
          id: 'test_${dir.name}_${style.name}',
          text: '🔥 TEST 100% 🚀',
          direction: dir,
          matrixStyle: style,
          isRainbow: true,
          fontSize: 80.0,
          speed: 5.0,
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 400,
                height: 200,
                child: LedDisplayWidget(config: config, isFullScreen: true),
              ),
            ),
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.byType(LedDisplayWidget), findsOneWidget);
      }
    }
  });
}

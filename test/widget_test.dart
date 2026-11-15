import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:led_scroller/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('LedScrollerApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const LedScrollerApp());
    // Pump frames with fixed duration to advance animation safely
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('Letrero LED Pro'), findsOneWidget);
    expect(find.text('INICIAR LETRERO EN PANTALLA COMPLETA'), findsOneWidget);
  });
}

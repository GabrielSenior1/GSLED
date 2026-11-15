import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:led_scroller/main.dart';

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
}

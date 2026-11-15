import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/studio_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set default preferred orientations for the studio/editor (allow portrait & landscape)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  // Set system UI overlay style to dark
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF10141E),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const LedScrollerApp());
}

class LedScrollerApp extends StatelessWidget {
  const LedScrollerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Letrero LED Pro',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0B0E14),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF00FF66),
          secondary: Color(0xFF00E5FF),
          surface: Color(0xFF141924),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF10141E),
          elevation: 0,
          centerTitle: false,
        ),
        useMaterial3: true,
      ),
      home: const StudioScreen(),
    );
  }
}

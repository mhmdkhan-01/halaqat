import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:halaqat/features/auth/presentation/login_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized(); // 1. Initialize Localization

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('ur')],
      path: 'assets/translations', // Path to your JSON files
      fallbackLocale: const Locale('en'),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Halaqat',
      // 2. Link easy_localization delegates to MaterialApp
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(
          0xFFF6F8F6,
        ), // Cool, soft background
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0A5C36),
          primary: const Color(0xFF0A5C36),
          secondary: const Color(0xFF10B981),
          surface: Colors.white,
        ),
        useMaterial3: true,
        // Make all AppBars have a clean, transparent iOS feel
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: false,
          iconTheme: IconThemeData(color: Color(0xFF0A5C36)),
          titleTextStyle: TextStyle(
            color: Color(0xFF0A5C36),
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      // Temporarily loading our entry screen for a student named "Hussein"
      home: const SplashScreen(),
    );
  }
}

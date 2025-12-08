import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/app_config.dart';
import 'screens/welcome_screen.dart';
import 'providers/voice_provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => VoiceProvider(),
      child: const ButeykoWorldApp(),
    ),
  );
}

class ButeykoWorldApp extends StatelessWidget {
  const ButeykoWorldApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConfig.appName,
      theme: ThemeData(
        primaryColor: const Color(AppConfig.primaryBlue),
        colorScheme: ColorScheme.light(
          primary: const Color(AppConfig.primaryBlue),
          secondary: const Color(AppConfig.secondaryMint),
          surface: Colors.white,
        ),
        fontFamily: 'Roboto',
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.w300,
            color: Color(AppConfig.primaryBlue),
          ),
          bodyLarge: TextStyle(
            fontSize: 18,
            color: Colors.black87,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(AppConfig.primaryBlue),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.white),
        ),
      ),
      home: const WelcomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}



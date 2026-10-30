import 'package:flutter/material.dart';
import 'features/auth/login_screen.dart';

class NewsIntelligenceApp extends StatelessWidget {
  const NewsIntelligenceApp({super.key});

  @override
  Widget build(BuildContext context) {
    const ink = Color(0xFF17243A);
    return MaterialApp(
      title: 'Briefly — News Intelligence',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF315CBA)),
        scaffoldBackgroundColor: const Color(0xFFF6F7FA),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF6F7FA),
          foregroundColor: ink,
          centerTitle: false,
          elevation: 0,
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        ),
      ),
      home: const LoginScreen(),
    );
  }
}

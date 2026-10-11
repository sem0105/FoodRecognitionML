import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const FoodLensApp());
}

class FoodLensApp extends StatelessWidget {
  const FoodLensApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FoodLens',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E5631), // Forest Green
          primary: const Color(0xFF1E5631),
          secondary: const Color(0xFFFF6F61), // Coral
          surface: const Color(0xFFFAF9F6), // Warm cream / off-white
        ),
        scaffoldBackgroundColor: const Color(0xFFFAF9F6),
        fontFamily: 'Roboto',
      ),
      home: const HomeScreen(),
    );
  }
}

import 'package:flutter/material.dart';
import 'core/screens/welcome/welcome_screen.dart';
import 'core/screens/onboarding/onboarding_screen.dart';

void main() {
  runApp(const RestaurantApp());
}

class RestaurantApp extends StatelessWidget {
  const RestaurantApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,

      home: OnboardingScreen(),
    );
  }
}

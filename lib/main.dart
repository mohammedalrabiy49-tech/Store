import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:resturnt_app/home_screen.dart';
import 'orders_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Resturnt App',
      theme: ThemeData(primarySwatch: Colors.green, useMaterial3: true),
      // حيبدأ التطبيق مباشرة من شاشة الطلبات اللي بنعدل عليها
      home: const HomeScreen(),
    );
  }
}

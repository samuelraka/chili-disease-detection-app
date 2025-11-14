import 'package:flutter/material.dart';
import 'pages/main_page.dart';
import 'pages/model_test_page.dart';
import 'pages/splash_screen.dart';   
import 'pages/onboarding_page.dart';
import 'pages/input_nama_page.dart';  

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Deteksi Penyakit Cabai',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/onboarding': (context) => const OnboardingPage(),
        '/main': (context) => const MainPage(),
        '/model-test': (context) => const ModelTestPage(),
        '/input-nama': (context) => const InputNamaPage(),
      },
    );
  }
}

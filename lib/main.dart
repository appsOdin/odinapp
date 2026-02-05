import 'package:flutter/material.dart';
import '../views/login_page.dart';
import 'views/home_page.dart';
import 'views/register_page.dart';
import 'theme/app_theme.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Radiadores Odin',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.themeData,
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginPage(),
        '/home': (context) => const HomePage(),
        '/register': (context) => const RegisterPage(),
      },
    );
  }
}
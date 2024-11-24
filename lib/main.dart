import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:studysama/page/base/base_page.dart';
import 'package:studysama/page/base/home/home_page.dart';
import 'package:studysama/page/auth/login_page.dart';
import 'package:studysama/theme/app_theme.dart';
import 'package:studysama/utils/colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'StudySama dev',
      theme: AppTheme.lightTheme, // Light Theme
      darkTheme: AppTheme.darkTheme, // Dark Theme
      themeMode: ThemeMode.system, // Use system settings
      initialRoute: '/',
      routes: {
        '/': (context) => BasePage(), //start page
        '/home': (context) => BasePage(),
      },
    );
  }
}

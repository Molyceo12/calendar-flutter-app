import 'package:flutter/material.dart';
import 'package:calendar_app/theme/app_theme.dart';
import 'package:calendar_app/screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Calendar App',
      theme: AppTheme.lightTheme,
      home: const HomeScreen(),
    );
  }
}

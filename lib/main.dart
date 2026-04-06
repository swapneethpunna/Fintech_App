// main.dart
import 'package:backtesting_app/utils/app_theme.dart';
import 'package:backtesting_app/back_testing_page.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(
    const BacktestingApp(),
  );
}

class BacktestingApp extends StatelessWidget {
  const BacktestingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ModernAlgos Backtesting',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const BacktestingPage(),
    );
  }
}
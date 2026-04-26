import 'package:flutter/material.dart';
import 'package:mini_finance_manager/core/theme/app_theme.dart';
import 'features/home/presentation/home_page.dart';

class FinanceApp extends StatelessWidget {
  const FinanceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mini Finance Manager',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,

      home: const HomePage(),
    );
  }
}

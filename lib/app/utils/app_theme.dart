import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppThemes {
  // الثيم الفاتح
  static final lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: Colors.white,
    // يفرض اللون الأسود على النصوص في الوضع الفاتح
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.black),
      bodyMedium: TextStyle(color: Colors.black87),
    ),
  );

  // الثيم الداكن
  static final darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: AppColors.primary,
    // اللون الداكن المريح (نفس الذي ظهر في صورتك الأخيرة)
    scaffoldBackgroundColor: const Color(0xFF1F172A),
    // يفرض اللون الأبيض على النصوص في الوضع الداكن
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.white),
      bodyMedium: TextStyle(color: Colors.white70),
    ),
  );
}

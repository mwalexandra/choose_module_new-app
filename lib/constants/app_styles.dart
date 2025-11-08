import 'package:flutter/material.dart';
import 'app_colors.dart';

// Fonts
class AppTextStyles {
  // Заголовок
  static TextStyle heading({bool isDark = false}) => TextStyle(
        fontFamily: 'Roboto',
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
      );

  // Подзаголовок
  static TextStyle subheading({bool isDark = false}) => TextStyle(
        fontFamily: 'Roboto Condensed',
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
      );

  // Основной текст
  static TextStyle body({bool isDark = false}) => TextStyle(
        fontFamily: 'Roboto',
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
      );

  // Текст на кнопках
  static TextStyle button({bool isDark = false}) => TextStyle(
        fontFamily: 'Roboto Condensed',
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      );
}

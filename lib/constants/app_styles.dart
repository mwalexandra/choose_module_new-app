import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  // Заголовок
  static TextStyle heading(BuildContext context) => TextStyle(
        fontFamily: 'Roboto',
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary(context),
      );

  // Подзаголовок
  static TextStyle subheading(BuildContext context) => TextStyle(
        fontFamily: 'Roboto Condensed',
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary(context),
      );

  // Основной текст
  static TextStyle body(BuildContext context) => TextStyle(
        fontFamily: 'Roboto',
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: AppColors.textPrimary(context),
      );

  // Текст на кнопках
  static TextStyle button(BuildContext context) => TextStyle(
        fontFamily: 'Roboto Condensed',
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      );
}

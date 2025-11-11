import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  // Überschrift
  static TextStyle heading(BuildContext context) => TextStyle(
        fontFamily: 'Roboto',
        fontSize: 24,
        fontWeight: FontWeight.normal,
        color: AppColors.textPrimary(context),
      );

  // Unterüberschrift
  static TextStyle subheading(BuildContext context) => TextStyle(
        fontFamily: 'Roboto Condensed',
        fontSize: 20,
        fontWeight: FontWeight.normal,
        color: AppColors.textPrimary(context),
      );

  // Haupttext
  static TextStyle body(BuildContext context) => TextStyle(
        fontFamily: 'Roboto',
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: AppColors.textPrimary(context),
      );

  // Text auf Schaltflächen
  static TextStyle button(BuildContext context) => TextStyle(
        fontFamily: 'Roboto Condensed',
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: AppColors.textPrimaryOpposite(context),
      );
}

import 'package:flutter/material.dart';

class AppColors {
  // Основные цвета
  static const primary = Color.fromRGBO(85, 171, 38, 0.8);
  static const secondary = Color.fromRGBO(161, 16, 114, 1);
  static const success = Color.fromRGBO(5, 92, 43, 0.941);
  static const error = Color.fromRGBO(196, 31, 13, 1);
  static const warning = Color.fromRGBO(173, 27, 11, 1);
  static const white = Color.fromRGBO(255, 255, 255, 1);

  // Светлая тема
  static const _lightBackgroundMain = Color.fromRGBO(255, 255, 255, 1);
  static const _lightBackgroundSubtle = Color.fromRGBO(246, 246, 246, 1);
  static const _lightCard = Color.fromRGBO(255, 255, 255, 1);
  static const _lightTextPrimary = Color.fromRGBO(0, 0, 0, 1);
  static const _lightTextSecondary = Color.fromRGBO(114, 114, 114, 1);
  static const _lightTextDisabled = Color.fromRGBO(184, 184, 184, 1);
  static const _lightBorderLight = Color.fromRGBO(224, 224, 223, 1);
  static const _lightBorderStrong = Color.fromRGBO(24, 70, 55, 1);

  // Тёмная тема
  static const _darkBackgroundMain = Color.fromRGBO(18, 18, 18, 1);
  static const _darkBackgroundSubtle = Color.fromRGBO(31, 45, 38, 1);
  static const _darkCard = Color.fromRGBO(31, 45, 38, 1);
  static const _darkTextPrimary = Color.fromRGBO(255, 255, 255, 1);
  static const _darkTextSecondary = Color.fromRGBO(184, 184, 184, 1);
  static const _darkTextDisabled = Color.fromRGBO(114, 114, 114, 1);
  static const _darkBorderLight = Color.fromRGBO(58, 58, 58, 1);
  static const _darkBorderStrong = Color.fromRGBO(84, 171, 38, 1);

  // Получение цвета в зависимости от темы
  static Color backgroundMain(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? _darkBackgroundMain
          : _lightBackgroundMain;

  static Color backgroundSubtle(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? _darkBackgroundSubtle
          : _lightBackgroundSubtle;

  static Color card(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? _darkCard : _lightCard;

  static Color textPrimary(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? _darkTextPrimary
          : _lightTextPrimary;

  static Color textPrimaryOpposite(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? _lightTextPrimary
          : _darkTextPrimary;

  static Color textSecondary(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? _darkTextSecondary
          : _lightTextSecondary;

  static Color textDisabled(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? _darkTextDisabled
          : _lightTextDisabled;

  static Color borderLight(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? _darkBorderLight
          : _lightBorderLight;

  static Color borderStrong(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? _darkBorderStrong
          : _lightBorderStrong;

  static Color sectionHeaderInactive(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Color.fromRGBO(255, 255, 255, 0.00) // лёгкая подсветка в dark
        : Color.fromRGBO(0, 0, 0, 0.00); // лёгкая подсветка в light
  }

  static Color sectionHeaderActive(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Color.fromRGBO(255, 255, 255, 0.00) // более заметная подсветка в dark
        : Color.fromRGBO(0, 0, 0, 0.00); // более заметная подсветка в light
  }
}



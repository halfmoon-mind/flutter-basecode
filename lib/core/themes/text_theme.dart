import 'package:flutter/material.dart';
import 'package:template/core/constants/asset_constant.dart';

TextTheme appTextTheme() {
  return TextTheme(
    displayLarge: TextStyle(
      fontSize: 94,
      fontWeight: FontWeight.w300,
      letterSpacing: -1.5,
      fontFamily: pretendardFontFamily,
    ),
    displayMedium: TextStyle(
      fontSize: 59,
      fontWeight: FontWeight.w300,
      letterSpacing: -0.5,
      fontFamily: pretendardFontFamily,
    ),
    displaySmall: TextStyle(
      fontSize: 47,
      fontWeight: FontWeight.w400,
      fontFamily: pretendardFontFamily,
    ),
    headlineSmall: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w400,
      fontFamily: pretendardFontFamily,
    ),
    titleLarge: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.15,
      fontFamily: pretendardFontFamily,
    ),
    titleMedium: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.15,
      fontFamily: pretendardFontFamily,
    ),
    titleSmall: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.1,
      fontFamily: pretendardFontFamily,
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.5,
      fontFamily: pretendardFontFamily,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.25,
      fontFamily: pretendardFontFamily,
    ),
    labelLarge: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      letterSpacing: 1.25,
      fontFamily: pretendardFontFamily,
    ),
    bodySmall: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.4,
      fontFamily: pretendardFontFamily,
    ),
    labelSmall: TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.w400,
      letterSpacing: 1.5,
      fontFamily: pretendardFontFamily,
    ),
  );
}

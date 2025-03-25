import 'package:flutter/material.dart';

const mainAccentColor = Color(0xff6446ff);
const paleAccentColor = Color(0xffBFC6FA);
const subAccentColor = Color(0xff5293FF);
const red900 = Color(0xffFF402F);
const red600 = Color(0xffFF6450);
const gray900 = Color(0xff1B1D1F);
const gray600 = Color(0xff454C53);
const gray400 = Color(0xff878EA1);
const gray200 = Color(0xffC9CDD2);
const gray100 = Color(0xffE8EBED);
const background = Color(0xffEDF3FB);

ColorScheme appColorScheme() {
  return ColorScheme(
    brightness: Brightness.light,
    primary: mainAccentColor,
    onPrimary: mainAccentColor,
    secondary: subAccentColor,
    onSecondary: subAccentColor,
    surface: background,
    onSurface: gray900,
    outline: gray200,
    error: red900,
    onError: red900,
  );
}

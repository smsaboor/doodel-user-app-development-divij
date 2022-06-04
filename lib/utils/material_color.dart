import 'package:flutter/material.dart';

class MyColors {
  // This class is not meant to be instantiated or extended; this constructor
  // prevents instantiation and extension.
  MyColors._();

  static const MaterialColor appColor = MaterialColor(
    _appPrimaryValue,
    <int, Color>{
      50: Color(0xFFD9E2F8),
      100: Color(0xFF91A9E6),
      200: Color(0xFF7293E5),
      300: Color(0xFF416DDD),
      400: Color(0xFF2D60E3),
      500: Color(_appPrimaryValue),
      600: Color(0xFF1244C6),
      700: Color(0xFF0B3AB1),
      800: Color(0xFF0C37A5),
      900: Color(0xFF082F95),
    },
  );
  static const int _appPrimaryValue = 0xff0644e3;
}

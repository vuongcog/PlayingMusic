import 'package:flutter/material.dart';
import 'package:working_message_mobile/utils/convert.dart';

class AppLightColors {
  static const Color primary = Colors.blue;
  static const Color secondary = Colors.orange;
  static const Color surface = Colors.white;
  static const Color background = Colors.white;
  static const Color onPrimary = Colors.white;
  static const Color onSecondary = Colors.black;
  static const Color onSurface = Colors.black;
  static const Color onBackground = Colors.black;
  static const Color error = Colors.red;
  static const Color onError = Colors.red;
}

class AppDarkColors {
  static const Color primary = Colors.blue;
  static final Color secondary = hextToColor("#FF5C00");
  // static Color surface = Color.fromRGBO(12, 16, 21, 1);
  static Color surface = hextToColor("#0C1015");
  static const Color background = Colors.black;
  static const Color onPrimary = Colors.white;
  static const Color onSecondary = Colors.white;
  static final onSurface = Colors.white;
  static const Color onBackground = Colors.white;
  static const Color error = Colors.red;
  static const Color onError = Colors.red;
}

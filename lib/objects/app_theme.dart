import 'package:flutter/material.dart';
import 'package:working_message_mobile/objects/colors_scheme.dart';

class AppThemes {
  static ThemeData lightTheme = ThemeData(
    colorScheme: customLightColorScheme,
    useMaterial3: true,
  );
  static ThemeData darkTheme = ThemeData(
    colorScheme: customDarkColorScheme,
    useMaterial3: true,
  );
}

import 'package:flutter/material.dart';
import 'package:working_message_mobile/objects/app_colors.dart';

ColorScheme customLightColorScheme = ColorScheme(
  primary: AppLightColors.primary,
  onPrimary: AppLightColors.onPrimary,
  secondary: AppLightColors.secondary,
  onSecondary: AppLightColors.onSecondary,
  surface: AppLightColors.surface,
  onSurface: AppLightColors.onSurface,
  error: AppLightColors.error,
  onError: AppLightColors.onError,
  brightness: Brightness.light,
);

ColorScheme customDarkColorScheme = ColorScheme(
  primary: AppDarkColors.primary,
  secondary: AppDarkColors.secondary,
  surface: AppDarkColors.surface,

  onPrimary: AppDarkColors.onPrimary,
  onSecondary: AppDarkColors.onSecondary,
  onSurface: AppDarkColors.onSurface,

  error: AppDarkColors.error,
  onError: AppDarkColors.onError,
  brightness: Brightness.dark,
);

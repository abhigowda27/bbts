import 'package:bbts_server/theme/app_colors.dart';
import 'package:flutter/material.dart';

ThemeData lightTheme() {
  return ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: const Color(0xFFDCF8F4),
    fontFamily: "OpenSans",
    extensions: const <ThemeExtension<dynamic>>[lightAppColors],
    appBarTheme: AppBarTheme(
      centerTitle: true,
      titleTextStyle: TextStyle(
          fontWeight: FontWeight.bold,
          color: lightAppColors.background,
          fontSize: 24),
      backgroundColor: lightAppColors.primary,
      foregroundColor: lightAppColors.background,
    ),
    dialogBackgroundColor: lightAppColors.background,
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        foregroundColor: lightAppColors.primary,
      ),
    ),
    dialogTheme: DialogTheme(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      backgroundColor: Colors.white,
      titleTextStyle: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
      contentTextStyle: const TextStyle(
        fontSize: 16,
        color: Colors.black54,
        height: 1.4,
      ),
      actionsPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        backgroundColor: lightAppColors.buttonBackground,
        foregroundColor: lightAppColors.buttonText,
      ),
    ),
    textTheme: TextTheme(
      displayLarge: TextStyle(
          fontSize: 57,
          fontWeight: FontWeight.bold,
          color: lightAppColors.textPrimary),
      displayMedium: TextStyle(
          fontSize: 45,
          fontWeight: FontWeight.w600,
          color: lightAppColors.textPrimary),
      displaySmall: TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.w500,
          color: lightAppColors.textPrimary),
      headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: lightAppColors.textPrimary),
      headlineMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          color: lightAppColors.textPrimary),
      headlineSmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w500,
          color: lightAppColors.textPrimary),
      titleLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w500,
          color: lightAppColors.textPrimary),
      titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: lightAppColors.textPrimary),
      titleSmall: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: lightAppColors.textSecondary),
      bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: lightAppColors.textSecondary),
      bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: lightAppColors.textSecondary),
      bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: lightAppColors.textSecondary),
      labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: lightAppColors.primary),
      labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: lightAppColors.primary),
      labelSmall: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w400,
          color: lightAppColors.grey),
    ),
  );
}

ThemeData darkTheme() {
  return ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: const Color(0xFF2C3F3C),
    fontFamily: "OpenSans",
    extensions: const <ThemeExtension<dynamic>>[darkAppColors],
    appBarTheme: AppBarTheme(
      centerTitle: true,
      titleTextStyle: TextStyle(
          fontWeight: FontWeight.w600,
          color: darkAppColors.textSecondary,
          fontSize: 24),
      backgroundColor: darkAppColors.primary,
      foregroundColor: darkAppColors.textPrimary,
    ),
    dialogBackgroundColor: darkAppColors.background,
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        backgroundColor: darkAppColors.buttonBackground,
        foregroundColor: darkAppColors.buttonText,
      ),
    ),
    textTheme: TextTheme(
      displayLarge: TextStyle(
          fontSize: 57,
          fontWeight: FontWeight.bold,
          color: darkAppColors.textPrimary),
      displayMedium: TextStyle(
          fontSize: 45,
          fontWeight: FontWeight.w600,
          color: darkAppColors.textPrimary),
      displaySmall: TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.w500,
          color: darkAppColors.textPrimary),
      headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: darkAppColors.textPrimary),
      headlineMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          color: darkAppColors.textPrimary),
      headlineSmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w500,
          color: darkAppColors.textPrimary),
      titleLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: darkAppColors.textPrimary),
      titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: darkAppColors.textSecondary),
      titleSmall: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: darkAppColors.textSecondary),
      bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: darkAppColors.textPrimary),
      bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: darkAppColors.textSecondary),
      bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: darkAppColors.textSecondary),
      labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: darkAppColors.primary),
      labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: darkAppColors.primary),
      labelSmall: TextStyle(
          fontSize: 11, fontWeight: FontWeight.w400, color: darkAppColors.grey),
    ),
  );
}

const lightAppColors = AppColors(
  primary: Color(0xFF00BFA6), // A fresh teal for primary color
  background: Color(0xFFFDFDFD), // Soft white background
  textPrimary: Color(0xFF1C1C1E), // Near-black for good readability
  textSecondary: Color(0xFF6E6E73), // Neutral gray for secondary text
  buttonBackground:
      Color(0xFF00C7BE), // Slightly lighter than primary for buttons
  buttonText: Color(0xFFFFFFFF), // White text for buttons

  // Additional
  white: Color(0xFFFFFFFF),
  black: Color(0xFF000000),
  grey: Color(0xFFB0BEC5), // Cool gray for borders, disabled states
  backgroundDark: Color(0xFFF0F0F3), // Subtle light-gray background
  red: Color(0xFFF58D8D), // Vibrant red for alerts
  redButton: Color(0xFFD32F2F), // Deep red for danger buttons
  green: Color(0xFF66BB6A), // Medium green for success icons
  greenButton: Color(0xFF07601A), // Strong green for confirm buttons
);

const darkAppColors = AppColors(
  primary: Color(0xFF05806C), // Same vibrant teal for brand consistency
  background: Color(0xFF121212), // Standard dark background (Material Dark)
  textPrimary: Color(0xFFD5D5D5), // White text for contrast
  textSecondary: Color(0xFFB0B0B0), // Light gray for less important text
  buttonBackground: Color(0xFF0E795E), // Bright teal for button pop
  buttonText: Color(0xFF000000), // Black text for high-contrast buttons

  // Additional
  white: Color(0xFFFFFFFF),
  black: Color(0xFF000000),
  grey: Color(0xFF616161),
  backgroundDark: Color(0xFF1E1E1E),
  red: Color(0xFFFF6B6B), // Vibrant red for alerts
  redButton: Color(0xFFB41717), // Consistent danger button
  green: Color(0xFF25AB51), // Soft green for status indicators
  greenButton: Color(0xFF06570A), // Medium green for CTA success buttons
);

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Central location for light and dark theme configuration.
class OlyTheme {
  OlyTheme._();

  /// Brand color shared between light and dark schemes.
  static const Color _brandColor = Color(0xFF0066CC);

  /// Light theme using Material 3.
  static ThemeData light() {
    final base = ThemeData.light(useMaterial3: true);
    return base.copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: _brandColor,
        brightness: Brightness.light,
      ),
      textTheme: GoogleFonts.robotoTextTheme(base.textTheme),
    );
  }

  /// Dark theme using Material 3.
  static ThemeData dark() {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: _brandColor,
        brightness: Brightness.dark,
      ),
      textTheme: GoogleFonts.robotoTextTheme(base.textTheme),
    );
  }
}

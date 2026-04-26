import 'package:flutter/material.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData light = FlexThemeData.light(
    scheme: FlexScheme.blue,
    surfaceMode: FlexSurfaceMode.highScaffoldLowSurface,
    blendLevel: 10,
    subThemesData: const FlexSubThemesData(
      defaultRadius: 12,
      inputDecoratorRadius: 12,
    ),
    textTheme: GoogleFonts.poppinsTextTheme(),
  );

  static ThemeData dark = FlexThemeData.dark(
    scheme: FlexScheme.blue,
    surfaceMode: FlexSurfaceMode.highScaffoldLowSurface,
    blendLevel: 15,
    textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
  );
}

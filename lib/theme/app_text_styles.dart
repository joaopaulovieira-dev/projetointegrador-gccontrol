import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract class ApptextStyles {
  TextStyle get titleSplashPage;
}

class ApptextStylesDefault implements ApptextStyles {
  @override
  TextStyle get titleSplashPage => GoogleFonts.inter(
        fontSize: 48,
        fontWeight: FontWeight.bold,
        // color: AppTheme.colors.title,
      );
}

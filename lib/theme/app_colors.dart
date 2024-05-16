import 'package:flutter/material.dart';

abstract class AppColors {
  Color get background;
  Color get primary;
  Color get primaryVariant;
  Color get secundary;
  Color get secundaryVariant;
  Color get menu;
  Color get deepPrimary;

  Color get appBar;

  Color get menulateralColor;
  Color get menulateralselecionadoColor;
  Color get white;
  Color get textmenulateralColor;
  Color get enabletextmenulateralColor;
  Color get novidadesColor;
}

class AppColorsDefault implements AppColors {
  @override
  Color get background => Colors.white;
  @override
  Color get primary => Colors.orange;
  @override
  Color get primaryVariant => Colors.red;
  @override
  Color get secundary => Colors.blue;
  @override
  Color get secundaryVariant => Colors.blue[900]!;
  @override
  Color get menu => const Color(0xFF767676);
  @override
  Color get deepPrimary => const Color.fromARGB(129, 201, 224, 231);

  @override
  Color get novidadesColor => Colors.orange;

  /////////////// MENU LATERAL ////////////////

  @override
  Color get menulateralColor => const Color(0xFFF5F7F8);
  @override
  Color get menulateralselecionadoColor => Colors.transparent;
  @override
  Color get white => Colors.white;
  @override
  Color get textmenulateralColor => const Color(0xFF767676);
  @override
  Color get enabletextmenulateralColor => Colors.black;

  /////////////// APP BAR ////////////////

  @override
  Color get appBar => Colors.white;
}

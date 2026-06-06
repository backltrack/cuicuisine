import 'package:flutter/material.dart';

class Breakpoints {
  static const double wide = 800;
  static const double ultraWide = 1200;

  static bool isWide(BuildContext context) =>
      MediaQuery.of(context).size.width >= wide;

  static bool isUltraWide(BuildContext context) =>
      MediaQuery.of(context).size.width >= ultraWide;
}

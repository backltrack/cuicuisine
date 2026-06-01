import 'package:flutter/material.dart';

class DarkColors {
  DarkColors._();

  // Brique (brick red) — accent, AppBar, FAB
  static const MaterialColor accentColor = MaterialColor(
    0xffd65931,
    <int, Color>{
      50:  Color(0xfffdf0eb),
      100: Color(0xfff9d4c5),
      200: Color(0xfff2a98a),
      300: Color(0xffe87e54),
      400: Color(0xffde6940),
      500: Color(0xffd65931),
      600: Color(0xffc14f2a),
      700: Color(0xffb84623),
      800: Color(0xff9a3a1b),
      900: Color(0xff7a2c12),
    }
  );

  // M3 neutral dark surface — scaffold background (#1C1B1F)
  static const Color backgroundColor = Color(0xff1c1b1f);

  // M3 surface container — cards, dialogs (#2B2930)
  static const Color tileBackgroundColor = Color(0xff2b2930);

  // Primary alternative (darker brique) — FAB background
  static const MaterialColor menuColor = MaterialColor(
    0xffb84623,
    <int, Color>{
      500: Color(0xffd65931),
      900: Color(0xffb84623),
    }
  );

  // M3 on-surface — near white, neutral, highly readable (#E6E1E5)
  static const Color writingColor = Color(0xffe6e1e5);
  // M3 on-surface-variant — muted secondary text (#CAC4D0)
  static const Color secondaryWritingColor = Color(0xffcac4d0);

  // Deep neutral dark — chip backgrounds
  static const Color blackColor = Color(0xff0f0d13);

  // Warm amber — notifications/hints
  static const MaterialColor notificationColor = MaterialColor(
    0xffe8a030,
    <int, Color>{
      50:  Color(0xfffff8e8),
      100: Color(0xfffeecbf),
      200: Color(0xfffde093),
      300: Color(0xfffcd366),
      400: Color(0xfffbc945),
      500: Color(0xffe8a030),
      600: Color(0xffdb9228),
      700: Color(0xffcb801e),
      800: Color(0xffbb6f15),
      900: Color(0xff9e5207),
    }
  );
}

class LightColors {
  LightColors._();

  // Brique (brick red) — accent, AppBar, FAB
  static const MaterialColor accentColor = MaterialColor(
    0xffd65931,
    <int, Color>{
      50:  Color(0xfffdf0eb),
      100: Color(0xfff9d4c5),
      200: Color(0xfff2a98a),
      300: Color(0xffe87e54),
      400: Color(0xffde6940),
      500: Color(0xffd65931),
      600: Color(0xffc14f2a),
      700: Color(0xffb84623),
      800: Color(0xff9a3a1b),
      900: Color(0xff7a2c12),
    }
  );

  // Warm parchment — scaffold background
  static const Color backgroundColor = Color(0xfffdf6e8);

  // Slightly deeper parchment — cards, dialogs
  static const Color tileBackgroundColor = Color(0xfff6edd8);

  // Primary alternative (darker brique) — FAB background
  static const MaterialColor menuColor = MaterialColor(
    0xffb84623,
    <int, Color>{
      500: Color(0xffd65931),
      900: Color(0xffb84623),
    }
  );

  // Very dark warm brown — main writing color on light backgrounds
  static const Color writingColor = Color(0xff1e1108);
  static const Color secondaryWritingColor = Color(0x881e1108);  // ~53% opacity

  // Dark warm — chip backgrounds
  static const Color blackColor = Color(0xff1e1108);

  // Warm amber — notifications/hints
  static const MaterialColor notificationColor = MaterialColor(
    0xffe8a030,
    <int, Color>{
      50:  Color(0xfffff8e8),
      100: Color(0xfffeecbf),
      200: Color(0xfffde093),
      300: Color(0xfffcd366),
      400: Color(0xfffbc945),
      500: Color(0xffe8a030),
      600: Color(0xffdb9228),
      700: Color(0xffcb801e),
      800: Color(0xffbb6f15),
      900: Color(0xff9e5207),
    }
  );
}

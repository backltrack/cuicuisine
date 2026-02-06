import 'package:dynamic_themes/dynamic_themes.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'colors.dart';

class AppThemes {
  static const int Dark = 0;
  static const int Light = 1;
  static const List<String> themes = ['Dark', 'Light'];
}

ThemeCollection setThemeCollection(context) {
  GoogleFonts.config.allowRuntimeFetching = false;

  return ThemeCollection(
    themes: {
      AppThemes.Dark: ThemeData(
        useMaterial3: true,

        colorScheme: ColorScheme.fromSeed(
          seedColor: DarkColors.accentColor,
          secondary: DarkColors.menuColor,
          surface: DarkColors.backgroundColor,
          brightness: Brightness.light,
        ),

        appBarTheme: AppBarTheme(
          backgroundColor: DarkColors.accentColor,
          titleTextStyle: TextStyle(
            color: DarkColors.writingColor,
            fontSize: 20,
            fontFamily: GoogleFonts.comfortaa().fontFamily
          ),
          iconTheme: const IconThemeData(
            color: DarkColors.writingColor,
            size: 20
          )
        ),

        bottomAppBarTheme: const BottomAppBarThemeData(
          color: DarkColors.accentColor
        ),

        fontFamily: GoogleFonts.comfortaa().fontFamily,
        scaffoldBackgroundColor: DarkColors.backgroundColor,
        canvasColor: DarkColors.backgroundColor,
        primaryColorDark: DarkColors.menuColor,
        cardColor: DarkColors.tileBackgroundColor,
        listTileTheme: const ListTileThemeData(
          textColor: DarkColors.writingColor,
          iconColor: DarkColors.writingColor
        ),
        chipTheme: Theme.of(context).chipTheme.copyWith(backgroundColor: DarkColors.blackColor, deleteIconColor: DarkColors.writingColor),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
            splashColor: DarkColors.writingColor,
            backgroundColor: DarkColors.menuColor,
            foregroundColor: DarkColors.writingColor,
            shape: StadiumBorder()
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: DarkColors.writingColor, fontSize: 14),
          bodyMedium: TextStyle(color: DarkColors.secondaryWritingColor, fontSize: 14),
          displayLarge: TextStyle(color: DarkColors.writingColor, fontSize: 24, fontWeight: FontWeight.bold),
          displayMedium: TextStyle(color: DarkColors.writingColor, fontSize: 16),
          displaySmall: TextStyle(color: DarkColors.writingColor, fontSize: 15)
        ),
        iconTheme: const IconThemeData(color: DarkColors.writingColor, size: 20),
        hintColor: DarkColors.notificationColor,
        dividerColor: DarkColors.secondaryWritingColor,
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            shape: const StadiumBorder(),
            side: const BorderSide(width: 1, color: DarkColors.writingColor),
            textStyle: const TextStyle(color: DarkColors.writingColor),
          ),
        ),
        drawerTheme: const DrawerThemeData(
          backgroundColor: DarkColors.blackColor
        ),
        popupMenuTheme: const PopupMenuThemeData(
          color: DarkColors.tileBackgroundColor
        ),
        dialogTheme: DialogThemeData(
          backgroundColor: DarkColors.tileBackgroundColor,
          titleTextStyle: const TextStyle(color: DarkColors.writingColor, fontSize: 20)
        )
      ),
      AppThemes.Light: ThemeData(
        useMaterial3: true,

        colorScheme: ColorScheme.fromSeed(
          seedColor: LightColors.accentColor,
          secondary: LightColors.menuColor,
          surface: LightColors.backgroundColor,
          brightness: Brightness.light,
        ),

        appBarTheme: AppBarTheme(
          backgroundColor: LightColors.accentColor,
          titleTextStyle: TextStyle(
            color: DarkColors.writingColor,
            fontSize: 20,
            fontFamily: GoogleFonts.comfortaa().fontFamily
          ),
          iconTheme: const IconThemeData(
            color: DarkColors.writingColor,
            size: 20
          )
        ),

        bottomAppBarTheme: const BottomAppBarThemeData(
          color: LightColors.accentColor
        ),

        fontFamily: GoogleFonts.comfortaa().fontFamily,
        scaffoldBackgroundColor: LightColors.backgroundColor,
        canvasColor: LightColors.backgroundColor,
        primaryColorDark: LightColors.menuColor,
        cardColor: LightColors.tileBackgroundColor,
        listTileTheme: const ListTileThemeData(
            textColor: LightColors.writingColor,
            iconColor: LightColors.writingColor
        ),
        chipTheme: Theme.of(context).chipTheme.copyWith(backgroundColor: LightColors.backgroundColor, deleteIconColor: LightColors.writingColor),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
            splashColor: LightColors.writingColor,
            backgroundColor: LightColors.menuColor,
            foregroundColor: DarkColors.writingColor,
            shape: StadiumBorder()
        ),
        textTheme: const TextTheme(
            bodyLarge: TextStyle(color: LightColors.writingColor, fontSize: 14),
            bodyMedium: TextStyle(color: LightColors.secondaryWritingColor, fontSize: 14),
            displayLarge: TextStyle(color: LightColors.writingColor, fontSize: 24, fontWeight: FontWeight.bold),
            displayMedium: TextStyle(color: LightColors.writingColor, fontSize: 17),
            displaySmall: TextStyle(color: LightColors.writingColor, fontSize: 15)
        ),
        iconTheme: const IconThemeData(color: LightColors.writingColor, size: 20),
        hintColor: LightColors.notificationColor,
        dividerColor: LightColors.secondaryWritingColor,
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            shape: const StadiumBorder(),
            side: const BorderSide(width: 1, color: LightColors.writingColor),
            textStyle: const TextStyle(color: LightColors.writingColor),
          ),
        ),
        drawerTheme: DrawerThemeData(
          backgroundColor: LightColors.backgroundColor
        ),
        popupMenuTheme: PopupMenuThemeData(
          color: LightColors.tileBackgroundColor
        ),
        dialogTheme: DialogThemeData(
          backgroundColor: LightColors.tileBackgroundColor,
          titleTextStyle: const TextStyle(color: LightColors.writingColor, fontSize: 20)
        )
      )
    },
    fallbackTheme: ThemeData.dark(),
  );
}
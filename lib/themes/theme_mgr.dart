import 'package:cuicuisine/database/database_mgr.dart';
import 'package:flutter/material.dart';
import 'package:dynamic_themes/dynamic_themes.dart';

import 'package:cuicuisine/themes/themes.dart';

class ThemeMgr {
  static final ThemeMgr _instance = ThemeMgr._();

  factory ThemeMgr() {
    return _instance;
  }

  ThemeMgr._();

  static Future<void> setTheme(context, int themeId) async {
    DatabaseMgr.localMgr.saveTheme(themeId);
    print('Save theme $themeId');

    await DynamicTheme.of(context)?.setTheme(themeId);
  }

  static Future<void> loadTheme(context) async {
    int? themeId = DatabaseMgr.localMgr.loadTheme();
    if (themeId != null) {
      await DynamicTheme.of(context)?.setTheme(themeId);
    }
  }

  static ThemeData? getTheme(context) {
    return DynamicTheme.of(context)?.theme;
  }

  static bool isDarkTheme(context) {
    return DynamicTheme.of(context)!.themeId == AppThemes.Dark;
  }
}

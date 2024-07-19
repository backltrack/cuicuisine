import 'package:cuicuisine/database/database_mgr.dart';
import 'package:cuicuisine/main.dart';
import 'package:flutter/material.dart';

import '../generated/l10n.dart';

class LocaleMgr {
  static final LocaleMgr _instance = LocaleMgr._();

  factory LocaleMgr() {
    return _instance;
  }

  LocaleMgr._();

  static void setLocale(BuildContext context, String code) {
    DatabaseMgr().localMgr.saveLocale(code);
    print('Save locale $code');

    Cuicuisine.of(context)!.changeLocale(code);
  }

  static void loadLocale(BuildContext context) {
    String? localeCode = DatabaseMgr().localMgr.loadLocale();
    if (localeCode != null) {
      Cuicuisine.of(context)!.changeLocale(localeCode);
    } 
    else {
      Cuicuisine.of(context)!.changeLocale('en');
    }
  }

  static String getLocale(BuildContext context) {
    return Cuicuisine.of(context)!.getLocaleCode();
  }
}
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../database/database_mgr.dart';
import '../../l10n/locale_mgr.dart';
import '../../themes/theme_mgr.dart';
import '../../generated/l10n.dart';
import '../../themes/themes.dart';
import '../../utilities/import_export.dart';
import '../../widgets/core_widgets/alert_dialog.dart';
import '../account/account_page.dart';
import '../authentication/authentication_page.dart';
import 'synchronization_status_page.dart';

class GeneralSettingsPage extends StatefulWidget {
  static const String route = "/settings";

  const GeneralSettingsPage({super.key});

  @override
  _GeneralSettingsPageState createState() => _GeneralSettingsPageState();
}

class _GeneralSettingsPageState extends State<GeneralSettingsPage> {
  bool wakelockState = false;

  @override
  void initState() {
    super.initState();

    wakelockState = DatabaseMgr().localMgr.loadWakelock() ?? false;
    setState(() {});

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).settings),
      ),
      body: Column(
        children: [
          // Theme
          Container(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Text(S.of(context).general_settings_theme, style: ThemeMgr.getTheme(context)!.textTheme.displayMedium),
                const Spacer(),
                PopupMenuButton(
                    icon: const Icon(Icons.palette),
                    itemBuilder: (context) => List<PopupMenuItem>.generate(AppThemes.themes.length, (index) => PopupMenuItem(
                      child: Text(AppThemes.themes[index], style: ThemeMgr.getTheme(context)!.textTheme.bodyLarge),
                      onTap: () {
                        setState(() {
                          ThemeMgr.setTheme(context, index);
                        });
                      },
                    ))
                )
              ],
            ),
          ),
          // Language
          Container(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Text(S.of(context).general_settings_language, style: ThemeMgr.getTheme(context)!.textTheme.displayMedium),
                const Spacer(),
                PopupMenuButton(
                    icon: const Icon(Icons.language),
                    itemBuilder: (context) => List<PopupMenuItem>.generate(S.delegate.supportedLocales.length, (index) => PopupMenuItem(
                      child: Text(S.delegate.supportedLocales[index].languageCode, style: ThemeMgr.getTheme(context)!.textTheme.bodyLarge),
                      onTap: () {
                        LocaleMgr.setLocale(context, S.delegate.supportedLocales[index].languageCode);
                      },
                    ))
                )
              ],
            )
          ),

          // Keep Screen Awake
          Container(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Text(S.of(context).general_settings_awake, style: ThemeMgr.getTheme(context)!.textTheme.displayMedium),
                  const Spacer(),
                  Switch(
                    value: wakelockState,
                    onChanged: (bool val) {
                      setState(() {
                        wakelockState = val;
                      });
                      DatabaseMgr().localMgr.saveWakelock(wakelockState);
                      wakelockState ? WakelockPlus.enable() : WakelockPlus.disable();
                    },
                  )
                ],
              )
          ),

          const Divider(),
          // Export
          ListTile(
            title: Text(S.of(context).general_settings_export, style: ThemeMgr.getTheme(context)!.textTheme.displayMedium),
            trailing: const FaIcon(FontAwesomeIcons.fileExport),
            onTap: () async {
              await exportAllAsJson();
            }
          ),
          const Divider(),
          // Synchronization
          ListTile(
            title: Text(S.of(context).general_settings_synchronization, style: ThemeMgr.getTheme(context)!.textTheme.displayMedium),
            trailing: const FaIcon(FontAwesomeIcons.arrowsRotate),
            onTap: () {
              Navigator.pushNamed(context, SynchronizationStatusPage.route);
            }
          ),
          const Spacer(),
          const Divider(),
          // remove account
          ListTile(
            title: Text(S.of(context).account),
            leading: const FaIcon(FontAwesomeIcons.user),
            onTap: () {
              Navigator.pushNamed(context, AccountPage.route);
            }
          ),
          const Divider(),
          // Sign out
          ListTile(
            title: Text(S.of(context).general_settings_signout),
            leading: const FaIcon(FontAwesomeIcons.rightFromBracket),
            onTap: () async {
              bool? shouldSignOut = await showAlertDialog(
                context: context,
                title: S.of(context).sign_out_popup_title,
                description: Text(S.of(context).sign_out_popup_description)
              );
              if(shouldSignOut != null && shouldSignOut) {
                DatabaseMgr().localMgr.deleteCredentials();
                await DatabaseMgr().localMgr.clearAllUserData();
                Navigator.pushNamedAndRemoveUntil(context, LogInPage.route, (route) => false);
              }
            }
          ),
        ],
      ),
    );
  }
}

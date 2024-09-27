import 'package:cuicuisine/database/database_mgr.dart';
import 'package:cuicuisine/l10n/localeMgr.dart';
import 'package:cuicuisine/themes/theme_mgr.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../../generated/l10n.dart';
import '../../pages/authentication/authentication_page.dart';
import '../../pages/authentication/remove_account.dart';
import '../themes/themes.dart';
import '../../utilities/import_export.dart';
import '../../widgets/core_widgets/alert_dialog.dart';

class GeneralSettingsPage extends StatefulWidget {
  static const String route = "/settings";

  GeneralSettingsPage({Key? key}) : super(key: key);

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
                        ThemeMgr.setTheme(context, index);
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
                      DatabaseMgr().localMgr.saveWakelock(wakelockState);
                      setState(() {
                        wakelockState = !wakelockState;
                      });
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
          /// V1
          // Import
          // Container(
          //     padding: EdgeInsets.all(12),
          //     child: Row(
          //       children: [
          //         Text(S.of(context).general_settings_import, style: getTheme(context)!.textTheme.headline2),
          //         Spacer(),
          //         IconButton(
          //           icon: FaIcon(FontAwesomeIcons.fileImport),
          //           onPressed: () async {
          //             await importJson(DatabaseMgr().localMgr.getUser()!.id);
          //           },
          //         )
          //       ],
          //     )
          // ),
          const Spacer(),
          const Divider(),
          // remove account
          ListTile(
              title: Text(S.of(context).remove_account),
              leading: const FaIcon(FontAwesomeIcons.userSlash),
              onTap: () {
                Navigator.pushNamed(context, RemoveAccountPage.route);
              }
          ),
          const Divider(),
          // Sign out
          ListTile(
            title: Text(S.of(context).general_settings_signout),
            leading: const FaIcon(FontAwesomeIcons.signOutAlt),
            onTap: () async {
              bool? shouldSignOut = await showAlertDialog(
                context: context,
                title: S.of(context).sign_out_popup_title,
                description: Text(S.of(context).sign_out_popup_description)
              );
              if(shouldSignOut != null && shouldSignOut) {
                //await FirebaseAuth.instance.signOut();
                DatabaseMgr().localMgr.deleteCredentials();
                Navigator.pushNamedAndRemoveUntil(context, LogInPage.route, (route) => false);
              }
            }
          ),
        ],
      ),
    );
  }
}

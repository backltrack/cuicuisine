import 'package:cuicuisine/models/data_model.dart';
import 'package:cuicuisine/pages/account/update_password.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../database/database_mgr.dart';
import '../../themes/theme_mgr.dart';

import '../../generated/l10n.dart';
import '../../utilities/string_functions.dart';
import '../../utilities/toast_notifier.dart';
import 'remove_account.dart';

class AccountPage extends StatefulWidget {
  static const String route = '/account';

  const AccountPage({ Key? key }) : super(key: key);

  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  AppUser? user = DatabaseMgr().localMgr.getUser();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).account),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              margin: const EdgeInsets.all(48),
              child: CircleAvatar(
                radius: 64,
                backgroundColor: ThemeMgr.getTheme(context)!.primaryColor,
                child: Text(getInitials(DatabaseMgr().localMgr.getUserName()), style: ThemeMgr.getTheme(context)!.textTheme.displayLarge),
              ),
            )
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                title: Text(user!.name, style: ThemeMgr.getTheme(context)!.textTheme.displayMedium),
                trailing: IconButton(
                  onPressed: () {},
                  icon: const FaIcon(FontAwesomeIcons.pen)
                )
              ),
              ListTile(
                title: Text(user!.email, style: ThemeMgr.getTheme(context)!.textTheme.displayMedium),
                trailing: IconButton(
                  onPressed: () {},
                  icon: const FaIcon(FontAwesomeIcons.pen)
                )
              ),
              ListTile(
                title: Text("************", style: ThemeMgr.getTheme(context)!.textTheme.displayMedium),
                trailing: IconButton(
                  onPressed: DatabaseMgr().isOnline ? () {
                    Navigator.pushNamed(context, UpdatePassword.route);
                  } : () {
                    ToastNotifier().showWarning(S.of(context).connexion_needed2);
                  },
                  icon: const FaIcon(FontAwesomeIcons.pen)
                )
              )
            ]
          ),
          

          const Spacer(),
          const Divider(),
          // remove account
          ListTile(
              title: Text(S.of(context).remove_account),
              leading: const FaIcon(FontAwesomeIcons.userSlash),
              onTap: DatabaseMgr().isOnline ? () {
                Navigator.pushNamed(context, RemoveAccountPage.route);
              } : () {
                ToastNotifier().showWarning(S.of(context).connexion_needed2);
              }
          )
        ]
      )
    );
  }
}
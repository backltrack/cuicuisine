import 'package:cuicuisine/models/data_model.dart';
import 'package:cuicuisine/pages/account/update_password.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../database/database_mgr.dart';
import '../../themes/theme_mgr.dart';

import '../../generated/l10n.dart';
import '../../utilities/string_functions.dart';
import '../../utilities/toast_notifier.dart';
import '../../widgets/core_widgets/alert_dialog.dart';
import '../../widgets/core_widgets/my_text_field.dart';
import 'remove_account.dart';

class AccountPage extends StatefulWidget {
  static const String route = '/account';

  const AccountPage({ super.key });

  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  AppUser? user = DatabaseMgr().localMgr.getUser();

  Future<void> _editName(BuildContext context) async {
    final TextEditingController nameEditingController = TextEditingController(text: user!.name);

    final bool? confirmed = await showAlertDialog(
      context: context,
      title: S.of(context).account_edit_name,
      description: MyTextField(
        autofocus: true,
        textEditingController: nameEditingController,
        label: S.of(context).account_name_label,
        icon: FontAwesomeIcons.idCard,
        textCapitalization: TextCapitalization.words,
      ),
    );

    if (confirmed == null) return;
    if (!confirmed) return;

    final String newName = nameEditingController.text.trim();
    if (newName.isEmpty || newName == user!.name) return;

    await DatabaseMgr().localMgr.updateUser(name: newName);

    if (!context.mounted) return;
    setState(() {
      user = DatabaseMgr().localMgr.getUser();
    });
  }

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
                title: Text(user!.email, style: ThemeMgr.getTheme(context)!.textTheme.displayMedium),
              ),
              ListTile(
                title: Text(user!.name, style: ThemeMgr.getTheme(context)!.textTheme.displayMedium),
                trailing: IconButton(
                  onPressed: () => _editName(context),
                  icon: const FaIcon(FontAwesomeIcons.pen)
                )
              ),
              ListTile(
                title: Text("************", style: ThemeMgr.getTheme(context)!.textTheme.displayMedium),
                trailing: IconButton(
                  onPressed: DatabaseMgr().isOnline && DatabaseMgr().isCompatible ? () {
                    Navigator.pushNamed(context, UpdatePassword.route);
                  } : () {
                    ToastNotifier().showWarning(DatabaseMgr().isCompatible ? S.of(context).connexion_needed2 : S.of(context).outdated_version_login_blocked);
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
              onTap: DatabaseMgr().isOnline && DatabaseMgr().isCompatible ? () {
                Navigator.pushNamed(context, RemoveAccountPage.route);
              } : () {
                ToastNotifier().showWarning(DatabaseMgr().isCompatible ? S.of(context).connexion_needed2 : S.of(context).outdated_version_login_blocked);
              }
          )
        ]
      )
    );
  }
}
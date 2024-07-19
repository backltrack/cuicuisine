import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../database/database_mgr.dart';
import '../../themes/theme_mgr.dart';
import '../../widgets/core_widgets/social_button.dart';

import '../../generated/l10n.dart';
import '../../utilities/string_functions.dart';
import '../../widgets/core_widgets/my_text_field.dart';
import 'authentication_page.dart';

class RemoveAccountPage extends StatefulWidget {
  static const String route = "/remove-account";

  const RemoveAccountPage({Key? key}) : super(key: key);

  @override
  State<RemoveAccountPage> createState() => _RemoveAccountPageState();
}

class _RemoveAccountPageState extends State<RemoveAccountPage> {
  String _email = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).remove_account),
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(12),
            child: Text(S.of(context).remove_account_method,
              textAlign: TextAlign.center,
              style: ThemeMgr.getTheme(context)!.textTheme.displayMedium,
            ),
          ),
          // email confirmation
          MyTextField(
            label: S.of(context).auth_email_label,
            icon: FontAwesomeIcons.at,
            suffixIcon: isEmailValid(_email) ? FontAwesomeIcons.checkCircle : null,
            keyboardType: TextInputType.emailAddress,
            onChanged: (String val) {
              setState(() {
                _email = val;
              });
            },
          ),
          // Agreement
          Container(
            margin: const EdgeInsets.all(12),
            child: Text(S.of(context).remove_account_agreement,
              textAlign: TextAlign.center,
            ),
          ),
          SocialButton(
            onPressed: isEmailValid(_email) ? () async {

              if(_email == DatabaseMgr().localMgr.getUser()!.email) {
                // remove recipes, books and user from database
                //await removeUser();

                DatabaseMgr().remoteMgr.disconnect();

                Navigator.pushNamedAndRemoveUntil(context, LogInPage.route, (route) => false);
              }
            } : null,
            child: Text(S.of(context).remove_button),
          )
        ],
      )
    );
  }
}

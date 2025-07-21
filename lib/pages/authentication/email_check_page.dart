import 'package:cuicuisine/pages/authentication/email_connexion.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../database/database_mgr.dart';
import '../../widgets/core_widgets/my_text_field.dart';
import '../../widgets/core_widgets/social_button.dart';

import '../../generated/l10n.dart';
import '../../utilities/string_functions.dart';
import 'email_registration.dart';

class EmailCheck extends StatefulWidget {
  static const String route = '/email_check';

  const EmailCheck({super.key});

  @override
  _EmailCheckState createState() => _EmailCheckState();
}

class _EmailCheckState extends State<EmailCheck> {
  String _email = "";

  bool showRegisterButton = false;


  @override
  Widget build(BuildContext context) {
    void _submitEmail() async {
      if (await DatabaseMgr().remoteMgr.emailExists(_email)) {
        Navigator.pushNamed(context,  EmailConnexion.route, arguments: {
          'email': _email
        });
      }
      else {
        Navigator.pushNamed(context,  EmailRegistration.route, arguments: {
          'email': _email
        });
      }
    }

    return Scaffold(
      appBar: AppBar(title: Text(S.of(context).auth_connexion)),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(children: <Widget>[
            // EMAIL method
            MyTextField(
              label: S.of(context).auth_email_label,
              keyboardType: TextInputType.emailAddress,
              suffixIcon: EmailPasswordValidator.isEmailValid(_email) ? FontAwesomeIcons.circleCheck : null,
              onChanged: (String val) {
                setState(() {
                  _email = val;
                });
              },
              icon: FontAwesomeIcons.at,
              autofocus: true,
              onSubmit: (String val) {
                if (EmailPasswordValidator.isEmailValid(_email)) {
                  _submitEmail();
                }
              },
            ),

            const SizedBox(height: 24),

            SocialButton(
              // email sign in button
              onPressed: EmailPasswordValidator.isEmailValid(_email) ? _submitEmail : null,
              // email sign in button
              child: Text(S.of(context).auth_next),
            )
          ]),
        )
      )
    );
  }

}


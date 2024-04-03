import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../database/database_mgr.dart';
import '../../widgets/core_widgets/my_text_field.dart';
import '../../widgets/core_widgets/social_button.dart';

import '../../generated/l10n.dart';
import '../../utilities/string_functions.dart';
import '../test.dart';
import 'email_registration.dart';
import 'forgotten_password.dart';

class EmailConnexion extends StatefulWidget {
  static const String route = '/connexion';

  const EmailConnexion({super.key});

  @override
  _EmailConnexionState createState() => _EmailConnexionState();
}

class _EmailConnexionState extends State<EmailConnexion> {
  String _email = "";
  String _password = "";

  bool showRegisterButton = false;


  @override
  Widget build(BuildContext context) {
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
              suffixIcon: isEmailValid(_email) ? FontAwesomeIcons.circleCheck : null,
              onChanged: (String val) {
                setState(() {
                  _email = val;
                });
              },
              icon: FontAwesomeIcons.at,
              autofocus: true,
            ),
            MyTextField(
              label: S.of(context).auth_password_label,
              keyboardType: TextInputType.text,
              isPassword: true,
              onChanged: (String val) {
                setState(() {
                  _password = val;
                });
              },
              icon: FontAwesomeIcons.key,
            ),

            const SizedBox(height: 24),

            SocialButton(
              // email sign in button
              onPressed: isEmailValid(_email) && _password.length >= 6 ? () async {
                await DatabaseMgr().remoteMgr.connectWithEmail(_email, _password, 
                  onInvalidEmail: () {
                    setState(() {
                      showRegisterButton = true;
                    });
                    Fluttertoast.showToast(msg: "Invalid email, do you want to register?");
                  },
                  onInvalidPassword: () {
                    Fluttertoast.showToast(msg: "Invalid passward, try again!");
                  }
                );

                if (mounted) Navigator.of(context).pushNamedAndRemoveUntil(TestPage.route, (Route<dynamic> route) => false);
              } : null,
              // email sign in button
              child: Text(S.of(context).auth_connexion),
            ),

            // registration
            !showRegisterButton ? const SizedBox() : 
            SocialButton(
              // email sign in button
              child: Text(S.of(context).auth_register),
              onPressed: () async {
                Navigator.pushNamed(context,  EmailRegistration.route);
              },
            ),

            // forgotten password
            // SocialButton(
            //   // email sign in button
            //   child: Text(S.of(context).auth_forgotten_password),
            //   onPressed: () async {
            //     Navigator.pushNamed(context, ForgottenPasswordPage.route);
            //   },
            // ),
          ]),
        )
      )
    );
  }

}


import 'package:cuicuisine/security/rsa.dart';
import 'package:cuicuisine/widgets/core_widgets/password_check_info.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../database/database_mgr.dart';
import '../../widgets/core_widgets/my_text_field.dart';
import '../../widgets/core_widgets/social_button.dart';

import '../../generated/l10n.dart';
import '../../utilities/string_functions.dart';
import '../../models/data_model.dart';
import '../home_page.dart';
import '../404.dart';
// import 'forgotten_password.dart';

class EmailConnexion extends StatefulWidget {
  static const String route = '/connexion';

  const EmailConnexion({super.key});

  @override
  _EmailConnexionState createState() => _EmailConnexionState();
}

class _EmailConnexionState extends State<EmailConnexion> {
  bool shouldInit = true;

  TextEditingController emailEditingController = TextEditingController();
  String _password = "";

  bool showForgottenButton = false;

  @override
  Widget build(BuildContext context) {
    // load params
    if (shouldInit) {
      if (ModalRoute.of(context)?.settings.arguments != null) {
        final routeArgs = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
        if (routeArgs['email'] != null) {
          emailEditingController.text = routeArgs['email']!;
        }
        else {
          Navigator.of(context).pushNamed(PageNotFound.route);
        }
      }
      else {
        Navigator.of(context).pushNamed(PageNotFound.route);
      }

      shouldInit = false;
    }

    return Scaffold(
      appBar: AppBar(title: Text(S.of(context).auth_connexion)),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(children: <Widget>[
            // EMAIL method
            MyTextField(
              autofocus: false,
              textEditingController: emailEditingController,
              label: S.of(context).auth_email_label,
              keyboardType: TextInputType.emailAddress,
              suffixIcon: EmailPasswordValidator.isEmailValid(emailEditingController.text) ? FontAwesomeIcons.circleCheck : null,
              icon: FontAwesomeIcons.at
            ),
            MyTextField(
              autofocus: true,
              label: S.of(context).auth_password_label,
              keyboardType: TextInputType.text,
              isPassword: true,
              icon: FontAwesomeIcons.key,
              onChanged: (val) {
                setState(() {
                  _password = val;
                });
              },
            ),

            PasswordCheckInfo(password: _password),

            const SizedBox(height: 24),

            SocialButton(
              // email sign in button
              onPressed: EmailPasswordValidator.isEmailValid(emailEditingController.text) && EmailPasswordValidator.isPasswordValid(_password) ? () async {

                String pwd = await RSAEncrypter.encryptData(_password);
                
                await DatabaseMgr().remoteMgr.connectWithEmail(emailEditingController.text, pwd, 
                  onInvalidEmail: () {
                    setState(() {
                      showForgottenButton = true;
                    });
                    Fluttertoast.showToast(msg: "Invalid email, do you want to register?");
                  },
                  onInvalidPassword: () {
                    Fluttertoast.showToast(msg: "Invalid passward, try again!");
                  },
                  onSuccess: (AppUser user) async {
                    await DatabaseMgr().synchronization.sync();
                    if (mounted) Navigator.of(context).pushNamedAndRemoveUntil(HomePage.route, (Route<dynamic> route) => false);

                  }
                );
              } : null,
              // email sign in button
              child: Text(S.of(context).auth_connexion),
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


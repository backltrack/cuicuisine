import 'package:cuicuisine/widgets/core_widgets/password_check_info.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../database/database_mgr.dart';
import '../../utilities/toast_notifier.dart';
import '../../widgets/core_widgets/my_text_field.dart';
import '../../widgets/core_widgets/social_button.dart';

import '../../generated/l10n.dart';
import '../../utilities/string_functions.dart';
import '../../models/data_model.dart';
import '../account/update_password.dart';
import '../home_page.dart';
import '../404.dart';
import 'forgotten_password.dart';
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
  bool _isSyncing = false;

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

    void submitPassword() async {
      if (!DatabaseMgr().isCompatible) {
        ToastNotifier().showWarning(S.of(context).outdated_version_login_blocked);
        return;
      }
      setState(() => _isSyncing = true);
      await DatabaseMgr().remoteMgr.connectWithEmail(emailEditingController.text, _password,
        onInvalidEmail: () {
          setState(() {
            showForgottenButton = true;
            _isSyncing = false;
          });
          ToastNotifier().showInfo(S.of(context).wrong_user);
        },
        onInvalidPassword: () {
          setState(() => _isSyncing = false);
          ToastNotifier().showWarning(S.of(context).wrong_password);
        },
        onSuccess: (AppUser user) async {
          await DatabaseMgr().synchronization.sync();
          if (!context.mounted) return;
          Navigator.of(context).pushNamedAndRemoveUntil(
              HomePage.route, (Route<dynamic> route) => false);
          if (_password == 'ToChange01') {
            Navigator.of(context).pushNamed(
              UpdatePassword.route,
              arguments: {'forceChange': true, 'oldPassword': _password},
            );
          }
        }
      );
    }

    final bool canSubmit = !_isSyncing &&
        DatabaseMgr().isCompatible &&
        EmailPasswordValidator.isEmailValid(emailEditingController.text) &&
        EmailPasswordValidator.isPasswordValid(_password);

    return Scaffold(
      appBar: AppBar(title: Text(S.of(context).auth_connexion)),
      body: Stack(
        children: [
          AbsorbPointer(
            absorbing: _isSyncing,
            child: SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Column(children: <Widget>[
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
                    onSubmit: (String val) {
                      if (canSubmit) submitPassword();
                    },
                  ),

                  PasswordCheckInfo(password: _password),

                  const SizedBox(height: 24),

                  SocialButton(
                    onPressed: canSubmit ? submitPassword : null,
                    child: Text(S.of(context).auth_connexion),
                  ),

                  TextButton(
                    onPressed: () async {
                      Navigator.pushNamed(context, ForgottenPasswordPage.route);
                    },
                    child: Text(S.of(context).auth_forgotten_password)
                  ),
                ]),
              )
            ),
          ),
          if (_isSyncing)
            Container(
              color: Colors.black45,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    Text(
                      S.of(context).synchronizing,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
        ],
      )
    );
  }

}


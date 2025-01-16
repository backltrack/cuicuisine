import 'package:cuicuisine/database/database_mgr.dart';
import 'package:cuicuisine/widgets/core_widgets/password_check_info.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../models/data_model.dart';
import '../../themes/theme_mgr.dart';
import '../../widgets/core_widgets/social_button.dart';

import '../../generated/l10n.dart';
import '../../utilities/string_functions.dart';
import '../../widgets/core_widgets/my_text_field.dart';

class ForgottenPasswordPage extends StatefulWidget {
  static const String route = '/forgotten-password';

  const ForgottenPasswordPage({Key? key}) : super(key: key);

  @override
  State<ForgottenPasswordPage> createState() => _ForgottenPasswordPageState();
}

class _ForgottenPasswordPageState extends State<ForgottenPasswordPage> {
  String _email = "";
  String _code = "";
  String _new_pwd = "";

  bool isSent = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(S.of(context).auth_forgotten_password)),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.all(12),
              child: Text(S.of(context).auth_forgotten_password_method,
                textAlign: TextAlign.center,
                style: ThemeMgr.getTheme(context)!.textTheme.displayMedium,
              ),
            ),
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
            ),
            SocialButton(
              onPressed: EmailPasswordValidator.isEmailValid(_email) ? () async {
                // send email
                Result result = await DatabaseMgr().remoteMgr.requestPasswordRecovery(_email);

                if (result.result) {
                  setState(() {
                    isSent = true;
                  });
                  Fluttertoast.showToast(msg: S.of(context).auth_renewal_email_sent);
                }
                else {
                  Fluttertoast.showToast(msg: result.reason);
                }

              } : null,
              child: Text(S.of(context).auth_renewal_link),
            ),



            !isSent ? const SizedBox() : 
            Column(
              children: [
                MyTextField(
                  label: S.of(context).auth_code_label,
                  keyboardType: TextInputType.text,
                  suffixIcon: EmailPasswordValidator.isEmailValid(_code) ? FontAwesomeIcons.circleCheck : null,
                  onChanged: (String val) {
                    setState(() {
                      _code = val;
                    });
                  },
                  icon: FontAwesomeIcons.hashtag
                ),
                MyTextField(
                  label: S.of(context).change_password_label_new,
                  keyboardType: TextInputType.visiblePassword,
                  suffixIcon: EmailPasswordValidator.isPasswordValid(_new_pwd) ? FontAwesomeIcons.circleCheck : null,
                  isPassword: true,
                  onChanged: (String val) {
                    setState(() {
                      _new_pwd = val;
                    });
                  },
                  icon: FontAwesomeIcons.key
                ),

                PasswordCheckInfo(password: _new_pwd),

                SocialButton(
                  onPressed: EmailPasswordValidator.isEmailValid(_email) && EmailPasswordValidator.isPasswordValid(_new_pwd) ? () async {
                    Result result = await DatabaseMgr().remoteMgr.passwordRecovery(_email, _new_pwd, _code);
                    if (result.result) {
                      Navigator.pop(context);
                    }
                    else {
                      Fluttertoast.showToast(msg: result.reason);
                    }
                  } : null,
                  child: Text(S.of(context).change_password),
                )
              ]
            )
          ]
        )
      )
    );
  }
}

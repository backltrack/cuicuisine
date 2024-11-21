import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import '../../pages/home_page.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(S.of(context).auth_forgotten_password)),
      body: Column(
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
              // await FirebaseAuth.instance.sendPasswordResetEmail(email: _email);

              // Print toast
              Fluttertoast.showToast(msg: S.of(context).auth_renewal_email_sent, gravity: ToastGravity.CENTER);

              // timeout before pop
              await Future.delayed(const Duration(seconds: 3));
              Navigator.pop(context);
            } : null,
            child: Text(S.of(context).auth_renewal_link),
          )
        ],
      ),
    );
  }
}

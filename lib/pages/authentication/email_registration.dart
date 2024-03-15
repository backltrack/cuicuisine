import 'package:cuicuisine/database/database_mgr.dart';
import 'package:cuicuisine/models/model.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../widgets/core_widgets/my_text_field.dart';
import '../../widgets/core_widgets/social_button.dart';

import '../../generated/l10n.dart';
import '../../utilities/string_functions.dart';


class EmailRegistration extends StatefulWidget {
  static const String route = '/registration';

  @override
  _EmailRegistrationState createState() => _EmailRegistrationState();
}

class _EmailRegistrationState extends State<EmailRegistration> {
  String _name = "";
  String _lastname = "";
  String _email = "";
  String _password = "";

  bool areAllFieldsValid() {
    return _name != "" && _lastname != "" && isEmailValid(_email) && _password.length >= 6;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(S.of(context).registration)),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(children: <Widget>[
            // First name
            MyTextField(
              label: S.of(context).auth_register_name,
              autofocus: true,
              icon: FontAwesomeIcons.idCard,
              suffixIcon: _name != "" ? FontAwesomeIcons.circleCheck : null,
              keyboardType: TextInputType.name,
              onChanged: (String val) {
                setState(() {
                  _name = val;
                });
              },
            ),
            // Last name
            MyTextField(
              label: S.of(context).auth_register_lastname,
              icon: FontAwesomeIcons.idCard,
              suffixIcon: _lastname != "" ? FontAwesomeIcons.circleCheck : null,
              keyboardType: TextInputType.name,
              onChanged: (String val) {
                setState(() {
                  _lastname = val;
                });
              },
            ),
            // email
            MyTextField(
              label: S.of(context).auth_email_label,
              icon: FontAwesomeIcons.at,
              suffixIcon: isEmailValid(_email) ? FontAwesomeIcons.circleCheck : null,
              keyboardType: TextInputType.emailAddress,
              onChanged: (String val) {
                setState(() {
                  _email = val;
                });
              },
            ),
            // password
            MyTextField(
              label: S.of(context).auth_password_label,
              icon: FontAwesomeIcons.key,
              keyboardType: TextInputType.text,
              isPassword: true,
              onChanged: (String val) {
                setState(() {
                  _password = val;
                });
              },
            ),
            Container(
              margin: const EdgeInsets.only(left: 12),
              width: double.infinity,
              child: Text(S.of(context).auth_password_requirements),
            ),

            const SizedBox(height: 24),

            SocialButton(
              // email sign in button
              onPressed: areAllFieldsValid() ? () async {
                await DatabaseMgr.remoteMgr.registerWithEmail(_email, _password, 
                  onSuccess: (AppUser user) {
                    Fluttertoast.showToast(msg: user.email);
                  },
                  onFailure: (String reason) {
                    if (reason == "Email already exists") {
                      Fluttertoast.showToast(msg: "An account using this email address already exists.");
                    }
                    if (reason == "Incorrect password") {
                      Fluttertoast.showToast(msg: "Password doesn't satisfy security contraints");
                    }
                    else {
                      Fluttertoast.showToast(msg: "Registration failed, please try later.");
                    }
                  }
                );

              } : null,
              child: Text(S.of(context).registration),
            ),
          ]),
        )
      )
    );
  }

}

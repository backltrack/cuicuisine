import 'package:cuicuisine/widgets/core_widgets/password_check_info.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../database/database_mgr.dart';
import '../../models/data_model.dart';
import '../../utilities/toast_notifier.dart';
import '../../widgets/core_widgets/my_text_field.dart';
import '../../widgets/core_widgets/social_button.dart';

import '../../generated/l10n.dart';
import '../../utilities/string_functions.dart';
import '../404.dart';
import 'onboarding_page.dart';


class EmailRegistration extends StatefulWidget {
  static const String route = '/registration';

  const EmailRegistration({super.key});

  @override
  _EmailRegistrationState createState() => _EmailRegistrationState();
}

class _EmailRegistrationState extends State<EmailRegistration> {
  bool shouldInit = true; 

  TextEditingController nameEditingController = TextEditingController();
  TextEditingController lastnameEditingController = TextEditingController();
  TextEditingController emailEditingController = TextEditingController();
  TextEditingController passwordEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();

    nameEditingController.addListener(() {setState(() {});});
    lastnameEditingController.addListener(() {setState(() {});});
    emailEditingController.addListener(() {setState(() {});});
    passwordEditingController.addListener(() {setState(() {});});
  }

  bool areAllFieldsValid() {
    return nameEditingController.text != "" && lastnameEditingController.text != "" && EmailPasswordValidator.isEmailValid(emailEditingController.text) && EmailPasswordValidator.isPasswordValid(passwordEditingController.text);
  }

  @override
  void dispose() {
    super.dispose();

    nameEditingController.dispose();
    lastnameEditingController.dispose();
    emailEditingController.dispose();
    passwordEditingController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // load params
    if (shouldInit) {
      if (ModalRoute.of(context)?.settings.arguments != null) {
        final routeArgs = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
        if (routeArgs['email'] != null) {
          emailEditingController.text = routeArgs['email']!;
          String name = routeArgs['email']!.split('@')[0];
          if (name.contains('.')) {
            String firstName = name.split('.')[0];
            if (firstName.isNotEmpty) {
              firstName = firstName[0].toUpperCase() + firstName.substring(1);
            }
            String lastName = name.split('.')[1];
            if (lastName.isNotEmpty) {
              lastName = lastName[0].toUpperCase() + lastName.substring(1);
            }
            nameEditingController.text = firstName;
            lastnameEditingController.text = lastName;
          }
          else {
            nameEditingController.text = name;
          }
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
      appBar: AppBar(title: Text(S.of(context).registration)),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(children: <Widget>[
            // First name
            MyTextField(
              textEditingController: nameEditingController,
              label: S.of(context).auth_register_name,
              icon: FontAwesomeIcons.idCard,
              suffixIcon: nameEditingController.text != "" ? FontAwesomeIcons.circleCheck : null,
              keyboardType: TextInputType.name,
              textCapitalization: TextCapitalization.words
            ),
            // Last name
            MyTextField(
              autofocus: lastnameEditingController.text.isEmpty,
              textEditingController: lastnameEditingController,
              label: S.of(context).auth_register_lastname,
              icon: FontAwesomeIcons.idCard,
              suffixIcon: lastnameEditingController.text != "" ? FontAwesomeIcons.circleCheck : null,
              keyboardType: TextInputType.name,
              textCapitalization: TextCapitalization.words
            ),
            // email
            MyTextField(
              textEditingController: emailEditingController,
              label: S.of(context).auth_email_label,
              icon: FontAwesomeIcons.at,
              suffixIcon: EmailPasswordValidator.isEmailValid(emailEditingController.text) ? FontAwesomeIcons.circleCheck : null,
              keyboardType: TextInputType.emailAddress
            ),
            // password
            MyTextField(
              autofocus: lastnameEditingController.text.isNotEmpty,
              textEditingController: passwordEditingController,
              label: S.of(context).auth_password_label,
              icon: FontAwesomeIcons.key,
              keyboardType: TextInputType.text,
              isPassword: true
            ),
            PasswordCheckInfo(password: passwordEditingController.text),

            const SizedBox(height: 24),

            SocialButton(
              // email sign in button
              onPressed: areAllFieldsValid() ? () async {
                await DatabaseMgr().remoteMgr.registerWithEmail(emailEditingController.text, passwordEditingController.text, "${nameEditingController.text} ${lastnameEditingController.text}",
                  onSuccess: (AppUser user) async {
                    if (mounted) Navigator.of(context).pushNamedAndRemoveUntil(OnboardingPage.route, (Route<dynamic> route) => false);
                  },
                  onFailure: (String reason) {
                    if (reason == "Email already exists") {
                      ToastNotifier().showInfo("An account using this email address already exists.");
                    }
                    if (reason == "Incorrect password") {
                      ToastNotifier().showError("Password doesn't satisfy security contraints");
                    }
                    else {
                      ToastNotifier().showError("Registration failed, please try later.");
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

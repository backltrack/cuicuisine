import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../database/database_mgr.dart';
import '../../generated/l10n.dart';
import '../home_page.dart';
import '../../utilities/string_functions.dart';
import '../../utilities/toast_notifier.dart';
import '../../widgets/core_widgets/my_text_field.dart';
import '../../widgets/core_widgets/password_check_info.dart';
import '../../widgets/core_widgets/social_button.dart';


class UpdatePassword extends StatefulWidget {
  static const String route = '/account/change-password';

  const UpdatePassword({ super.key });

  @override
  _UpdatePasswordState createState() => _UpdatePasswordState();
}

class _UpdatePasswordState extends State<UpdatePassword> {
  TextEditingController oldPasswordEditingController = TextEditingController();
  String _password = "";
  bool _didPrefill = false;

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final bool forceChange = args?['forceChange'] == true;
    final String? oldPassword = args?['oldPassword'] as String?;

    if (!_didPrefill && oldPassword != null) {
      oldPasswordEditingController.text = oldPassword;
      _didPrefill = true;
    }

    return PopScope(
      canPop: !forceChange,
      child: Scaffold(
        appBar: AppBar(
          title: Text(S.of(context).change_password),
          automaticallyImplyLeading: !forceChange,
        ),
        body: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(children: <Widget>[
              MyTextField(
                autofocus: true,
                textEditingController: oldPasswordEditingController,
                label: S.of(context).auth_password_label,
                keyboardType: TextInputType.visiblePassword,
                isPassword: true,
                icon: FontAwesomeIcons.key
              ),
              MyTextField(
                autofocus: false,
                label: S.of(context).change_password_label_new,
                keyboardType: TextInputType.visiblePassword,
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
                onPressed: EmailPasswordValidator.isPasswordValid(_password) ? () async {
                  bool result = await DatabaseMgr().remoteMgr.changeUserPassword(oldPasswordEditingController.text, _password);

                  if (!context.mounted) return;
                  if (result) {
                    if (forceChange) {
                      Navigator.of(context).pushNamedAndRemoveUntil(
                          HomePage.route, (Route<dynamic> route) => false);
                    } else {
                      Navigator.pop(context);
                    }
                  } else {
                    ToastNotifier().showError(S.of(context).change_password_issue);
                  }
                } : null,
                child: Text(S.of(context).change_password),
              )
            ])
          )
        )
      ),
    );
  }
}
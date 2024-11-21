import 'package:cuicuisine/utilities/string_functions.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../generated/l10n.dart';

class PasswordCheckInfo extends StatefulWidget {
  final String password;
  const PasswordCheckInfo({super.key, required this.password});

  @override
  State<PasswordCheckInfo> createState() => _PasswordCheckInfoState();
}

class _PasswordCheckInfoState extends State<PasswordCheckInfo> {
  @override
  Widget build(BuildContext context) {
    bool checkLength = EmailPasswordValidator.checkPasswordLength(widget.password);
    bool checkUp = EmailPasswordValidator.checkPasswordContainsLowerUpper(widget.password);
    bool checkDigit = EmailPasswordValidator.checkPasswordContainsDigit(widget.password);
    bool checkSpecials = EmailPasswordValidator.checkPasswordContainsSpecials(widget.password);

    return Container(
      margin: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(S.of(context).auth_password_req_len + EmailPasswordValidator.passwordLength.toString()),
              FaIcon(checkLength? FontAwesomeIcons.circleCheck : FontAwesomeIcons.circleXmark, size: 14, color: checkLength ? Colors.green : Colors.red)
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(S.of(context).auth_password_req_uplow),
              FaIcon(checkUp? FontAwesomeIcons.circleCheck : FontAwesomeIcons.circleXmark, size: 14, color: checkUp ? Colors.green : Colors.red)
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(S.of(context).auth_password_req_digit),
              FaIcon(checkDigit? FontAwesomeIcons.circleCheck : FontAwesomeIcons.circleXmark, size: 14, color: checkDigit ? Colors.green : Colors.red)
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(S.of(context).auth_password_req_sepcial),
              FaIcon(checkSpecials? FontAwesomeIcons.circleCheck : FontAwesomeIcons.circleXmark, size: 14, color: checkSpecials ? Colors.green : Colors.red)
            ],
          )
        ],
      ),
    );
  }
}
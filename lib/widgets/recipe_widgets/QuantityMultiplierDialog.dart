import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../generated/l10n.dart';
import '../../widgets/core_widgets/my_text_field.dart';

Future<double?> showQuantityMultiplierDialog({required context, double currentCoefficient=1}) async {
  TextEditingController textEditingController = TextEditingController();
  textEditingController.text = currentCoefficient.toString();

  return showDialog<double>(
    context: context,
    builder: (BuildContext context) => AlertDialog(
      title: Text(S.of(context).ingredient_proportion_coeff),
      content: MyTextField(
        label: S.of(context).ingredient_proportion_coeff,
        overrideTextColor: Colors.black54,
        textEditingController: textEditingController,
        autofocus: true,
        keyboardType: TextInputType.number,
        icon: FontAwesomeIcons.calculator,
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context, 1.0),
          child: Text(S.of(context).disable),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, double.tryParse(textEditingController.text.replaceAll(',', '.'))),
          child: Text(S.of(context).ok),
        ),
      ],
    ),
  );
}

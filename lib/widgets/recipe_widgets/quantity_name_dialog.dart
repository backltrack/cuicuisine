import 'package:flutter/material.dart';
import '../../generated/l10n.dart';
import '../../utilities/string_functions.dart';
import '../../widgets/core_widgets/my_text_field.dart';

Future<String?> showQuantityNameDialog({required context, String currentType=""}) async {
  TextEditingController textEditingController = TextEditingController();
  textEditingController.text = currentType;

  return showDialog<String>(
    context: context,
    builder: (BuildContext context) => AlertDialog(
      title: Text(S.of(context).ingredient_quantity_type_dialog_name),
      content: MyTextField(
        label: S.of(context).ingredient_quantity_type_dialog_label,
        overrideTextColor: Colors.black54,
        textEditingController: textEditingController,
        autofocus: true,
        keyboardType: TextInputType.name,
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context, ""),
          child: Text(S.of(context).cancel),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, beautifyName(textEditingController.text)),
          child: Text(S.of(context).ok),
        ),
      ],
    ),
  );
}

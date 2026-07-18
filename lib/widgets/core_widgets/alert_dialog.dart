import 'package:flutter/material.dart';
import '../../generated/l10n.dart';

Future<bool?> showAlertDialog({
  required context,
  required String title,
  String action = "OK",
  Widget? description,
}) async {
  return showDialog<bool>(
    context: context,
    builder: (BuildContext context) => AlertDialog(
      title: Text(title),
      content: description,
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(
            S.of(context).cancel,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(
            action,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
        ),
      ],
    ),
  );
}

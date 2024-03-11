import 'package:flutter/material.dart';
import '../../generated/l10n.dart';

Future<String?> showAddBookDialog({required context}) async {
  return showDialog<String>(
    context: context,
    builder: (BuildContext context) => AlertDialog(
      title: Text(S.of(context).book_add_dialog_title),
      content: Text(S.of(context).book_add_dialog_description),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context, "join"),
          child: Text(S.of(context).join_button),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, "new"),
          child: Text(S.of(context).new_button),
        ),
      ],
    ),
  );
}

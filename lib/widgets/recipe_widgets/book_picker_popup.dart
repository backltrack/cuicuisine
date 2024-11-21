import 'package:cuicuisine/themes/theme_mgr.dart';
import 'package:flutter/material.dart';
import '../../generated/l10n.dart';
import '../../models/data_model.dart';

Future<String?> showBookPickerDialog({required context, required List<Book> books}) async {
  return showDialog<String>(
      context: context,
      builder: (BuildContext context) => BookPickerDialog(books: books)
  );
}

class BookPickerDialog extends StatefulWidget {
  final List<Book> books;
  const BookPickerDialog({Key? key, required this.books}) : super(key: key);

  @override
  _BookPickerDialogState createState() => _BookPickerDialogState();
}

class _BookPickerDialogState extends State<BookPickerDialog> {
  int value = -1;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(S.of(context).recipe_page_book_picker_title),
      content: SizedBox(
        height: MediaQuery.of(context).size.height / 4,
        width: MediaQuery.of(context).size.width * 2 / 3,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: widget.books.length,
          itemBuilder: (context, int index) {
            return RadioListTile(
              groupValue: value,
              value: index,
              title: Text(widget.books[index].name),
              onChanged: (val) {
                setState(() {
                  value = index;
                });
              }
            );
          }
        )
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(S.of(context).cancel),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, widget.books[value].id),
          child: Text(S.of(context).ok),
        ),
      ],
    );
  }
}

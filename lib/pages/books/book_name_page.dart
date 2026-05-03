import 'package:cuicuisine/models/update_model.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../generated/l10n.dart';
import '../../database/database_mgr.dart';
import '../../widgets/core_widgets/my_text_field.dart';

import '../../l10n/localeMgr.dart';
import '../../models/data_model.dart';

class BookNamePage extends StatefulWidget {
  static const route = "/home/rename_book";

  const BookNamePage({Key? key}) : super(key: key);

  @override
  _BookNamePageState createState() => _BookNamePageState();
}

class _BookNamePageState extends State<BookNamePage> {
  TextEditingController _controller = TextEditingController();
  bool argsLoaded = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // load params
    final routeArgs = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
    final bool isBookCreation = routeArgs['isBookCreation']!; // false means rename book
    String bookId = "";
    String currentName = "";
    if (!isBookCreation) {
      bookId = routeArgs['bookId']!;
      currentName = routeArgs['currentName']!;
    }

    if (!argsLoaded) {
      _controller.text = currentName;
      argsLoaded = true;
    }

    void submit() async {
      if (_controller.text != "" && _controller.text != currentName) {
        if (isBookCreation) {
          String? newBookId = await DatabaseMgr().localMgr.addNewBook(_controller.text, LocaleMgr.getLocale(context));
          if (newBookId != null) {
            Book? newBook = DatabaseMgr().localMgr.getBook(newBookId);
            Navigator.pop(context, newBook);
          }
        } else {
          DatabaseMgr().localMgr.updateBook(
            bookId,
            BookUpdate(
              id: bookId,
              name: _controller.text
            )
          );
          Navigator.pop(context, "update");
        }
      } else {
        Navigator.pop(context);
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(isBookCreation ? S.of(context).book_creation_title : S.of(context).book_rename_title),
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        child: MyTextField(
          textEditingController: _controller,
          autofocus: true,
          keyboardType: TextInputType.name,
          textCapitalization: TextCapitalization.words,
          icon: FontAwesomeIcons.book,
          label: S.of(context).book_creation_name,
          onSubmit: (_) => submit()
        )
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        label: Text(isBookCreation ? S.of(context).add_button : S.of(context).book_settings_rename),
        onPressed: submit
      )
    );
  }
}

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:clipboard/clipboard.dart';

import '../../generated/l10n.dart';
import '../../database/database_mgr.dart';
import '../../widgets/core_widgets/my_text_field.dart';

import '../../models/data_model.dart';

class BookJoinPage extends StatefulWidget {
  static const String route = '/home/join_book';
  const BookJoinPage({Key? key}) : super(key: key);

  @override
  _BookJoinPageState createState() => _BookJoinPageState();
}

class _BookJoinPageState extends State<BookJoinPage> {
  TextEditingController _controller = TextEditingController();
  bool argsLoaded = false;

  @override
  void initState() {
    super.initState();
  }

  void getIdFromClipboard() async {
    FlutterClipboard.paste().then((value) {
      RegExp pattern = RegExp('[a-zA-Z0-9]{20}');
      final RegExpMatch? match = pattern.firstMatch(value);
      if (match != null && match.group(0) != null) {
        _controller.text = match.group(0)!;
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // try load book id
    final String? url = ModalRoute.of(context)?.settings.name!;
    String? bookId;

    if (url != null && url.split('/').length > 3) {
      bookId = url.split('/')[3];
      _controller.text = bookId;
    }
    else {
      getIdFromClipboard();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).book_join_title),
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            MyTextField(
              textEditingController: _controller,
              autofocus: true,
              icon: FontAwesomeIcons.solidKeyboard,
              label: S.of(context).book_join_uid,
            ),
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 8),
              child: ElevatedButton(
                onPressed: getIdFromClipboard,
                child: const FaIcon(FontAwesomeIcons.paste, size: 20)
              ),
            )
          ],
        )
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        label: Text(S.of(context).join_button),
        onPressed: () async {
          if (_controller.text != "") {
            // is book already accessed by user
            bool canAlreadyAccess = false;
            List<Book> books = DatabaseMgr().localMgr.getUserBooks();
            books.forEach((Book book) {
              canAlreadyAccess = canAlreadyAccess || book.id == _controller.text;
            });
            // add user to book
            if (!canAlreadyAccess) {
              //await addUserToBook(_controller.text);
              try {
                // Get book locally 
                Book? remoteBook = await DatabaseMgr().remoteMgr.fetchBook(_controller.text);
                DatabaseMgr().localMgr.addBook(remoteBook, addToQueue: false);

                // update book to add user
                DatabaseMgr().localMgr.addUserToBook(remoteBook);
              }
              catch (e) {
                return;
              }
              
              Navigator.pop(context, DatabaseMgr().localMgr.getBook(_controller.text));
            }
            else {
              Fluttertoast.showToast(msg: S.of(context).book_already_accessible, gravity: ToastGravity.CENTER);
            }

          } else {
            Navigator.pop(context);
          }
        },
      ),
    );
  }
}

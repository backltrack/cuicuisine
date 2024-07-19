import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../themes/theme_mgr.dart';
import '../../widgets/core_widgets/info_dialog.dart';
import 'package:share_plus/share_plus.dart';

import '../../utilities/string_functions.dart';
import '../../generated/l10n.dart';
import '../../database/database_mgr.dart';
import '../../models/data_model.dart';
import '../../pages/authentication/authentication_page.dart';
import '../../pages/books/book_name_page.dart';
import '../../widgets/core_widgets/alert_dialog.dart';

class BookSettingsPage extends StatefulWidget {
  static const route = "/home/book_settings";

  const BookSettingsPage({Key? key}) : super(key: key);

  @override
  _BookSettingsPageState createState() => _BookSettingsPageState();
}

class _BookSettingsPageState extends State<BookSettingsPage> {
  Map<String, String> userNames = {};
  Book? _book;
  bool isReady = false;
  bool bookSharingUnderstood = false;

  @override
  void initState() {
    super.initState();

    _init();
  }

  void _init() async {
    bool? _bookSharingUnderstood = DatabaseMgr().localMgr.loadBookSharingAgreement();
    print(_bookSharingUnderstood);
    if (_bookSharingUnderstood != null) {
      bookSharingUnderstood = _bookSharingUnderstood;
    }
    print(bookSharingUnderstood);
  }

  getNames() async {
    if (_book != null) {
      if (_book!.access[DatabaseMgr().localMgr.getUserId()] == 2) {
        userNames = await DatabaseMgr().remoteMgr.getBookUserNames(_book!.id);
      }
      // build is ready to render
      isReady = true;
      // build UI
      if (mounted) setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    // load params
    final routeArgs = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
    final Book book = routeArgs['book']!;

    if (_book == null) {
      _book = book;
      // get user names && check if ready
      getNames();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).book_settings_page_title),
      ),
      body: isReady ? SingleChildScrollView(
        child: Column(
          children: [
            // Header
            Center(
                child: CircleAvatar(
                    radius: 128 / 2 + 36,
                    backgroundColor: ThemeMgr.getTheme(context)!.colorScheme.background,
                    child: Image.asset('assets/icons/splash_icon.png', width: 128)
                )
            ),
            Container(
              margin: const EdgeInsets.only(bottom: 36),
              child: Text(_book?.name ?? "",
                  style: ThemeMgr.getTheme(context)!.textTheme.displayLarge
              ),
            ),
            const Divider(),

            // Rename book
            if (_book!.access[DatabaseMgr().localMgr.getUser()!.id] == 2)
              ListTile(
                title: Text(S.of(context).book_settings_rename),
                onTap: () {
                  Navigator.of(context).pushNamed(BookNamePage.route,
                      arguments: {
                        'bookId': _book!.id,
                        'currentName': _book!.name,
                        'isBookCreation': false
                      }
                  ).then((mustUpdate) async {
                    if (mustUpdate != null && mustUpdate == "update") {
                      var _tmp = DatabaseMgr().localMgr.getBook(_book!.id);
                      if (_tmp != null) {
                        setState(() {
                          print(_tmp.name);
                          _book = _tmp;
                          print(_book!.name);
                        });
                        setState(() {

                        });
                      }
                    }
                  });
                },
              ),
            // share book
            ListTile(
              title: Text(S.of(context).book_settings_share),
              onTap: () async {
                if (!bookSharingUnderstood) {
                  await showInfoDialog(
                    context: context,
                    title: S.of(context).info_share_book_title,
                    description: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(S.of(context).info_share_book_description1, textAlign: TextAlign.center),
                        Text(S.of(context).info_share_book_description2, textAlign: TextAlign.center),
                        Text(_book!.access[DatabaseMgr().localMgr.getUser()!.id]! < 2 ?
                            S.of(context).info_share_book_description_collaborator :
                            S.of(context).info_share_book_description_owner
                          , textAlign: TextAlign.center)
                      ],
                    )
                  ).then((value) async {
                    if (value != null && value) {
                      DatabaseMgr().localMgr.saveBookSharingAgreement(value);
                    }
                  });
                }
                Share.share(
                    "${S.of(context).book_settings_share_content1}${_book!.name}${S.of(context).book_settings_share_content2}${S.of(context).title}\nhttp://openapp.recettesdefamille.com/home/join_book/${_book!.id}"
                );
              },
            ),
            // Leave / remove book
            if (_book!.access[DatabaseMgr().localMgr.getUser()!.id] == 2) (
                // can remove definitely the book for all the users
                ListTile(
                  title: Text(S.of(context).book_settings_remove),
                  onTap: () {
                    showAlertDialog(
                        context: context,
                        title: S.of(context).popup_delete_title,
                        description: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(S.of(context).popup_delete_description_as_owner),
                            Text(_book!.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                            Text(S.of(context).popup_delete_for_all)
                          ],
                        )
                    ).then((value) async {
                      if (value != null && value) {
                        //await removeBook(_book!.id);
                        Navigator.pop(context);
                      }
                    });
                  },
                )
            )
            else
            // can revoke access to the book
              ListTile(
                title: Text(S.of(context).book_settings_quit),
                onTap: () {
                  showAlertDialog(
                      context: context,
                      title: S.of(context).popup_quit_title,
                      description: Text(S.of(context).popup_quit_description + _book!.name + '?')
                  ).then((value) async {
                    if (value != null && value) {
                      DatabaseMgr().localMgr.removeUserFromBook(_book!);
                      
                      Navigator.pop(context);
                    }
                  });
                },
              ),

            const Divider(),

            const SizedBox(
              height: 12,
            ),
            Text(S.of(context).book_settings_users, style: ThemeMgr.getTheme(context)!.textTheme.headline2),
            const SizedBox(height: 12),

            ListView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _book!.users.length,
              itemBuilder: (context, int index) {
                final String _name = userNames[_book!.users[index]] ?? "";
                print(_name);
                return Container(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container( // user
                        child: Row(
                          children: [
                            CircleAvatar(
                              child: Text(getInitials(_name)),
                            ),
                            const SizedBox(width: 16),
                            Text(_name)
                          ],
                        ),
                      ),
                      if (_book!.access[_book!.users[index]]! == 2) // this book user is owner
                        Container(
                          padding: const EdgeInsets.only(right: 24),
                          child: FaIcon(FontAwesomeIcons.user, color: ThemeMgr.getTheme(context)!.hintColor),
                        ),
                      if (_book!.access[_book!.users[index]]! < 2) // this book user is not owner
                        Row(
                          children: [
                            _book!.access[DatabaseMgr().localMgr.getUser()!.id] != 2 ?
                            // current User is not owner
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 24),
                              child: FaIcon(FontAwesomeIcons.eye,
                                  color: ThemeMgr.getTheme(context)!.hintColor
                              ),
                            ) :
                            // current user is owner
                            ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    shape: const CircleBorder(),
                                    padding: const EdgeInsets.all(8),
                                    primary: ThemeMgr.getTheme(context)!.cardColor
                                ),
                                onPressed: () async {
                                  showAlertDialog(
                                      context: context,
                                      title: S.of(context).popup_remove_user_title,
                                      description: Text(S.of(context).popup_remove_user_description + _name + '?')
                                  ).then((value) async {
                                    if (value != null && value) {
                                      // remove access to book
                                      DatabaseMgr().localMgr.removeOtherUserFromBook(_book!.users[index], _book!);
                                      // get the book back from db
                                      var _tmpBook = DatabaseMgr().localMgr.getBook(_book!.id);
                                      if (_tmpBook != null) {
                                        setState(() {
                                          _book = _tmpBook;
                                        });
                                      }
                                    }
                                  });
                                },
                                child: FaIcon(FontAwesomeIcons.eye,
                                    color: ThemeMgr.getTheme(context)!.hintColor
                                )
                            ),
                            _book!.access[DatabaseMgr().localMgr.getUser()!.id] != 2 ?
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 24),
                              child: FaIcon(FontAwesomeIcons.edit,
                                  color: _book!.access[_book!.users[index]]! == 1 ? ThemeMgr.getTheme(context)!.hintColor
                                      : ThemeMgr.getTheme(context)!.iconTheme.color
                              ),
                            ) :
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  shape: const CircleBorder(),
                                  padding: const EdgeInsets.all(8),
                                  primary: ThemeMgr.getTheme(context)!.cardColor
                              ),
                              onPressed: () async {
                                // update access
                                if (_book!.access[_book!.users[index]]! == 1) {
                                  DatabaseMgr().localMgr.updateUserAccess(_book!, _book!.users[index], 0);
                                }
                                else{
                                  DatabaseMgr().localMgr.updateUserAccess(_book!, _book!.users[index], 1);
                                }
                                // get the book back from db
                                var _tmpBook = DatabaseMgr().localMgr.getBook(_book!.id);
                                if (_tmpBook != null) {
                                  print(_tmpBook.access[_book!.users[index]]);
                                  setState(() {
                                    _book = _tmpBook;
                                  });
                                }
                              },
                              child: FaIcon(FontAwesomeIcons.edit,
                                  color: _book!.access[_book!.users[index]]! == 1 ? ThemeMgr.getTheme(context)!.hintColor
                                      : ThemeMgr.getTheme(context)!.iconTheme.color
                              ),
                            ),
                        
                          ],
                        )
                    ],
                  ),
                );
              }
            )
          ],
        ),
      ) :
      const Center(
        child: CircularProgressIndicator()
      )
    );
  }
}

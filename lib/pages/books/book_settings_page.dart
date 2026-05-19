import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../themes/theme_mgr.dart';
import '../../utilities/string_functions.dart';
import '../../generated/l10n.dart';
import '../../database/database_mgr.dart';
import '../../models/data_model.dart';
import '../../pages/books/book_name_page.dart';
import '../../utilities/toast_notifier.dart';
import '../../widgets/core_widgets/alert_dialog.dart';
import 'book_share_page.dart';

class BookSettingsPage extends StatefulWidget {
  static const route = "/home/book_settings";

  const BookSettingsPage({super.key});

  @override
  _BookSettingsPageState createState() => _BookSettingsPageState();
}

class _BookSettingsPageState extends State<BookSettingsPage> {
  Map<String, String> userNames = {};
  Book? _book;
  bool isReady = false;
  bool bookSharingUnderstood = false;

  getNames() async {
    if (_book != null) {
      if (await DatabaseMgr().remoteMgr.testConnexion()) {
        userNames = await DatabaseMgr().remoteMgr.getBookUserNames(_book!.id);
      }
      // build is ready to render
      isReady = true;
      // build UI
      print("Book settings page is ready to render");
      print("User names: $userNames");
      print("Is mounted: $mounted");
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
      body: isReady ? SingleChildScrollView(child: Column(
        children: [
          // Header
          Center(
              child: CircleAvatar(
                  radius: 96 / 2 + 36,
                  backgroundColor: ThemeMgr.getTheme(context)!.colorScheme.surface,
                  child: Image.asset('assets/icons/splash_icon.png', width: 96)
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
          if (_book!.access[DatabaseMgr().localMgr.getUser()!.id]!.index == AccessLevel.own.index)
            ListTile(
              title: Text(S.of(context).book_settings_rename),
              onTap: () {
                if (!DatabaseMgr().isCompatible) {
                  ToastNotifier().showWarning(S.of(context).outdated_version_login_blocked);
                  return;
                }
                Navigator.of(context).pushNamed(BookNamePage.route,
                    arguments: {
                      'bookId': _book!.id,
                      'currentName': _book!.name,
                      'isBookCreation': false
                    }
                ).then((mustUpdate) async {
                  if (mustUpdate != null && mustUpdate == "update") {
                    var tmp = DatabaseMgr().localMgr.getBook(_book!.id);
                    if (tmp != null) {
                      setState(() {
                        _book = tmp;
                      });
                      setState(() {

                      });
                    }
                  }
                });
              },
            ),
          // tags edition
          if (_book!.access[DatabaseMgr().localMgr.getUser()!.id]!.index >= AccessLevel.write.index)
            ListTile(
              title: Text(S.of(context).book_settings_tags),
              onTap: () {
                if (!DatabaseMgr().isCompatible) {
                  ToastNotifier().showWarning(S.of(context).outdated_version_login_blocked);
                  return;
                }
                Navigator.pushNamed(
                  context,
                  '${BookSettingsPage.route}/${_book!.id}/tags',
                  arguments: {'bookId': _book!.id},
                );
              },
            ),
          // share book
          ListTile(
            title: Text(S.of(context).book_settings_share),
            onTap: () async {
              Navigator.pushNamed(context, "${BookSharePage.route}/${_book!.id}", arguments: {
                "book": _book
              });
            },
          ),
          // Leave / remove book
          if (_book!.access[DatabaseMgr().localMgr.getUser()!.id]!.index == AccessLevel.own.index) (
              // can remove definitely the book for all the users
              ListTile(
                title: Text(S.of(context).book_settings_remove),
                onTap: () {
                  if (!DatabaseMgr().isCompatible) {
                    ToastNotifier().showWarning(S.of(context).outdated_version_login_blocked);
                    return;
                  }
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
                      DatabaseMgr().localMgr.deleteBook(_book!.id);
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
                if (!DatabaseMgr().isCompatible) {
                  ToastNotifier().showWarning(S.of(context).outdated_version_login_blocked);
                  return;
                }
                showAlertDialog(
                    context: context,
                    title: S.of(context).popup_quit_title,
                    description: Text('${S.of(context).popup_quit_description}${_book!.name}?')
                ).then((value) async {
                  if (value != null && value) {
                    bool isConnected = await DatabaseMgr().remoteMgr.testConnexion();
                    if (isConnected) {
                      bool result = await DatabaseMgr().remoteMgr.revokeUserFromBook(_book!.id);
                      if (result) {
                        DatabaseMgr().synchronization.fetchNew();
                        setState(() {});
                      }
                    }
                    
                    Navigator.pop(context);
                  }
                });
              },
            ),

          const Divider(),

          const SizedBox(
            height: 12,
          ),
          Text(S.of(context).book_settings_users, style: ThemeMgr.getTheme(context)!.textTheme.displayMedium),
          const SizedBox(height: 12),

          DatabaseMgr().isOnline ? ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: _book!.users.length,
            itemBuilder: (context, int index) {
              final String name = userNames[_book!.users[index]] ?? "";

              return Container(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          child: Text(getInitials(name)),
                        ),
                        const SizedBox(width: 16),
                        Text(name)
                      ],
                    ),
                    if (_book!.access[_book!.users[index]]!.index == AccessLevel.own.index) // this book user is owner
                      Container(
                        padding: const EdgeInsets.only(right: 24),
                        child: FaIcon(FontAwesomeIcons.user, color: ThemeMgr.getTheme(context)!.hintColor),
                      ),
                    if (_book!.access[_book!.users[index]]!.index < AccessLevel.own.index) // this book user is not owner
                      Row(
                        children: [
                          _book!.access[DatabaseMgr().localMgr.getUser()!.id]!.index != AccessLevel.own.index ?
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
                                  backgroundColor: ThemeMgr.getTheme(context)!.cardColor,
                                  padding: const EdgeInsets.all(8)
                              ),
                              onPressed: () async {
                                if (!DatabaseMgr().isCompatible) {
                                  ToastNotifier().showWarning(S.of(context).outdated_version_login_blocked);
                                  return;
                                }
                                showAlertDialog(
                                    context: context,
                                    title: S.of(context).popup_remove_user_title,
                                    description: Text('${S.of(context).popup_remove_user_description}$name?')
                                ).then((value) async {
                                  if (value != null && value) {
                                    // remove access to book
                                    DatabaseMgr().localMgr.removeOtherUserFromBook(_book!.users[index], _book!);
                                    // get the book back from db
                                    var tmpBook = DatabaseMgr().localMgr.getBook(_book!.id);
                                    if (tmpBook != null) {
                                      setState(() {
                                        _book = tmpBook;
                                      });
                                    }
                                  }
                                });
                              },
                              child: FaIcon(FontAwesomeIcons.eye,
                                  color: ThemeMgr.getTheme(context)!.hintColor
                              )
                          ),
                          _book!.access[DatabaseMgr().localMgr.getUser()!.id]!.index != AccessLevel.own.index ?
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: FaIcon(FontAwesomeIcons.penToSquare,
                                color: _book!.access[_book!.users[index]]!.index == AccessLevel.write.index ? ThemeMgr.getTheme(context)!.hintColor
                                    : ThemeMgr.getTheme(context)!.iconTheme.color
                            ),
                          ) :
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                shape: const CircleBorder(),
                                backgroundColor: ThemeMgr.getTheme(context)!.cardColor,
                                padding: const EdgeInsets.all(8)
                            ),
                            onPressed: () async {
                              if (!DatabaseMgr().isCompatible) {
                                ToastNotifier().showWarning(S.of(context).outdated_version_login_blocked);
                                return;
                              }
                              // update access
                              if (_book!.access[_book!.users[index]]!.index == AccessLevel.write.index) {
                                DatabaseMgr().localMgr.updateUserAccess(_book!, _book!.users[index], AccessLevel.read);
                              }
                              else {
                                DatabaseMgr().localMgr.updateUserAccess(_book!, _book!.users[index], AccessLevel.write);

                              }
                              // get the book back from db
                              var tmpBook = DatabaseMgr().localMgr.getBook(_book!.id);
                              if (tmpBook != null) {
                                setState(() {
                                  _book = tmpBook;
                                });
                              }
                            },
                            child: FaIcon(FontAwesomeIcons.penToSquare,
                                color: _book!.access[_book!.users[index]]!.index == AccessLevel.write.index ? ThemeMgr.getTheme(context)!.hintColor
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
          : ListTile(
            title: Text(S.of(context).book_settings_need_online),
          )
        ],
      )) :
      const Center(
        child: CircularProgressIndicator()
      )
    );
  }
}

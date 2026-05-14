

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../../database/database_mgr.dart';
import '../../generated/l10n.dart';
import '../../models/data_model.dart';
import '../../widgets/core_widgets/info_dialog.dart';

class BookSharePage extends StatefulWidget {
  static const String route = '/home/share_book';
  const BookSharePage({super.key});

  @override
  _BookSharePageState createState() => _BookSharePageState();
}

class _BookSharePageState extends State<BookSharePage> {
  Book? _book;
  bool bookSharingUnderstood = false;

  @override
  void initState() {
    super.initState();
    // Initialize any necessary data or state here
    bookSharingUnderstood = DatabaseMgr().localMgr.loadBookSharingAgreement() ?? false;
  }

  @override
  Widget build(BuildContext context) {
    // load params
    final routeArgs = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
    final Book book = routeArgs['book']!;

    _book ??= book;

    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).book_settings_share),
      ),
      body: _book != null ? Column(
        children: [
          // share book
          ListTile(
            title: Text(S.of(context).book_settings_share_link),
            leading: const FaIcon(FontAwesomeIcons.share),
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
                      Text(_book!.access[DatabaseMgr().localMgr.getUser()!.id]!.index < AccessLevel.own.index ?
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
                  "${S.of(context).book_settings_share_content1}${_book!.name}${S.of(context).book_settings_share_content2}${S.of(context).title}\nhttp://openapp.cuicuisine.com/home/join_book/${_book!.id}"
              );
            },
          ),
          const Divider(),
          const SizedBox(height: 48),
          Center(
            child: Container(
              color: Colors.white,
              child: QrImageView(data: _book!.id, version: QrVersions.auto, size: 200),
            )
          ),
          const SizedBox(height: 4),
          Center(child: Text(_book!.id))

        ]
      ) :
      const Center(
        child: CircularProgressIndicator()
      ),
    );
  }
}
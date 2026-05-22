import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:clipboard/clipboard.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';

import '../../generated/l10n.dart';
import '../../database/database_mgr.dart';
import '../../utilities/toast_notifier.dart';
import '../../widgets/core_widgets/my_text_field.dart';

import '../../models/data_model.dart';
import '../../utilities/logger.dart';

final _log = Logger('BookJoinPage');

class BookJoinPage extends StatefulWidget {
  static const String route = '/home/join_book';
  const BookJoinPage({super.key});

  @override
  _BookJoinPageState createState() => _BookJoinPageState();
}

class _BookJoinPageState extends State<BookJoinPage> {
  final TextEditingController _controller = TextEditingController();
  bool argsLoaded = false;

  bool isLoaded = false;

  final FocusNode focusNode = FocusNode();

  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  QRViewController? qrViewController;
  bool showQrView = false;

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
    if (!kIsWeb) {
      if (Platform.isAndroid) {
        qrViewController!.pauseCamera();
      } else if (Platform.isIOS) {
        qrViewController!.resumeCamera();
      }
    }
    if (Platform.isAndroid) {
      qrViewController!.pauseCamera();
    } else if (Platform.isIOS) {
      qrViewController!.resumeCamera();
    }
  }

  @override
  void initState() {
    super.initState();
  }

  void getIdFromClipboard() async {
    FlutterClipboard.paste().then((value) {
      RegExp pattern = RegExp('[a-zA-Z0-9]{24}');
      final RegExpMatch? match = pattern.firstMatch(value);
      if (match != null && match.group(0) != null) {
        _controller.text = match.group(0)!;
      }
    });
  }

  void _onQRViewCreated(QRViewController controller) {
    qrViewController = controller;
    focusNode.unfocus();
    controller.scannedDataStream.listen((scanData) {
      if (scanData.code != null) {
        setState(() {
          _controller.text = scanData.code!;
          showQrView = false;
        });
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

    if (!isLoaded) {
      isLoaded = true;
      if (url != null && url.split('/').length > 3) {
        // extract book id from share link
        bookId = url.split('/')[3];
        _controller.text = bookId;
      }
      else {
        getIdFromClipboard();
      }
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(S.of(context).book_join_title),
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            MyTextField(
              textEditingController: _controller,
              focusNode: focusNode,
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
            ),
            if (Platform.isAndroid) ...[
              Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 8),
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      showQrView = !showQrView;
                    });
                  },
                  child: const FaIcon(FontAwesomeIcons.qrcode, size: 20)
                ),
              ),
              const SizedBox(height: 48),
              showQrView ? 
                SizedBox(
                  width: 300,
                  height: 300,
                  child: QRView(
                    key: qrKey,
                    onQRViewCreated: _onQRViewCreated
                  )
                ) :
                const SizedBox()
            ]
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
            for (var book in books) {
              _log.fine("joined book: ${book.id}");
              canAlreadyAccess = canAlreadyAccess || book.id == _controller.text;
              _log.fine("canAlreadyAccess: $canAlreadyAccess");
            }
            // add user to book
            if (!canAlreadyAccess) {
              //await addUserToBook(_controller.text);
              try {
                await DatabaseMgr().remoteMgr.joinBook(_controller.text);
                Book? newBook = DatabaseMgr().localMgr.getBook(_controller.text);
                if (newBook != null) {
                  Navigator.pop(context, newBook);
                }
                else {
                  ToastNotifier().showError(S.of(context).connexion_needed2);
                }
              }
              catch (e) {
                ToastNotifier().showError(S.of(context).connexion_needed2);
              }
            }
            else {
              ToastNotifier().showInfo(S.of(context).book_already_accessible);
            }

          } else {
            Navigator.pop(context);
          }
        },
      ),
    );
  }
}

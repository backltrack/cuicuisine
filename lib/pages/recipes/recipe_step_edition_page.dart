import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

import '../../generated/l10n.dart';

class StepEditionPage extends StatefulWidget {
  const StepEditionPage({super.key});

  @override
  _StepEditionPageState createState() => _StepEditionPageState();
}

class _StepEditionPageState extends State<StepEditionPage> {

  final QuillController _controller = QuillController.basic();

  bool isInitialized = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // load params
    final routeArgs = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
    final int stepNumber = routeArgs['stepNumber'];
    final String stepDescription = routeArgs['stepDescription'];

    if (!isInitialized) {
      if (stepDescription.isNotEmpty) {
        _controller.document = Document.fromJson(jsonDecode(stepDescription));

      }
      isInitialized = true;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('${S.of(context).step_edition_title} ${stepNumber+1}'),
      ),
      body: Column(
        children: [
          QuillSimpleToolbar(
            controller: _controller,
            config: const QuillSimpleToolbarConfig(
              toolbarIconAlignment: WrapAlignment.start,
              multiRowsDisplay: true,
              showCodeBlock: false,
              showQuote: false,
              showInlineCode: false,
              showDirection: false,
              showClearFormat: false,
              showDividers: true,
              showSearchButton: false,
              showUndo: true,
              showRedo: true,
              showFontFamily: false,
              showFontSize: false,
              showBoldButton: true,
              showItalicButton: true,
              showSmallButton: false,
              showUnderLineButton: true,
              showLineHeightButton: false,
              showStrikeThrough: false,
              showColorButton: true,
              showBackgroundColorButton: true,
              showAlignmentButtons: false,
              showHeaderStyle: false,
              showListNumbers: true,
              showListBullets: true,
              showListCheck: true,
              showIndent: false,
              showLink: true,
              showSubscript: false,
              showSuperscript: false
            ),
          ),
          Expanded(
            child: QuillEditor.basic(
              controller: _controller,
              config: QuillEditorConfig(
                autoFocus: true,
                padding: EdgeInsetsGeometry.all(12.0),
                customStyles: DefaultStyles(
                  link: DefaultStyles.getInstance(context).link!.copyWith(
                    decoration: TextDecoration.underline,
                    color: Colors.blue
                  )
                )
              )
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
          label: Text(S.of(context).recipe_edition_update),
          onPressed: () {
            String? data = jsonEncode(_controller.document.toDelta().toJson());
            Navigator.pop(context, data);
          }
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat
    );
  }
}

import 'package:flutter/material.dart';
import 'package:html_editor_enhanced/html_editor.dart';

import '../../generated/l10n.dart';
import '../../themes/theme_mgr.dart';

class StepEditionPage extends StatefulWidget {
  const StepEditionPage({Key? key}) : super(key: key);

  @override
  _StepEditionPageState createState() => _StepEditionPageState();
}

class _StepEditionPageState extends State<StepEditionPage> {

  HtmlEditorController htmlEditorController = HtmlEditorController();

  @override
  Widget build(BuildContext context) {
    // load params
    final routeArgs = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
    final int stepNumber = routeArgs['stepNumber'];
    final String stepDescription = routeArgs['stepDescription'];

    return Scaffold(
      appBar: AppBar(
        title: Text('${S.of(context).step_edition_title} ${stepNumber+1}'),
      ),
      body: HtmlEditor(
        controller: htmlEditorController,
        otherOptions: OtherOptions(
          height: MediaQuery.of(context).size.height - 100,
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.zero,
          )
        ),
        htmlEditorOptions: HtmlEditorOptions(
          darkMode: true,
          initialText: stepDescription,
          hint: S.of(context).step_edition_hint,
          autoAdjustHeight: false,
        ),
        htmlToolbarOptions: HtmlToolbarOptions(
          buttonColor: ThemeMgr.getTheme(context)!.textTheme.bodyLarge!.color,
          initiallyExpanded: true,
          toolbarType: ToolbarType.nativeScrollable,
          defaultToolbarButtons: [
            const ColorButtons(),
            const FontButtons(
              clearAll: false
            ),
            const OtherButtons(
              codeview: false,
              fullscreen: false,
              help: false
            ),
            const ListButtons(
              listStyles: false
            ),
            const ParagraphButtons(
              caseConverter: false,
              lineHeight: false,
              textDirection: false
            ),
            const InsertButtons(
                audio: false,
                hr: false,
                otherFile: false,
                table: false
            ),
          ]
        )
      ),
      floatingActionButton: FloatingActionButton.extended(
          label: Text(S.of(context).recipe_edition_update),
          onPressed: () {
            Navigator.pop(context, htmlEditorController.getText());
          }
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat
    );
  }
}

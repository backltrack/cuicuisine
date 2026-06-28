import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../generated/l10n.dart';
import '../../utilities/string_functions.dart';
import '../../widgets/core_widgets/my_text_field.dart';

class RecipeNamePage extends StatefulWidget {
  final String currentName;
  const RecipeNamePage({super.key, required this.currentName});

  @override
  _RecipeNamePageState createState() => _RecipeNamePageState();
}

class _RecipeNamePageState extends State<RecipeNamePage> {
  final TextEditingController _controller = TextEditingController();
  bool argsLoaded = false;

  @override
  void initState() {
    super.initState();
    setState(() {
      _controller.text = widget.currentName;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    void submit() async {
      if (_controller.text != "" && _controller.text != widget.currentName) {
        Navigator.pop(context, beautifyName(_controller.text));
      } else {
        Navigator.pop(context);
      }
    }

    return Scaffold(
      appBar: AppBar(title: Text(S.of(context).recipe_edition_new_name)),
      body: Container(
        padding: const EdgeInsets.all(16),
        child: MyTextField(
          textEditingController: _controller,
          maxLength: 60,
          autofocus: true,
          keyboardType: TextInputType.name,
          textCapitalization: TextCapitalization.words,
          icon: FontAwesomeIcons.fileLines,
          label: S.of(context).book_creation_name,
          onSubmit: submit,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        label: Text(S.of(context).book_settings_rename),
        onPressed: submit,
      ),
    );
  }
}

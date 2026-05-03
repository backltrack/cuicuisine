import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../generated/l10n.dart';
import '../../widgets/core_widgets/my_text_field.dart';

class NewTagPage extends StatefulWidget {
  const NewTagPage({Key? key}) : super(key: key);

  @override
  _NewTagPageState createState() => _NewTagPageState();
}

class _NewTagPageState extends State<NewTagPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).new_tag_title),
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            MyTextField(
              textEditingController: _nameController,
              autofocus: true,
              icon: FontAwesomeIcons.hashtag,
              label: S.of(context).new_tag_name,
            ),
            MyTextField(
              textEditingController: _categoryController,
              icon: FontAwesomeIcons.layerGroup,
              label: S.of(context).new_tag_category,
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        label: Text(S.of(context).add_button),
        onPressed: () {
          final name = _nameController.text.toLowerCase().trim();
          if (name.isNotEmpty) {
            Navigator.pop(context, {
              'name': name,
              'category': _categoryController.text.trim().toLowerCase(),
            });
          } else {
            Navigator.pop(context);
          }
        },
      ),
    );
  }
}

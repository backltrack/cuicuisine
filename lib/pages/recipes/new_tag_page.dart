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
  TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).new_tag_title),
      ),
      body: Container(
        padding: EdgeInsets.all(16),
        child: MyTextField(
          textEditingController: _controller,
          autofocus: true,
          icon: FontAwesomeIcons.hashtag,
          label: S.of(context).new_tag_name,
        )
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        label: Text(S.of(context).add_button),
        onPressed: () async {
          if (_controller.text != "") {
            Navigator.pop(context, _controller.text.toLowerCase().trim());
          } else {
            Navigator.pop(context);
          }
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../database/database_mgr.dart';
import '../../generated/l10n.dart';
import '../../themes/theme_mgr.dart';
import '../../widgets/core_widgets/alert_dialog.dart';
import '../../widgets/core_widgets/my_text_field.dart';
import '../../widgets/recipe_widgets/comment_bubble_widget.dart';

import '../../models/data_model.dart';

class RecipeCommentsWidget extends StatefulWidget {
  final String recipeId;
  final List<Comment> comments;
  final AccessLevel userAccess;
  final Function()? onUpdate;
  const RecipeCommentsWidget({super.key, required this.recipeId, required this.comments, required this.userAccess, this.onUpdate});

  @override
  _RecipeCommentsWidgetState createState() => _RecipeCommentsWidgetState();
}

class _RecipeCommentsWidgetState extends State<RecipeCommentsWidget> {
  final TextEditingController _newCommentTextController = TextEditingController();
  bool widgetApertureState = false;

  @override
  Widget build(BuildContext context) {
    int commentLength = widgetApertureState || widget.comments.isEmpty ? widget.comments.length : 1;

    return Container(
      decoration: BoxDecoration(
        color: ThemeMgr.getTheme(context)!.cardColor.withOpacity(0.5),
        borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(12), bottomRight: Radius.circular(12))
      ),
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: Column(
              children: [
                Column(
                    children: List<Widget>.generate(commentLength, (index) {
                      int invertedIndex = widget.comments.length - 1 - index;
                      return CommentWidget(
                        comment: widget.comments[invertedIndex],

                        onRemove: () {
                          showAlertDialog(
                              context: context,
                              title: S.of(context).comment_remove_title,
                              description: Text(S.of(context).comment_remove_description)
                          ).then((value) {
                            if (value != null && value) {
                              // TODO: implement comment removal
                            }
                          });
                        },
                      );
                    })
                ),
                if (widget.userAccess.index > AccessLevel.read.index && widgetApertureState)
                  MyTextField(
                    textEditingController: _newCommentTextController,
                    label: S.of(context).comment_widget_new,
                    suffixIcon: FontAwesomeIcons.paperPlane,
                    onSubmit: () async {
                      String? userId = DatabaseMgr().localMgr.getUserId();
                      if (userId != null) {}
                      // TODO: implement comment add
                    },
                  ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      widgetApertureState = !widgetApertureState;
                    });
                  },
                  icon: widgetApertureState ? const Icon(Icons.keyboard_arrow_up_rounded) : const Icon(Icons.keyboard_arrow_down_rounded)
                )
              ],
            )
          )
        ],
      )
    );
  }
}

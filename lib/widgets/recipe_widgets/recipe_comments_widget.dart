import 'package:cuicuisine/models/update_model.dart';
import 'package:cuicuisine/utilities/string_functions.dart';
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
  final Function? onUpdate;
  final Function(int)? onRemove;
  const RecipeCommentsWidget({super.key, required this.recipeId, required this.comments, required this.userAccess, this.onUpdate, this.onRemove});

  @override
  _RecipeCommentsWidgetState createState() => _RecipeCommentsWidgetState();
}

class _RecipeCommentsWidgetState extends State<RecipeCommentsWidget> {
  final TextEditingController _newCommentTextController = TextEditingController();
  bool widgetApertureState = true;

  @override
  Widget build(BuildContext context) {
    int commentLength = widgetApertureState || widget.comments.isEmpty ? widget.comments.length : 1;

    return Container(
      decoration: BoxDecoration(
        color: ThemeMgr.getTheme(context)!.cardColor.withValues(alpha: 0.5),
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
                if (widget.userAccess.index > AccessLevel.read.index && widgetApertureState)
                  MyTextField(
                    textEditingController: _newCommentTextController,
                    label: S.of(context).comment_widget_new,
                    suffixIcon: FontAwesomeIcons.paperPlane,
                    bSubmitOnSuffixIconPressed: true,
                    maxLines: 20,
                    onSubmit: () async {
                      if (_newCommentTextController.text.trim().isEmpty) return;
                      
                      String? userId = DatabaseMgr().localMgr.getUserId();
                      if (userId != null) {
                        DatabaseMgr().localMgr.updateRecipe(widget.recipeId, RecipeUpdate(id: widget.recipeId, comments: widget.comments + [Comment(userId: userId, comment: _newCommentTextController.text, initials: getInitials(DatabaseMgr().localMgr.getUserName()))])).then((value) {
                          _newCommentTextController.clear();
                          if (widget.onUpdate != null) widget.onUpdate!();
                        });
                      }
                    },
                  ),
                Column(
                    children: List<Widget>.generate(commentLength, (index) {
                      int invertedIndex = widget.comments.length - 1 - index;
                      return CommentWidget(
                        comment: widget.comments[invertedIndex],

                        onRemove: widget.onRemove != null ? (widget.comments[invertedIndex].userId == DatabaseMgr().localMgr.getUserId()) || widget.userAccess == AccessLevel.own ? () {
                          showAlertDialog(
                              context: context,
                              title: S.of(context).comment_remove_title,
                              description: Text(S.of(context).comment_remove_description)
                          ).then((value) {
                            if (value != null && value) {
                              widget.onRemove!(invertedIndex);
                            }
                          });
                        } : null : null,
                      );
                    })
                ),
                // IconButton(
                //   onPressed: () {
                //     setState(() {
                //       widgetApertureState = !widgetApertureState;
                //     });
                //   },
                //   icon: widgetApertureState ? const Icon(Icons.keyboard_arrow_up_rounded) : const Icon(Icons.keyboard_arrow_down_rounded)
                // )
              ],
            )
          )
        ],
      )
    );
  }
}

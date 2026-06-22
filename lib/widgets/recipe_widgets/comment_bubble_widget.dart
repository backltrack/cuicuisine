import 'package:cuicuisine/database/database_mgr.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../themes/theme_mgr.dart';

import '../../models/data_model.dart';

class CommentWidget extends StatefulWidget {
  final Comment comment;
  final Function? onRemove;

  const CommentWidget({super.key, required this.comment, this.onRemove});

  @override
  State<CommentWidget> createState() => _CommentWidgetState();
}

class _CommentWidgetState extends State<CommentWidget> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    List<Widget> orderedCommentWidget = [
      CircleAvatar(
          backgroundColor: ThemeMgr.getTheme(context)!.primaryColorDark,
          child: Text(widget.comment.initials)
      ),
      Expanded(
        child: Container(
          constraints: const BoxConstraints(
              minHeight: 48
          ),
          padding: const EdgeInsets.only(left: 12),
          margin: const EdgeInsets.only(left: 8, right: 8, bottom: 4, top: 4),
          decoration: BoxDecoration(
              color: ThemeMgr.getTheme(context)!.colorScheme.surface,
              borderRadius: BorderRadius.circular(12)
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                  child: Text(widget.comment.comment)
              ),
              if (widget.onRemove != null)
                IconButton(
                    onPressed: () {
                        widget.onRemove!();
                    },
                    icon: const Icon(FontAwesomeIcons.xmark, size: 14),
                    padding: EdgeInsets.zero
                )
            ],
          ),
        ),
      )
    ];

    return SizedBox(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: widget.comment.userId == DatabaseMgr().localMgr.getUserId() ? orderedCommentWidget.reversed.toList() : orderedCommentWidget,
      ),
    );
  }
}

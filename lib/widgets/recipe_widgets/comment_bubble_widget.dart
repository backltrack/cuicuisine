import 'package:cuicuisine/database/database_mgr.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../themes/theme_mgr.dart';

import '../../models/data_model.dart';

class CommentWidget extends StatefulWidget {
  final Comment comment;
  final Function()? onRemove;

  const CommentWidget({super.key, required this.comment, this.onRemove});

  @override
  State<CommentWidget> createState() => _CommentWidgetState();
}

class _CommentWidgetState extends State<CommentWidget> {
  String? initials;
  bool isLoaded = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    List<Widget> orderedCommentWidget = [
      CircleAvatar(
          backgroundColor: ThemeMgr.getTheme(context)!.primaryColorDark,
          child: Text(isLoaded ? initials! : "")
      ),
      Container(
        width: MediaQuery.of(context).size.width - 16-3*12-48,
        constraints: const BoxConstraints(
            minHeight: 48
        ),
        padding: const EdgeInsets.only(left: 12),
        margin: const EdgeInsets.only(left: 8, right: 8, bottom: 8),
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
            if (widget.comment.userId == DatabaseMgr().localMgr.getUserId())
              IconButton(
                  onPressed: () {
                    if (widget.onRemove != null) {
                      widget.onRemove!();
                    }
                  },
                  icon: const Icon(FontAwesomeIcons.times, size: 14),
                  padding: EdgeInsets.zero
              )
          ],
        ),
      )
    ];

    return isLoaded ?
        SizedBox(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: widget.comment.userId == DatabaseMgr().localMgr.getUserId() ? orderedCommentWidget.reversed.toList() : orderedCommentWidget,
          ),
        )
        :
        const Center(
          child: CircularProgressIndicator(),
        );
  }
}

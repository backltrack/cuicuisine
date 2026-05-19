import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import '../../models/data_model.dart';
import '../../themes/theme_mgr.dart';
import '../../utilities/string_functions.dart';
import '../../widgets/core_widgets/tag_item.dart';
import 'package:reorderables/reorderables.dart';

import '../../generated/l10n.dart';

class RecipeTagsWidget extends StatefulWidget {
  final List<Tag> tags;
  final bool isEditable;
  final Function(Tag)? onRemove;
  const RecipeTagsWidget({super.key, required this.tags, this.isEditable=false, this.onRemove});

  @override
  State<RecipeTagsWidget> createState() => _RecipeTagsWidgetState();
}

class _RecipeTagsWidgetState extends State<RecipeTagsWidget> {
  List<Tag> _currentTags = [];

  @override
  void initState() {
    super.initState();

    _currentTags = widget.tags;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {

    List<Widget> tagWidgetsList = List<Widget>.generate(_currentTags.length, (int index) => Container(
        key: UniqueKey(),
        margin: EdgeInsets.only(right: 4),
        child:TagItem(
          title: "#${_currentTags[index].name}",
          onRemove: widget.isEditable ? () {
            if (widget.onRemove != null) widget.onRemove!(_currentTags[index]);
          } : null
        )
    ));

    return Container(
      decoration: BoxDecoration(
          color: ThemeMgr.getTheme(context)!.cardColor,
          borderRadius: BorderRadius.circular(12)
      ),
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 12),
      margin: EdgeInsets.only(left: 8, top: 8, right: 8),
      child: widget.isEditable && _currentTags.isNotEmpty ?
        ReorderableRow(
          children: tagWidgetsList,
          onReorder: (int oldIndex, int newIndex) {
            _currentTags = moveListItem(_currentTags, oldIndex, newIndex) as List<Tag>;
            setState(() {});
          },
        )
        :
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _currentTags.isNotEmpty ? tagWidgetsList
                : [
              TagItem(
                  title: "#${S.of(context).no_tag}"
              ),
            ],
          )
        )
    );
  }
}

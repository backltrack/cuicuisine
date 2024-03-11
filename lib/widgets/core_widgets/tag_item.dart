import 'package:flutter/material.dart';

import '../../themes/theme_mgr.dart';

class TagItem extends StatelessWidget {
  final String title;
  final Function()? onRemove;

  TagItem({required this.title, this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Chip(
        label: Text(title, style: ThemeMgr.getTheme(context)!.textTheme.bodyLarge),
        deleteIcon: Icon(Icons.cancel),
        onDeleted: this.onRemove
    );
  }
}


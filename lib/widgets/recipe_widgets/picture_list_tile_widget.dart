import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../themes/theme_mgr.dart';

class PictureListTile extends StatefulWidget {
  const PictureListTile({Key? key, required this.picture, this.height=80, this.onRemove}) : super(key: key);

  final String picture;
  final double height;
  final Function()? onRemove;

  @override
  State<PictureListTile> createState() => _PictureListTileState();
}

class _PictureListTileState extends State<PictureListTile> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: widget.height,
      margin: EdgeInsets.only(left: 4, top: 4, right: 4, bottom: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: ThemeMgr.getTheme(context)!.cardColor
      ),
      child: Row(
        children: [
          Container(
            width: 12,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.only(topLeft: Radius.circular(4), bottomLeft: Radius.circular(4)),
                color: ThemeMgr.getTheme(context)!.primaryColorDark
            ),
          ),
          Image.network(widget.picture),
          Spacer(),
          IconButton(
            icon: Icon(FontAwesomeIcons.trashAlt),
            onPressed: widget.onRemove,
          )
        ],
      ),
    );
  }
}

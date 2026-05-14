import 'package:cuicuisine/database/database_mgr.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../themes/theme_mgr.dart';

class PictureListTile extends StatefulWidget {
  const PictureListTile({super.key, required this.recipeId, required this.imageId, this.height=80, this.onRemove});

  final String recipeId;
  final String imageId;
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
      margin: const EdgeInsets.only(left: 4, top: 4, right: 4, bottom: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: ThemeMgr.getTheme(context)!.cardColor
      ),
      child: Row(
        children: [
          Container(
            width: 12,
            decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(4), bottomLeft: Radius.circular(4)),
                color: ThemeMgr.getTheme(context)!.primaryColorDark
            ),
          ),
          FutureBuilder(
            future: DatabaseMgr().localMgr.getRecipeImage(widget.recipeId, widget.imageId),
            builder: (BuildContext context, AsyncSnapshot<Image> snapshot) {
              if (snapshot.hasData) {
                Image image = snapshot.data!;
                return image;
              }
              return Image.asset("assets/images/default_image.png");
            }
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(FontAwesomeIcons.trashCan),
            onPressed: widget.onRemove,
          )
        ],
      ),
    );
  }
}

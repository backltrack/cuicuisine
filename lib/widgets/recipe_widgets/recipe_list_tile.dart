import 'package:cuicuisine/database/database_mgr.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../themes/theme_mgr.dart';
import '../../utilities/time_functions.dart';
import '../../models/data_model.dart';

class RecipeListTile extends StatefulWidget {
  final Recipe recipe;
  final Function()? onTap;
  final Function()? onLongPress;
  final Function(TapDownDetails)? onTapDown;
  RecipeListTile({Key? key, required this.recipe, this.onTap, this.onLongPress, this.onTapDown}) : super(key: key);

  @override
  _RecipeListTileState createState() => _RecipeListTileState();
}

class _RecipeListTileState extends State<RecipeListTile> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // get is favorite recipe
    bool isFav = DatabaseMgr().localMgr.getUser()!.favoriteRecipes.contains(widget.recipe.id);

    const double cardHeight = 96;
    const double spacing = 8;

    return GestureDetector(
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      onTapDown: widget.onTapDown,
      child: Container(
        padding: const EdgeInsets.only(top: spacing, right: spacing, left: spacing),
        child: Stack(
          children: [
            Container(
              height: cardHeight,
              decoration: BoxDecoration(
                  color: ThemeMgr.getTheme(context)!.cardColor,
                  borderRadius: const BorderRadius.all(Radius.circular(4))
              ),
              margin: const EdgeInsets.only(left: cardHeight / 2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox.fromSize(
                    size: const Size(spacing * 2 + cardHeight / 2, 1),
                  ),
                  Flexible(
                    child: Container(
                        padding: const EdgeInsetsDirectional.all(spacing),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: cardHeight * 0.55,
                              alignment: Alignment.centerLeft,
                                child: SingleChildScrollView(
                                    child: Text(widget.recipe.name, style: ThemeMgr.getTheme(context)!.textTheme.displaySmall)
                                ),
                            ),
                            Row(
                              children: [
                                Row(
                                  children: [
                                    const FaIcon(FontAwesomeIcons.layerGroup),
                                    Container(
                                      margin: const EdgeInsetsDirectional.only(start: spacing),
                                      child: Text(widget.recipe.steps.length.toString()),
                                    )
                                  ],
                                ),
                                SizedBox.fromSize(
                                  size: const Size(spacing * 2, 1),
                                ),
                                Row(
                                  children: [
                                    const FaIcon(FontAwesomeIcons.clock),
                                    Container(
                                      margin: const EdgeInsetsDirectional.only(start: spacing),
                                      child: Text(minutesToTime(widget.recipe.preparationTime + widget.recipe.cookingTime + widget.recipe.waitingTime)),
                                    )
                                  ],
                                ),
                              ],
                            )
                          ],
                        )
                    ),
                  ),
                  Container(
                    alignment: AlignmentDirectional.topCenter,
                    margin: const EdgeInsets.fromLTRB(0, 0, 0, spacing),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: () async {
                            //set favorite in database
                            DatabaseMgr().localMgr.toggleFavorite(widget.recipe.id);
                            AppUser? newAppUser = DatabaseMgr().localMgr.getUser();

                            if (newAppUser != null) {
                              if (newAppUser.favoriteRecipes.contains(widget.recipe.id)) {
                                setState(() {
                                  isFav = true;
                                });
                              } else {
                                setState(() {
                                  isFav = false;
                                });
                              }
                            } else {
                              print("Connexion issue");
                            }
                          },
                          icon: FaIcon(FontAwesomeIcons.solidStar, size: 21, color: isFav ? Colors.amber : ThemeMgr.getTheme(context)!.iconTheme.color),
                        ),
                        FaIcon(widget.recipe.isDirty ? FontAwesomeIcons.arrowsRotate : FontAwesomeIcons.check)
                      ],
                    )
                  ),
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: ThemeMgr.getTheme(context)!.colorScheme.background, spreadRadius: spacing)]
              ),
              child: () {
                if (widget.recipe.pictures.isEmpty) {
                  return CircleAvatar(
                    maxRadius: (cardHeight) / 2,
                    backgroundImage: const AssetImage("assets/images/default_circle_image.png"),
                    backgroundColor: ThemeMgr.getTheme(context)!.cardColor,
                  );
                } else {
                  return FutureBuilder(
                    future: DatabaseMgr().localMgr.getFirstRecipeImage(widget.recipe.id),
                    builder: (BuildContext context, AsyncSnapshot<Image> snapshot) {
                      if (snapshot.hasData) {
                        return CircleAvatar(
                          maxRadius: (cardHeight) / 2,
                          foregroundImage: snapshot.data!.image,
                          backgroundColor: ThemeMgr.getTheme(context)!.primaryColorDark,
                        );
                      } else {
                        return CircleAvatar(
                          maxRadius: (cardHeight) / 2,
                          backgroundImage: const AssetImage("assets/images/default_circle_image.png"),
                          backgroundColor: ThemeMgr.getTheme(context)!.primaryColorDark,
                        );
                      }
                    }
                  );
                }
              } ()
            ),
          ],
        ),
      ),
    );
  }
}
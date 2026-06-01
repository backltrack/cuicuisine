import 'dart:math' show pi;
import 'dart:math' show sqrt;

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
  const RecipeListTile({super.key, required this.recipe, this.onTap, this.onLongPress, this.onTapDown});

  @override
  _RecipeListTileState createState() => _RecipeListTileState();
}

class _RecipeListTileState extends State<RecipeListTile> {
  Future<Image>? _imageFuture;
  bool _isFav = false;

  @override
  void initState() {
    super.initState();
    _isFav = DatabaseMgr().localMgr.getUser()?.favoriteRecipes.contains(widget.recipe.id) ?? false;
    _updateImageFuture();
  }

  @override
  void didUpdateWidget(RecipeListTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.recipe.id != widget.recipe.id ||
        oldWidget.recipe.pictures.length != widget.recipe.pictures.length) {
      _updateImageFuture();
    }
    _isFav = DatabaseMgr().localMgr.getUser()?.favoriteRecipes.contains(widget.recipe.id) ?? false;
  }

  void _updateImageFuture() {
    _imageFuture = widget.recipe.pictures.isNotEmpty
        ? DatabaseMgr().localMgr.getFirstRecipeImage(widget.recipe.id)
        : null;
  }

  @override
  Widget build(BuildContext context) {

    const double cardHeight = 110;
    const double spacing = 8;

    return GestureDetector(
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      onTapDown: widget.onTapDown,
      child: Container(
        padding: const EdgeInsets.only(top: 18, right: spacing, left: spacing),
        child: Stack(
          children: [
            // Card with a circular notch clipped from the left side
            Container(
              height: cardHeight,
              margin: const EdgeInsets.only(left: cardHeight / 2),
              child: ClipPath(
                clipper: const _TileCardClipper(circleRadius: cardHeight / 2 + 8, cornerRadius: 16),
                clipBehavior: Clip.hardEdge,
                child: Container(
                  color: ThemeMgr.getTheme(context)!.cardColor,
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
                                  child: Text(widget.recipe.name, style: ThemeMgr.getTheme(context)!.textTheme.displaySmall),
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
                                  SizedBox.fromSize(size: const Size(spacing * 2, 1)),
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
                          ),
                        ),
                      ),
                      Container(
                        alignment: AlignmentDirectional.topCenter,
                        margin: const EdgeInsets.fromLTRB(0, 0, 0, spacing * 1.5),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              onPressed: () async {
                                DatabaseMgr().localMgr.toggleFavorite(widget.recipe.id);
                                final newAppUser = DatabaseMgr().localMgr.getUser();
                                if (newAppUser != null) {
                                  setState(() {
                                    _isFav = newAppUser.favoriteRecipes.contains(widget.recipe.id);
                                  });
                                }
                              },
                              icon: FaIcon(FontAwesomeIcons.solidStar, size: 21, color: _isFav ? Colors.amber : ThemeMgr.getTheme(context)!.iconTheme.color),
                            ),
                            FaIcon(widget.recipe.isDirty ? FontAwesomeIcons.arrowsRotate : FontAwesomeIcons.check, size: 14, color: widget.recipe.isDirty ? Colors.blue : Colors.green)
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // CircleAvatar — sits in the notch, no shadow
            Container(
              child: () {
                if (widget.recipe.pictures.isEmpty) {
                  return CircleAvatar(
                    maxRadius: cardHeight / 2,
                    backgroundImage: const AssetImage("assets/images/default_circle_image.png"),
                    backgroundColor: ThemeMgr.getTheme(context)!.cardColor,
                  );
                } else {
                  return FutureBuilder(
                    future: _imageFuture,
                    builder: (BuildContext context, AsyncSnapshot<Image> snapshot) {
                      if (snapshot.hasData) {
                        return CircleAvatar(
                          maxRadius: cardHeight / 2,
                          foregroundImage: snapshot.data!.image,
                          backgroundColor: ThemeMgr.getTheme(context)!.primaryColorDark,
                        );
                      } else {
                        return CircleAvatar(
                          maxRadius: cardHeight / 2,
                          backgroundImage: const AssetImage("assets/images/default_circle_image.png"),
                          backgroundColor: ThemeMgr.getTheme(context)!.primaryColorDark,
                        );
                      }
                    },
                  );
                }
              }(),
            ),
          ],
        ),
      ),
    );
  }
}

// Clips a rectangle with rounded corners and a circular notch on the left side.
// The notch center is at (0, height/2) with the given circleRadius.
class _TileCardClipper extends CustomClipper<Path> {
  final double cornerRadius;
  final double circleRadius; // must be >= half the card height to create a full semicircular notch

  const _TileCardClipper({required this.circleRadius, required this.cornerRadius});

  @override
  Path getClip(Size size) {
    final path = Path();
    final r = cornerRadius;
    final cr = circleRadius;

    if (cr < size.height / 2) {
      // If the circle radius is too small to cut a full notch, just return a rounded rectangle.
      return Path()..addRRect(RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(r)));
    }
    if (cr == size.height / 2) {
      // If the circle radius is exactly half the height, the notch is a perfect semicircle that just touches the top and bottom edges. This is a special case where we can simplify the path.
      return Path()..addRRect(RRect.fromRectAndCorners(
        Offset.zero & size,
        topLeft: Radius.circular(r),
        bottomLeft: Radius.circular(r),
        topRight: Radius.circular(r),
        bottomRight: Radius.circular(r),
      ))..addOval(Rect.fromCircle(center: Offset(0, size.height / 2), radius: cr));
    }

    final double x = sqrt(cr * cr - (size.height / 2) * (size.height / 2));

    // Clockwise outline: top-left → top-right → bottom-right → bottom-left → notch arc back to top-left
    path.moveTo(x, 0);
    path.lineTo(size.width - r, 0);
    path.arcToPoint(Offset(size.width, r), radius: Radius.circular(r));
    path.lineTo(size.width, size.height - r);
    path.arcToPoint(Offset(size.width - r, size.height), radius: Radius.circular(r));
    path.lineTo(x, size.height);
    // Notch: arc counterclockwise from bottom (π/2) to top (-π/2) through the right half of the circle.
    // This cuts a semicircle into the left edge of the card.
    path.arcTo(
      Rect.fromCircle(center: Offset(0, size.height / 2), radius: cr),
      pi / 2,
      -pi,
      false,
    );
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
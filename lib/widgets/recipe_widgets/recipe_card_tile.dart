import 'package:flutter/material.dart';
import '../../models/data_model.dart';
import '../../themes/theme_mgr.dart';

class RecipeCardTile extends StatefulWidget {
  final Recipe recipe;
  RecipeCardTile({Key? key, required this.recipe}) : super(key: key);

  @override
  _RecipeCardTileState createState() => _RecipeCardTileState();
}

class _RecipeCardTileState extends State<RecipeCardTile> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final double cardWidth = MediaQuery.of(context).size.width / 2 - 20;
    
    return GestureDetector(
      child: Card(
        child: Container(
          width: cardWidth,
          child: Column(
            children: [
              ListTile(
                title: Text(widget.recipe.name),
              ),
              Container(
                height: 50,
                color: ThemeMgr.getTheme(context)!.cardColor,
              ),
              ListTile(
                subtitle: Text("my description"),
              )
            ],
          ),
        ),
      ),

      // Stack(
      //   children: [
      //     Container(
      //       height: cardHeight,
      //       decoration: BoxDecoration(
      //           color: ThemeMgr.getTheme(context)!.cardColor,
      //           borderRadius: BorderRadius.all(Radius.circular(4))
      //       ),
      //       margin: EdgeInsets.all(spacing),
      //       child: Row(
      //         mainAxisAlignment: MainAxisAlignment.start,
      //         children: [
      //           SizedBox.fromSize(
      //             size: Size(spacing * 2 + cardHeight, 1),
      //           ),
      //           Flexible(
      //             child: Container(
      //                 padding: EdgeInsetsDirectional.all(spacing),
      //                 child: Column(
      //                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      //                   crossAxisAlignment: CrossAxisAlignment.start,
      //                   children: [
      //                     Text(widget.recipe.name, style: ThemeMgr.getTheme(context)!.textTheme.headline2),
      //                     Row(
      //                       children: [
      //                         Row(
      //                           children: [
      //                             FaIcon(FontAwesomeIcons.layerGroup),
      //                             Container(
      //                               margin: EdgeInsetsDirectional.only(start: spacing),
      //                               child: Text(widget.recipe.steps.length.toString()),
      //                             )
      //                           ],
      //                         ),
      //                         SizedBox.fromSize(
      //                           size: Size(spacing * 2, 1),
      //                         ),
      //                         Row(
      //                           children: [
      //                             FaIcon(FontAwesomeIcons.clock),
      //                             Container(
      //                               margin: EdgeInsetsDirectional.only(start: spacing),
      //                               child: Text(minutesToTime(widget.recipe.preparationTime + widget.recipe.cookingTime + widget.recipe.waitingTime)),
      //                             )
      //                           ],
      //                         )
      //                       ],
      //                     )
      //                   ],
      //                 )
      //             ),
      //           ),
      //           Container(
      //             alignment: AlignmentDirectional.topCenter,
      //             child: MyIconButton(
      //                 onPressed: () {
      //                   //TODO
      //                   //set favorite in database
      //                 },
      //                 icon: FaIcon(FontAwesomeIcons.solidStar, size: 24),
      //             ),
      //           ),
      //         ],
      //       ),
      //     ),
      //     Container(
      //         margin: EdgeInsets.only(left: spacing/2, top: spacing / 2),
      //         child: Stack(
      //           children: [
      //             CircleAvatar(
      //               maxRadius: (cardHeight + spacing) / 2,
      //               backgroundColor: ThemeMgr.getTheme(context)!.colorScheme.background,
      //             ),
      //             Container(
      //               margin: EdgeInsetsDirectional.all(spacing),
      //               child: CircleAvatar(
      //                 maxRadius: (cardHeight - spacing) / 2,
      //                 backgroundColor: ThemeMgr.getTheme(context)!.primaryColorDark,
      //               ),
      //             )
      //           ],
      //         )
      //     ),
      //   ],
      // ),
      onTap: () {},
    );
  }
}
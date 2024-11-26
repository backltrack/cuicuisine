import 'package:flutter/material.dart';

import '../../generated/l10n.dart';
import '../../models/data_model.dart';
import '../../themes/theme_mgr.dart';

List<PopupMenuItem> makeRecipePopupMenu(BuildContext context, AccessLevel userAccess) {
  return [
    // Add to shopping list
    /// v1
    // PopupMenuItem(
    //     child: Container(
    //       width: MediaQuery.of(context).size.width / 2,
    //       child: Row(
    //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //         children: [
    //           Text(S.of(context).recipe_menu_cart, style: ThemeMgr.getTheme(context)!.textTheme.bodyLarge),
    //           Icon(Icons.add_shopping_cart_rounded)
    //         ],
    //       ),
    //     )
    // ),
    // share
    // PopupMenuItem(
    //     child: Container(
    //       width: MediaQuery.of(context).size.width / 2,
    //       child: Row(
    //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //         children: [
    //           Text(S.of(context).recipe_menu_share, style: ThemeMgr.getTheme(context)!.textTheme.bodyLarge),
    //           Icon(Icons.link)
    //         ],
    //       ),
    //     )
    // ),
    // Send to other book
    PopupMenuItem(
        value: "copy_into",
        child: Container(
          width: MediaQuery.of(context).size.width / 2,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(S.of(context).recipe_menu_copy_to_book, style: ThemeMgr.getTheme(context)!.textTheme.bodyLarge),
              Icon(Icons.copy, color: ThemeMgr.getTheme(context)!.textTheme.bodyLarge!.color)
            ],
          ),
        )
    ),
    // remove recipe
    if (userAccess.index > AccessLevel.read.index)
      PopupMenuItem(
        value: "remove",
        child: Container(
          width: MediaQuery.of(context).size.width / 2,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(S.of(context).recipe_menu_remove, style: ThemeMgr.getTheme(context)!.textTheme.bodyLarge),
              Icon(Icons.delete_forever, color: ThemeMgr.getTheme(context)!.textTheme.bodyLarge!.color)
            ],
          ),
        ),
      ),
  ];
}

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
    // Send to other book
    PopupMenuItem(
        value: "copy_into",
        child: SizedBox(
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
    // share
    PopupMenuItem(
        value: "share",
        child: SizedBox(
          width: MediaQuery.of(context).size.width / 2,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(S.of(context).recipe_menu_share, style: ThemeMgr.getTheme(context)!.textTheme.bodyLarge),
              Icon(Icons.share, color: ThemeMgr.getTheme(context)!.textTheme.bodyLarge!.color)
            ],
          ),
        )
    ),
    // export to pdf
    PopupMenuItem(
        value: "export_to_pdf",
        child: SizedBox(
          width: MediaQuery.of(context).size.width / 2,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(S.of(context).recipe_menu_export_to_pdf, style: ThemeMgr.getTheme(context)!.textTheme.bodyLarge),
              Icon(Icons.picture_as_pdf, color: ThemeMgr.getTheme(context)!.textTheme.bodyLarge!.color)
            ],
          ),
        )
    ),
    // remove recipe
    if (userAccess.index > AccessLevel.read.index)
      PopupMenuItem(
        value: "remove",
        child: SizedBox(
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

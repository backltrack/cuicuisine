import 'package:cuicuisine/themes/theme_mgr.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../models/data_model.dart';
import '../../widgets/core_widgets/badged_icon.dart';

import '../../fonts/custom_icons.dart';
import '../../themes/colors.dart';
import 'filter_bottom_menu.dart';
import '../core_widgets/my_icon_button.dart';

class BottomActionBar extends StatefulWidget {
  static bool isSortingAZ = true;
  static String sortingMethod = "alphaDown";
  static bool isListed = true;
  static bool displayFavorites = false;

  final VoidCallback? onCloseFilters;
  final VoidCallback? onResetFilters;
  final VoidCallback? onSortingMethodChanged;
  final VoidCallback? onChangeDisplay;
  final Book? currentBook;

  BottomActionBar({Key? key, this.onCloseFilters, this.onResetFilters, this.onSortingMethodChanged, this.onChangeDisplay, this.currentBook}) : super(key: key);

  @override
  _BottomActionBarState createState() => _BottomActionBarState();
}

class _BottomActionBarState extends State<BottomActionBar> {

  int _badgeNumber = 0;
  IconData sortMenuIcon = FontAwesomeIcons.sortAlphaDown;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppBar().preferredSize.height,
      child: BottomAppBar(
        notchMargin: 6.0,
        shape: CircularNotchedRectangle(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                BadgedIconButton(
                  key: UniqueKey(),
                  icon: Icon(Icons.filter_list, size: 28, color: DarkColors.writingColor),
                  badgeColor: ThemeMgr.getTheme(context)!.hintColor,
                  number: _badgeNumber,
                  onPressed: () {
                    setState(() {
                      showModalBottomSheet(
                          context: context,
                          backgroundColor: Colors.black.withOpacity(0.04),
                          builder: (BuildContext context) {
                            return FilterBottomMenu(
                              currentBook: widget.currentBook,
                              onReset: () {
                                setState(() {
                                  resetFilterItems();
                                  _badgeNumber = 0;
                                });
                                // Callback
                                if (widget.onResetFilters != null) widget.onResetFilters!();
                              },
                            );
                          }
                      ).whenComplete(() {
                        // Callback
                        if (widget.onCloseFilters != null) widget.onCloseFilters!();
                        // update badge number
                        setState(() {
                          _badgeNumber = getBadgeNumber();
                        });
                      });
                    });
                  },
                ),
                PopupMenuButton(
                  icon: FaIcon(sortMenuIcon, size: 20, color: DarkColors.writingColor),
                  itemBuilder: (context) => <PopupMenuItem>[
                    // first row
                    PopupMenuItem(
                      padding: EdgeInsets.only(left: 12),
                      child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: FaIcon(FontAwesomeIcons.sortAlphaDown),
                              onPressed: () {
                                setState(() {
                                  BottomActionBar.sortingMethod = "alphaDown";
                                  sortMenuIcon = FontAwesomeIcons.sortAlphaDown;
                                  if (widget.onSortingMethodChanged != null) widget.onSortingMethodChanged!();
                                });
                              },
                            ),
                            IconButton(
                                icon: FaIcon(CustomIcons.sort_time_down),
                                onPressed: () {
                                  setState(() {
                                    BottomActionBar.sortingMethod = "timeDown";
                                    sortMenuIcon = CustomIcons.sort_time_down;
                                    if (widget.onSortingMethodChanged != null) widget.onSortingMethodChanged!();
                                  });
                                }
                            ),
                            IconButton(
                              icon: FaIcon(CustomIcons.sort_last_down),
                              onPressed: () {
                                setState(() {
                                  BottomActionBar.sortingMethod = "lastUpdatedDown";
                                  sortMenuIcon = CustomIcons.sort_last_down;
                                  if (widget.onSortingMethodChanged != null) widget.onSortingMethodChanged!();
                                });
                              },
                            )
                          ],
                        )
                    ),
                    // second row
                    PopupMenuItem(
                        padding: EdgeInsets.only(left: 12),
                      child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: FaIcon(FontAwesomeIcons.sortAlphaUp),
                                onPressed: () {
                                  setState(() {
                                    BottomActionBar.sortingMethod = "alphaUp";
                                    sortMenuIcon = FontAwesomeIcons.sortAlphaUp;
                                    if (widget.onSortingMethodChanged != null) widget.onSortingMethodChanged!();
                                  });
                                },
                              ),
                              IconButton(
                                  icon: FaIcon(CustomIcons.sort_time_up),
                                  onPressed: () {
                                    setState(() {
                                      BottomActionBar.sortingMethod = "timeUp";
                                      sortMenuIcon = CustomIcons.sort_time_up;
                                      if (widget.onSortingMethodChanged != null) widget.onSortingMethodChanged!();
                                    });
                                  }
                              ),
                              IconButton(
                                icon: FaIcon(CustomIcons.sort_last_up),
                                onPressed: () {
                                  setState(() {
                                    BottomActionBar.sortingMethod = "lastUpdatedUp";
                                    sortMenuIcon = CustomIcons.sort_last_up;
                                    if (widget.onSortingMethodChanged != null) widget.onSortingMethodChanged!();
                                  });
                                },
                              )
                            ]
                        )
                    )
                  ],

                ),
                MyIconButton(
                    onPressed: () {
                      setState(() {
                        BottomActionBar.displayFavorites = !BottomActionBar.displayFavorites;
                      });
                      if (widget.onCloseFilters != null) widget.onCloseFilters!();
                    },
                    icon: FaIcon(BottomActionBar.displayFavorites ? FontAwesomeIcons.solidStar : FontAwesomeIcons.star, color: DarkColors.writingColor)
                ),
              ],
            ),

            /// V1
            // Row(
            //   children: [
            //     MyIconButton(
            //         onPressed: () {
            //           setState(() {
            //             BottomActionBar.isListed = !BottomActionBar.isListed;
            //           });
            //           // Callback
            //           if (widget.onChangeDisplay != null) widget.onChangeDisplay!();
            //         },
            //         icon: BottomActionBar.isListed ? FaIcon(FontAwesomeIcons.listUl) : FaIcon(FontAwesomeIcons.thLarge)
            //     ),
            //     SizedBox(
            //       width: 80,
            //     )
            //   ],
            // )
          ],
        ),
      ),
    );
  }
}

int getBadgeNumber() {
  return FilterBottomMenu.mandatoryIngredients.length + FilterBottomMenu.mandatoryTags.length
      + (FilterBottomMenu.time / (FilterBottomMenu.time + 1)).ceil().toInt();
}

void resetFilterItems() {
  FilterBottomMenu.displayFavorites = false;
  FilterBottomMenu.time = 0;
  FilterBottomMenu.isTimeMax = true;
  FilterBottomMenu.mandatoryIngredients.clear();
  FilterBottomMenu.mandatoryTags.clear();
}

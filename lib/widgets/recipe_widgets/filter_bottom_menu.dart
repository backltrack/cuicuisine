import 'package:cuicuisine/themes/theme_mgr.dart';
import 'package:flutter/material.dart';
import '../../themes/colors.dart';

import '../../utilities/time_functions.dart';
import '../../generated/l10n.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:duration_picker/duration_picker.dart';
import '../../models/data_model.dart';

// import '../../pages/item_selector_page.dart';
import '../../widgets/core_widgets/tag_item.dart';

class FilterBottomMenu extends StatefulWidget {
  static bool displayFavorites = false;
  static int time = 0;
  static bool isTimeMax = true;
  static List<String> mandatoryIngredients = [];
  static List<String> mandatoryTags = [];

  final Book? currentBook;
  final VoidCallback? onReset;

  FilterBottomMenu({this.currentBook, this.onReset});

  @override
  _FilterBottomMenuState createState() => _FilterBottomMenuState();
}

class _FilterBottomMenuState extends State<FilterBottomMenu> {

  final List<Map<String, dynamic>> _filterItems = [];

  void refreshFilterItems() {
    setState(() {
      _filterItems.clear();

      // add time limit
      if (FilterBottomMenu.time > 0) {
        _filterItems.add({
          'title': minutesToTime(FilterBottomMenu.time),
          'variable': FilterBottomMenu.time
        });
      }

      // add ingredients
      for (int i=0; i < FilterBottomMenu.mandatoryIngredients.length; i++) {
        _filterItems.add({
          'title': FilterBottomMenu.mandatoryIngredients[i],
          'variable': FilterBottomMenu.mandatoryIngredients,
          'index': i
        });
      }

      // add tags
      for (int i=0; i < FilterBottomMenu.mandatoryTags.length; i++) {
        _filterItems.add({
          'title': "#${FilterBottomMenu.mandatoryTags[i]}",
          'variable': FilterBottomMenu.mandatoryTags,
          'index': i
        });
      }
    });
  }

  void removeFilterItem(Map<String, dynamic> item) {
    if (item['variable'] == FilterBottomMenu.time) {
      FilterBottomMenu.time = 0;
    }
    else {
      item['variable'].removeAt(item['index']);
    }
    refreshFilterItems();
  }

  @override
  void initState() {
    super.initState();

    refreshFilterItems();
  }

  @override
  Widget build(BuildContext context) {
    const double margin = 24;

    return Container(
      height: MediaQuery.of(context).size.height * 0.5,
      decoration: BoxDecoration(
          color: ThemeMgr.getTheme(context)!.primaryColorDark,
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24))
      ),
      child: Stack(
        children: [
          Column(
            children: [
              // separator
              Container(
                height: 4,
                width: MediaQuery.of(context).size.width / 5,
                decoration: BoxDecoration(
                    color: DarkColors.writingColor,
                    borderRadius: BorderRadius.circular(2)
                ),
                margin: const EdgeInsets.only(top: 10, bottom: 10),
              ),
              // Filtered items wrap
              Expanded(
                child: Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    spacing: 5,
                    runSpacing: 5,
                    children: List<TagItem>.generate(_filterItems.length, (int index) => TagItem(
                      title: _filterItems[index]['title'],
                      onRemove: () {
                        setState(() {
                          removeFilterItem(_filterItems[index]);
                        });
                      },
                    ))
                ),
              ),
              Divider(
                thickness: 2,
                indent: MediaQuery.of(context).size.width / 10,
                endIndent: MediaQuery.of(context).size.width / 10,
                height: 25,
                color: DarkColors.writingColor,
              ),
              // Time
              Container(
                margin: const EdgeInsets.only(left: margin, right: margin),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 60,
                          alignment: AlignmentDirectional.centerStart,
                          margin: const EdgeInsets.only(left: 10),
                          child: const FaIcon(FontAwesomeIcons.clock, size: 24, color: DarkColors.writingColor),
                        ),
                        Text(S.of(context).filter_time, style: ThemeMgr.getTheme(context)!.textTheme.displayMedium!.copyWith(color: DarkColors.writingColor)),
                      ],
                    ),
                    SizedBox(
                      width: 150,
                      child: Row(
                        children: [
                          Container(
                            width: ButtonTheme.of(context).height + margin/2,
                            margin: const EdgeInsets.only(right: margin/2),
                            child: ElevatedButton(
                              child: FilterBottomMenu.isTimeMax ? const Text("<") : const Text(">"),
                              onPressed: () {
                                setState(() {
                                  FilterBottomMenu.isTimeMax = !FilterBottomMenu.isTimeMax;
                                });
                              },
                            ),
                          ),
                          Expanded(
                            child: ElevatedButton(
                              child: Text(FilterBottomMenu.time == 0 ? "--:--" : minutesToTime(FilterBottomMenu.time)),
                              onPressed: () async {
                                var resultingDuration = await showDurationPicker(
                                  context: context,
                                  initialTime: const Duration(hours: 1),
                                  // snapToMins: 10.0,
                                );
                                setState(() {
                                  FilterBottomMenu.time = resultingDuration != null ? resultingDuration.inMinutes : FilterBottomMenu.time;
                                });
                                refreshFilterItems();
                              },
                            ),
                          )
                        ]
                      ),
                    )
                  ],
                ),
              ),
              // Ingredients
              Container(
                margin: const EdgeInsets.only(left: margin, right: margin),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 60,
                          alignment: AlignmentDirectional.centerStart,
                          margin: const EdgeInsets.only(left: 10),
                          child: const FaIcon(FontAwesomeIcons.carrot, size: 24, color: DarkColors.writingColor),
                        ),
                        Text(S.of(context).filter_ingredients, style: ThemeMgr.getTheme(context)!.textTheme.displayMedium!.copyWith(color: DarkColors.writingColor)),
                      ],
                    ),
                    SizedBox(
                      width: 150,
                      child: ElevatedButton(
                        child: Text(S.of(context).add_button),
                        onPressed: () {
                          // add ingredient
                          // Navigator.of(context).pushNamed(ItemSelector.route, arguments: {
                          //   'items': widget.currentBook != null ? widget.currentBook!.bookIngredients : [],
                          //   'itemType': "ingredients"
                          // }).whenComplete(() {
                          //   refreshFilterItems();
                          // });
                        },
                      ),
                    )
                  ],
                ),
              ),
              // Tags
              Container(
                margin: const EdgeInsets.only(left: margin, right: margin),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 60,
                          alignment: AlignmentDirectional.centerStart,
                          margin: const EdgeInsets.only(left: 10),
                          child: const FaIcon(FontAwesomeIcons.hashtag, size: 24, color: DarkColors.writingColor),
                        ),
                        Text(S.of(context).filter_tags, style: ThemeMgr.getTheme(context)!.textTheme.displayMedium!.copyWith(color: DarkColors.writingColor)),
                      ],
                    ),
                    SizedBox(
                      width: 150,
                      child: ElevatedButton(
                        child: Text(S.of(context).add_button),
                        onPressed: () {
                          // add tag
                          // Navigator.of(context).pushNamed(ItemSelector.route, arguments: {
                          //   'items': widget.currentBook != null ? widget.currentBook!.tags : [],
                          //   'itemType': "tags"
                          // }).whenComplete(() {
                          //   refreshFilterItems();
                          // });
                        },
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(
                height: 12,
              ),
              FloatingActionButton.extended(
                onPressed: () {
                  Navigator.pop(context);
                },
                label: Text(S.of(context).filter_apply.toUpperCase()),
                backgroundColor: Colors.black87,
                shape: const StadiumBorder(),
              ),
              SizedBox(
                height: AppBar().preferredSize.height,
              )
            ],
          ),
          Positioned(
            top: 0,
            right: -4,
            child: ElevatedButton(
              onPressed: () {
                if (widget.onReset != null) widget.onReset!();
                refreshFilterItems();
                // rotation anim
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black87,
                  foregroundColor: Colors.white,
                  shape: const CircleBorder()
              ),
              child: const FaIcon(FontAwesomeIcons.undo, size: 15),
            ),
          ),
        ],
      )
    );
  }
}
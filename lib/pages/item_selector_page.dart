import 'package:diacritic/diacritic.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../generated/l10n.dart';
import '../../models/data_model.dart';
import '../../utilities/string_functions.dart';
import '../../widgets/recipe_widgets/filter_bottom_menu.dart';
import '../../widgets/core_widgets/search_app_bar.dart';
import '../themes/theme_mgr.dart';

class ItemSelector extends StatefulWidget {
  static const String route = "/home/ingredient_selection";

  const ItemSelector({super.key});

  @override
  _ItemSelectorState createState() => _ItemSelectorState();
}

class _ItemSelectorState extends State<ItemSelector> {

  final List<int> _selectedIndices = [];

  String _search = "";

  @override
  Widget build(BuildContext context) {

    // load params
    final routeArgs = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
    final List<dynamic> items = routeArgs['items']!;
    final String itemType = routeArgs['itemType'];

    // init already filtered ingredients
    if (_selectedIndices.isEmpty) {
      if (itemType == "ingredients") {
        for (int i = 0; i < items.length; i++) {
          if (FilterBottomMenu.mandatoryIngredients.contains(items[i])) {
            _selectedIndices.add(i);
          }
        }
      } else if (itemType == "tags") {
        for (int i = 0; i < items.length; i++) {
          if (FilterBottomMenu.mandatoryTags.any((t) => t.id == (items[i] as Tag).id)) {
            _selectedIndices.add(i);
          }
        }
      }
    }

    // set title
    String title = "";
    if (itemType == "ingredients") {
      title = S.of(context).filter_ingredients;
    } else if (itemType == "tags") {
      title = S.of(context).filter_tags;
    }

    // indices matching the current search, in original order
    final List<int> matchingIndices = [];
    for (int i = 0; i < items.length; i++) {
      final String displayName = itemType == "tags" ? (items[i] as Tag).name : items[i] as String;
      if (_search.isEmpty || removeDiacritics(displayName.toLowerCase()).contains(removeDiacritics(_search.toLowerCase()))) {
        matchingIndices.add(i);
      }
    }

    // render entries: either a category header (String) or an index (int) into `items`
    final List<dynamic> renderEntries = itemType == "tags" ? _groupByCategory(items, matchingIndices) : matchingIndices;

    return Scaffold(
      appBar: SearchAppBar(
        myTitle: title,
        onSearchChanged: (String val) {
          setState(() {
            _search = val;
          });
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        label: Text(S.of(context).add_button),
        onPressed: () {
          setState(() {
            if (itemType == "ingredients") {
              FilterBottomMenu.mandatoryIngredients.clear();
              FilterBottomMenu.mandatoryIngredients.addAll(
                _selectedIndices.map((i) => items[i] as String).toList()
              );
            } else if (itemType == "tags") {
              FilterBottomMenu.mandatoryTags.clear();
              FilterBottomMenu.mandatoryTags.addAll(
                _selectedIndices.map((i) => items[i] as Tag).toList()
              );
            }
          });
          Navigator.pop(context);
        },
      ),
      body: ListView.builder(
        itemCount: renderEntries.length,
        itemBuilder: (context, i) {
          final entry = renderEntries[i];
          if (entry is String) return _categoryHeader(context, entry);

          final int index = entry as int;
          final String displayName = itemType == "tags" ? (items[index] as Tag).name : items[index] as String;
          return ListTile(
            title: Text(itemType == "ingredients" ? beautifyName(displayName) : displayName),
            trailing: IconButton(
                onPressed: () {
                  setState(() {
                    if (_selectedIndices.contains(index)) {
                      _selectedIndices.remove(index);
                    } else {
                      _selectedIndices.add(index);
                    }
                  });
                },
                icon: _selectedIndices.contains(index) ? const FaIcon(FontAwesomeIcons.solidCircleCheck) : const FaIcon(FontAwesomeIcons.circlePlus)
            ),
          );
        },
      ),
    );
  }

  // Returns category headers (String) interleaved with item indices (int), empty category sorted last.
  List<dynamic> _groupByCategory(List<dynamic> items, List<int> indices) {
    final Map<String, List<int>> byCategory = {};
    for (final i in indices) {
      final String category = (items[i] as Tag).category;
      (byCategory[category] ??= []).add(i);
    }

    final List<String> sortedCategories = byCategory.keys.toList()
      ..sort((a, b) {
        if (a.isEmpty) return 1;
        if (b.isEmpty) return -1;
        return removeDiacritics(a.toLowerCase()).compareTo(removeDiacritics(b.toLowerCase()));
      });

    final List<dynamic> result = [];
    for (final category in sortedCategories) {
      result.add(category);
      final List<int> categoryIndices = byCategory[category]!
        ..sort((a, b) => removeDiacritics((items[a] as Tag).name).compareTo(removeDiacritics((items[b] as Tag).name)));
      result.addAll(categoryIndices);
    }
    return result;
  }

  Widget _categoryHeader(BuildContext context, String category) {
    final String label = category.isEmpty ? S.of(context).tag_category_other : beautifyName(category);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          Text(label, style: ThemeMgr.getTheme(context)!.textTheme.displayMedium),
          const SizedBox(width: 8),
          const Expanded(child: Divider()),
        ],
      ),
    );
  }
}

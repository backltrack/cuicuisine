import 'package:diacritic/diacritic.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../generated/l10n.dart';
import '../../models/data_model.dart';
import '../../utilities/string_functions.dart';
import '../../widgets/recipe_widgets/filter_bottom_menu.dart';
import '../../widgets/core_widgets/search_app_bar.dart';

class ItemSelector extends StatefulWidget {
  static const String route = "/home/ingredient_selection";

  const ItemSelector();

  @override
  _ItemSelectorState createState() => _ItemSelectorState();
}

class _ItemSelectorState extends State<ItemSelector> {

  List<int> _selectedIndices = [];

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
    String _title = "";
    if (itemType == "ingredients") {
      _title = S.of(context).filter_ingredients;
    } else if (itemType == "tags") {
      _title = S.of(context).filter_tags;
    }

    return Scaffold(
      appBar: SearchAppBar(
        myTitle: _title,
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
        itemCount: items.length,
        itemBuilder: (context, index) {
          final String displayName = itemType == "tags" ? (items[index] as Tag).name : items[index] as String;
          return _search != "" && removeDiacritics(displayName.toLowerCase()).contains(removeDiacritics(_search.toLowerCase())) || _search == "" ?
            ListTile(
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
          ) :
          const SizedBox();
        },
      ),
    );
  }
}

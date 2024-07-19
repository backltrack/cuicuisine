import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../generated/l10n.dart';
import '../../utilities/string_functions.dart';
import '../../widgets/recipe_widgets/filter_bottom_menu.dart';
import '../../widgets/core_widgets/my_icon_button.dart';
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
    final List<String> items = routeArgs['items']!;
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
          if (FilterBottomMenu.mandatoryTags.contains(items[i])) {
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
          List<String> _filteredIngredients = [];
          for (int index in _selectedIndices) {
            _filteredIngredients.add(items[index]);
          }
          setState(() {
            if (itemType == "ingredients") {
              FilterBottomMenu.mandatoryIngredients.clear();
              FilterBottomMenu.mandatoryIngredients.addAll(_filteredIngredients);
            } else if (itemType == "tags") {
              FilterBottomMenu.mandatoryTags.clear();
              FilterBottomMenu.mandatoryTags.addAll(_filteredIngredients);
            }
          });
          Navigator.pop(context);
        },
      ),
      body: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          return _search != "" && items[index].contains(_search) || _search == "" ?
            ListTile(
              title: Text(itemType == "ingredients" ? beautifyName(items[index]) : items[index]),
              trailing: MyIconButton(
                  onPressed: () {
                    setState(() {
                      if (_selectedIndices.contains(index)) {
                        _selectedIndices.remove(index);
                      } else {
                        _selectedIndices.add(index);
                      }
                    });
                  },
                  icon: _selectedIndices.contains(index) ? FaIcon(FontAwesomeIcons.solidCheckCircle) : FaIcon(FontAwesomeIcons.plusCircle)
              ),
          ) :
          SizedBox();
        },
      ),
    );
  }
}

import 'package:cuicuisine/database/database_mgr.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../generated/l10n.dart';
import '../../models/default_data.dart';
import '../../models/data_model.dart';
import '../../models/local_model.dart';
import '../../themes/theme_mgr.dart';
import '../../utilities/string_functions.dart';
import '../../utilities/toast_notifier.dart';
import '../../widgets/core_widgets/my_text_field.dart';
import '../../widgets/core_widgets/my_type_ahead_text_field.dart';

class IngredientEditionPage extends StatefulWidget {

  const IngredientEditionPage({Key? key}) : super(key: key);

  @override
  _IngredientEditionPageState createState() => _IngredientEditionPageState();
}

class _IngredientEditionPageState extends State<IngredientEditionPage> {
  Ingredient ingredient = Ingredient(name: '', quantity: 0, unit: 'none');
  late Unit unitMgr;
  DensityTable densityTable = DensityTable();

  TextEditingController nameTextEditingController = TextEditingController();
  TextEditingController quantityTextEditingController = TextEditingController();
  TextEditingController densityTextEditingController = TextEditingController();

  bool shouldInit = true;

  bool expansionTileState = false;

  String currentUnit = "";
  String currentMeasure = "";

  @override
  void initState() {
    super.initState();
    nameTextEditingController.addListener(() {
      if (densityTextEditingController.text.isNotEmpty) {
        // search for density if not set
        if (double.parse(densityTextEditingController.text) == 0) {
          densityTextEditingController.text = densityTable.getDensity(
              nameTextEditingController.text.trim().toLowerCase()).toString();
          if (double.parse(densityTextEditingController.text) != 0) {
            // notify user that density has changed
            setState(() {
              expansionTileState = true;
            });
            ToastNotifier().showInfo(S.of(context).ingredient_density_updated);
          }
        }
        // reinit if empty name
        if (nameTextEditingController.text.isEmpty) {
          densityTextEditingController.text = "0.0";
        }
      }
    });
  }

  @override
  void dispose() {
    nameTextEditingController.dispose();
    quantityTextEditingController.dispose();
    densityTextEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // load params
    final routeArgs = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
    final bool isNew = routeArgs['isNew'];
    final String locale = routeArgs['locale'];
    if (!isNew) ingredient = routeArgs['ingredient']!;

    if (shouldInit) {
      nameTextEditingController.text = ingredient.name;
      quantityTextEditingController.text = ingredient.quantity.toString();
      densityTextEditingController.text = ingredient.density.toString();

      setState(() {
        unitMgr = Unit(locale);
      });
      shouldInit = false;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(isNew ? S.of(context).new_ingredient_title : S.of(context).ingredient_edition_title),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: 300,
        margin: const EdgeInsets.only(top: 12),
        child:  Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width*0.8,
                  child: MyTypeAheadTextField(
                    label: S.of(context).ingredient_name,
                    textEditingController: nameTextEditingController,
                    itemBuilder: (context, suggestion) {
                      return ListTile(
                        title: Text(beautifyName(suggestion)),
                      );
                    },
                    suggestionsCallback: (String pattern) {
                      List<String> suggestions = [];
                      if (pattern != '') {
                        for (String ingredient in DatabaseMgr().localMgr.getBookIngredients()) {
                          if (ingredient.toLowerCase().contains(pattern.toLowerCase().trim())) suggestions.add(ingredient.toLowerCase().trim());
                        }
                        for (String ingredient in defaultIngredients[locale]!) {
                          if (ingredient.toLowerCase().contains(pattern.toLowerCase()) &&
                              !suggestions.contains(ingredient.toLowerCase().trim())) suggestions.add(ingredient.toLowerCase().trim());
                        }
                      }

                      suggestions.sort();
                      return suggestions;
                    },
                    onSuggestionSelected: (String suggestion) {
                      nameTextEditingController.text = beautifyName(suggestion);
                    }
                  )
                )
              ],
            ),

             Row(
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width*0.8,
                  child: MyTextField(
                    textEditingController: quantityTextEditingController,
                    label: S.of(context).ingredient_quantity,
                    keyboardType: TextInputType.number,
                    suffixText: ingredient.unit != 'none' ? ingredient.unit : null,
                  ),
                ),

                PopupMenuButton(
                  icon: const FaIcon(FontAwesomeIcons.scaleBalanced, size: 20),
                  itemBuilder: (context) => List<PopupMenuItem>.generate(unitMgr.getAllUnits().length, (unitIndex) => PopupMenuItem(
                    child: Text(unitMgr.getAllUnits()[unitIndex], style: ThemeMgr.getTheme(context)!.textTheme.bodyLarge),
                    onTap: () {
                      setState(() {
                        ingredient.unit = unitMgr.getAllUnits()[unitIndex];
                      });
                    }
                  )),
                ),
              ],
            ),

            const Divider(),
            Theme(
              data: ThemeMgr.getTheme(context)!.copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                  key: UniqueKey(),
                  initiallyExpanded: expansionTileState,
                  onExpansionChanged: (bool state) {
                    expansionTileState = state;
                  },
                  title: Text(S.of(context).ingredient_advanced),
                  collapsedTextColor: ThemeMgr.getTheme(context)!.textTheme.bodyLarge!.color,
                  textColor: ThemeMgr.getTheme(context)!.textTheme.bodyLarge!.color,
                  iconColor: ThemeMgr.getTheme(context)!.textTheme.bodyLarge!.color,
                  collapsedIconColor: ThemeMgr.getTheme(context)!.textTheme.bodyLarge!.color,

                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width*0.8,
                      child: MyTextField(
                        textEditingController: densityTextEditingController,
                        label: S.of(context).ingredient_density,
                        keyboardType: TextInputType.number,
                      ),
                    )
                  ]
              )
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        label: Text(S.of(context).recipe_edition_update),
        onPressed: () {
          if (nameTextEditingController.text != "") {
            ingredient.name = beautifyName(nameTextEditingController.text.trim());
            ingredient.quantity =
                double.tryParse(quantityTextEditingController.text.replaceAll(',', '.')) ?? 0;
            ingredient.density =
                double.tryParse(densityTextEditingController.text) ?? 0;
            Navigator.pop(context, ingredient);
          } else {
            ToastNotifier().showError(S.of(context).error_name_empty);
          }
        }
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat
    );
  }
}

import 'package:cuicuisine/l10n/locale_mgr.dart';
import 'package:cuicuisine/themes/theme_mgr.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../generated/l10n.dart';
import '../../models/data_model.dart';
import '../../utilities/string_functions.dart';
import '../../widgets/recipe_widgets/quantity_widget.dart';
import 'package:reorderables/reorderables.dart';

import 'ingredient_edition_tile_widget.dart';
import '../core_widgets/my_outlined_button.dart';

class RecipeIngredientsEditionWidget extends StatefulWidget {
  final List<Ingredient> ingredients;
  final int defaultQuantity;
  final String quantityType;
  final Function(int) onEdit;
  final Function(int) onRemove;
  final Function() onAddIngredient;
  final Function(int) onNumberChanged;
  final Function(String) onQuantityTypeChanged;

  RecipeIngredientsEditionWidget({
    super.key,
    required this.ingredients,
    required this.defaultQuantity,
    required this.quantityType,
    required this.onEdit,
    required this.onRemove,
    required this.onAddIngredient,
    required this.onNumberChanged,
    required this.onQuantityTypeChanged
  });

  @override
  _RecipeIngredientsEditionWidgetState createState() => _RecipeIngredientsEditionWidgetState();
}

class _RecipeIngredientsEditionWidgetState extends State<RecipeIngredientsEditionWidget> {

  int _quantity = 1;
  String _quantityType = "";
  List<Ingredient> _ingredients = [];

  String? locale;

  @override
  void initState() {
    super.initState();

    _quantity = widget.defaultQuantity;
    _quantityType = widget.quantityType;
    _ingredients = widget.ingredients;

    locale = LocaleMgr.getLocale(context);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {

    return locale == null ? const Center(child: CircularProgressIndicator()) :
    Container(
      decoration: BoxDecoration(
          color: ThemeMgr.getTheme(context)!.cardColor,
          borderRadius: BorderRadius.circular(12)
      ),
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(left: 8, top: 8, right: 8),
      child: Column(
        children: [
          Text(
            S.of(context).ingredient_widget_title,
            style: ThemeMgr.getTheme(context)!.textTheme.displayMedium,
          ),
          const SizedBox(height: 12),
          // persons selector
          QuantityEditorWidget(
            quantity: _quantity,
            quantityType: _quantityType,
            isEdition: true,
            onQuantityChanged: (int value) {
              widget.onNumberChanged(value);
                _quantity = value;
            },
            onTypeChanged: (String value) {
              widget.onQuantityTypeChanged(value);
                _quantityType = value;
            },
          ),

          const SizedBox(height: 12),
          //Ingredient Viewer
          ReorderableColumn(
            children: List<Widget>.generate(_ingredients.length, (ingredientIndex) {
              Ingredient ingredient = _ingredients[ingredientIndex];

              // return IngredientTile(ingredient: ingredient, locale: locale!);
              return IngredientEditionTile(
                key: UniqueKey(),
                ingredient: ingredient,
                locale: locale!,
                onEdit: () {
                  widget.onEdit(ingredientIndex);
                },
                onRemove: () {
                  widget.onRemove(ingredientIndex);
                }
              );
            }).toList(),
            onReorder: (int oldIndex, int newIndex) {
              _ingredients = moveListItem(_ingredients, oldIndex, newIndex) as List<Ingredient>;
              setState(() {});
            },
          ),
          MyOutlinedButton(
              text: S.of(context).add_button,
              icon: FontAwesomeIcons.plus,
              onPressed: widget.onAddIngredient
          )
        ],
      ),
    );
  }
}

import 'package:cuicuisine/l10n/locale_mgr.dart';
import 'package:cuicuisine/themes/theme_mgr.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../generated/l10n.dart';
import '../../models/data_model.dart';
import '../../utilities/string_functions.dart';
import '../../widgets/recipe_widgets/quantity_widget.dart';

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

  const RecipeIngredientsEditionWidget({
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
  late String locale;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;
    _quantity = widget.defaultQuantity;
    _quantityType = widget.quantityType;
    _ingredients = widget.ingredients;
    locale = LocaleMgr.getLocale(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
          ReorderableListView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            children: List<Widget>.generate(_ingredients.length, (ingredientIndex) {
              final ingredient = _ingredients[ingredientIndex];
              return IngredientEditionTile(
                key: ObjectKey(ingredient),
                ingredient: ingredient,
                locale: locale,
                onEdit: () { widget.onEdit(ingredientIndex); },
                onRemove: () { widget.onRemove(ingredientIndex); },
              );
            }),
            onReorder: (int oldIndex, int newIndex) {
              if (newIndex > oldIndex) newIndex--;
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

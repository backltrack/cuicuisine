import 'dart:math';

import 'package:cuicuisine/database/database_mgr.dart';
import 'package:cuicuisine/l10n/localeMgr.dart';
import 'package:flutter/material.dart';
import '../../generated/l10n.dart';
import '../../models/data_model.dart';
import '../../themes/theme_mgr.dart';
import '../../widgets/recipe_widgets/ingredient_tile_widget.dart';
import '../../widgets/core_widgets/my_icon_button.dart';
import '../../widgets/recipe_widgets/quantity_widget.dart';


class RecipeIngredientsWidget extends StatefulWidget {
  final List<Ingredient> ingredients;
  final int defaultQuantity;
  final String quantityType;

  RecipeIngredientsWidget({Key? key, required this.ingredients, required this.quantityType, required this.defaultQuantity}) : super(key: key);

  @override
  _RecipeIngredientsWidgetState createState() => _RecipeIngredientsWidgetState();
}

class _RecipeIngredientsWidgetState extends State<RecipeIngredientsWidget> {

  int _quantity = 1;
  double _multiplier = 1;

  bool _isListViewOpened = false;

  int _maxIngredientDisplay = 6;

  String? locale;

  // List<String> currentUnits = [];

  @override
  void initState() {
    super.initState();

    _quantity = widget.defaultQuantity;

    locale = LocaleMgr.getLocale(context);
    setState(() {});
  }
  
  String parseQuantity(double quantity) {
    if (quantity.round().toDouble() == quantity) {
      return quantity.round().toString();
    } 
    else if ((quantity * 10).round().toDouble() == quantity * 10) {
      return quantity.toStringAsFixed(1);
    }
    else if ((quantity * 100).round().toDouble() == quantity * 100) {
      return quantity.toStringAsFixed(2);
    }
    else {
      return quantity.toStringAsFixed(3);
    }
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
            style: ThemeMgr.getTheme(context)!.textTheme.headline2,
          ),
          const SizedBox(height: 12),
          // persons selector
          QuantityEditorWidget(
            key: UniqueKey(),
            quantity: _quantity,
            multiplier: _multiplier,
            quantityType: widget.quantityType,
            onQuantityChanged: (int value) {
              setState(() {
                _quantity = value;
              });
            },
            onMultiplierChanged: (double value) {
              setState(() {
                _multiplier = value;
              });
            },
          ),

          const SizedBox(height: 12),
          //Ingredient Viewer
          Column(
            children: List<Widget>.generate(_isListViewOpened ? widget.ingredients.length : [_maxIngredientDisplay, widget.ingredients.length].reduce(min), (ingredientIndex) {
              Ingredient ingredient = widget.ingredients[ingredientIndex];
              double quantityRatio = _quantity * _multiplier / widget.defaultQuantity.toDouble();

              return IngredientTile(
                ingredient: ingredient,
                locale: locale!,
                quantityRatio: quantityRatio,
              );
            })
          ),
          // Expand button
          if (widget.ingredients.length > _maxIngredientDisplay) MyIconButton(
            onPressed: () {
              setState(() {
                _isListViewOpened = !_isListViewOpened;
              });
            },
            icon: _isListViewOpened ? const Icon(Icons.keyboard_arrow_up_rounded) : const Icon(Icons.keyboard_arrow_down_rounded)
          )
        ],
      ),
    );
  }
}

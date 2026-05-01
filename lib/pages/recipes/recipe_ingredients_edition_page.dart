import 'package:cuicuisine/models/update_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../../generated/l10n.dart';
import '../../database/database_mgr.dart';
import '../../l10n/localeMgr.dart';
import '../../models/data_model.dart';
import '../../widgets/core_widgets/alert_dialog.dart';

import '../../widgets/recipe_widgets/recipe_ingredients_edition_widget.dart';

class RecipeIngredientsEditionPage extends StatefulWidget {

  const RecipeIngredientsEditionPage({Key? key}) : super(key: key);

  @override
  _RecipeIngredientsEditionPageState createState() => _RecipeIngredientsEditionPageState();
}

class _RecipeIngredientsEditionPageState extends State<RecipeIngredientsEditionPage> {
  List<Ingredient> ingredients = [];
  int quantity = 2;
  String quantityType = "";

  String? locale;

  bool shouldInit = true;

  @override
  void initState() {
    super.initState();
    
    locale = LocaleMgr.getLocale(context);
    setState(() {});
  }


  @override
  Widget build(BuildContext context) {
    // load params
    final routeArgs = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
    final String recipeId = routeArgs['id']!;
    final List<Ingredient> currentRecipeIngredients = routeArgs['ingredients']!;
    final int currentQuantity = routeArgs['quantity']!;
    final String currentQuantityType = routeArgs['quantityType']!;

    if (shouldInit) {
      ingredients.clear();
      ingredients.addAll(currentRecipeIngredients);
      
      quantity = currentQuantity;
      quantityType = currentQuantityType;

      shouldInit = false;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).recipe_edition_ingredients_title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () async {
            bool returnValue = false;
            await showAlertDialog(
              context: context,
              title: S.of(context).popup_loose_data_title,
              description: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(S.of(context).popup_loose_data_1, textAlign: TextAlign.center),
                  Text(S.of(context).recipe_edition_update, style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(S.of(context).popup_loose_data_2, textAlign: TextAlign.center),
                  Text(S.of(context).popup_loose_data_3, textAlign: TextAlign.center)
                ],
              ),
            ).then((value) {
              print(value);
              if (value != null && value) {
                returnValue = true;
              }
            });

            SchedulerBinding.instance.addPostFrameCallback((_) {
              Navigator.of(context).pop(returnValue);
            });
          }
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            RecipeIngredientsEditionWidget(
              key: UniqueKey(),
              ingredients: ingredients,
              defaultQuantity: quantity,
              quantityType: quantityType,
              onNumberChanged: (int value) {
                setState(() {
                  quantity = value;
                });
              },
              onQuantityTypeChanged: (String value) {
                setState(() {
                  quantityType = value;
                });
              },
              onRemove: (int index) {
                ingredients.removeAt(index);
                setState(() {});
              },
              onEdit: (int index) async {
                Ingredient? result = await Navigator.pushNamed(context, '${ModalRoute.of(context)!.settings.name!}/edition', arguments: {
                  'isNew': false,
                  'locale': locale,
                  'ingredient': ingredients[index]
                });
                if (result != null) {
                  ingredients[index].bookIngredientId = result.bookIngredientId;
                  ingredients[index].unitOverride = result.unitOverride;
                  ingredients[index].quantity = result.quantity;
                  ingredients[index].densityOverride = result.densityOverride;
                  setState(() {});
                }
              },
              onAddIngredient: () async {
                var result = await Navigator.pushNamed(context, '${ModalRoute.of(context)!.settings.name!}/edition', arguments: {
                  'isNew': true,
                  'locale': locale
                });
                if (result != null && result is Ingredient) {
                  ingredients.add(result);
                  setState(() {});
                }
              },
            ),
            const SizedBox(height: 80)
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
          label: Text(S.of(context).recipe_edition_update),
          onPressed: () {
            DatabaseMgr().localMgr.updateRecipe(
              recipeId,
              RecipeUpdate(
                id: recipeId,
                quantity: quantity,
                quantityType: quantityType,
                recipeIngredients: ingredients
              )
            );

            Navigator.pop(context, 'update');
          }
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat
    );
  }
}

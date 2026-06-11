import 'package:flutter/material.dart';

import '../../database/database_mgr.dart';
import '../../generated/l10n.dart';
import '../../models/data_model.dart';
import '../../themes/theme_mgr.dart';
import 'image_popup.dart';
import 'image_slideshow.dart';
import 'recipe_ingredients_widget.dart';
import 'recipe_steps_widget.dart';
import 'recipe_tags_widget.dart';
import 'recipe_time_widget.dart';

// Inline read-only recipe view for the ultra-wide (≥ 1200px) third column.
// Shows recipe content without navigation or edit controls.
class RecipePanelWidget extends StatelessWidget {
  final Recipe? recipe;

  const RecipePanelWidget({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    if (recipe == null) return _buildPlaceholder(context);

    final theme = ThemeMgr.getTheme(context)!;

    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: Theme.of(context).brightness == Brightness.dark
              ? const AssetImage('assets/images/background.png')
              : const AssetImage('assets/images/background_light.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image header
            MyImageSlideshow(
              recipeId: recipe!.id,
              onTap: (image) {
                showImagePopup(context: context, image: image);
              }
            ),

            // Recipe name
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Text(recipe!.name, style: theme.textTheme.displayLarge),
            ),

            // Time
            RecipeTimeWidget(
              preparationTime: recipe!.preparationTime,
              waitingTime: recipe!.waitingTime,
              cookingTime: recipe!.cookingTime,
            ),

            // Tags
            RecipeTagsWidget(
              key: ValueKey('tags_${recipe!.id}'),
              tags: DatabaseMgr().localMgr.getRecipeTags(recipe!.id),
            ),

            // Ingredients
            RecipeIngredientsWidget(
              key: ValueKey('ingredients_${recipe!.id}'),
              ingredients: recipe!.recipeIngredients,
              defaultQuantity: recipe!.quantity,
              quantityType: recipe!.quantityType,
            ),

            // Steps
            RecipeStepsWidget(steps: recipe!.steps),

            const SizedBox(height: 96),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: Theme.of(context).brightness == Brightness.dark
              ? const AssetImage('assets/images/background.png')
              : const AssetImage('assets/images/background_light.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.menu_book_outlined,
              size: 64,
              color: ThemeMgr.getTheme(context)!.textTheme.bodyMedium!.color,
            ),
            const SizedBox(height: 16),
            Text(
              S.of(context).select_a_recipe,
              style: ThemeMgr.getTheme(context)!.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

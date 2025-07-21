import 'package:cuicuisine/database/database_mgr.dart';
import 'package:cuicuisine/models/update_model.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../generated/l10n.dart';
import '../../models/data_model.dart';
import '../../pages/404.dart';
import '../../themes/theme_mgr.dart';
import '../../widgets/core_widgets/alert_dialog.dart';
import '../../widgets/recipe_widgets/image_slideshow.dart';
import '../../widgets/recipe_widgets/recipe_popup_menu.dart';
import '../../widgets/recipe_widgets/book_picker_popup.dart';
import '../../widgets/recipe_widgets/recipe_variants_widget.dart';
import '../../widgets/recipe_widgets/widget_selection_overlay_widget.dart';
import '../../widgets/recipe_widgets/recipe_ingredients_widget.dart';
import '../../widgets/recipe_widgets/recipe_steps_widget.dart';
import '../../widgets/recipe_widgets/recipe_tags_widget.dart';
import '../../widgets/recipe_widgets/recipe_time_widget.dart';

class RecipePage extends StatefulWidget {
  static const route = "/home/recipe";

  RecipePage({Key? key}) : super(key: key);

  @override
  _RecipePageState createState() => _RecipePageState();
}

class _RecipePageState extends State<RecipePage> {

  bool isEditMode = false;

  // Modal Rout args not loaded yet
  bool shouldInit = true;

  late Recipe recipe;
  late bool isNewRecipe;
  
  late String _currentBookId;

  late Book currentBook;

  AccessLevel userAccess = AccessLevel.read;

  String updateRecipes = "";

  @override
  void initState() {
    super.initState();

    _currentBookId = DatabaseMgr().localMgr.loadCurrentBook()!;
    currentBook = DatabaseMgr().localMgr.getBook(_currentBookId)!;
    userAccess = currentBook.access[DatabaseMgr().localMgr.getUserId()] ?? AccessLevel.read;

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // declare functions
    void updateAfterRename(value) {
      if (value != null) {
        // Update recipe name
        DatabaseMgr().localMgr.updateRecipe(recipe.id, RecipeUpdate(id: recipe.id, name: value));

        // make refresh recipes
        updateRecipes = "reloadRecipes";

        // reload local recipe
        Recipe? tmpRecipe = DatabaseMgr().localMgr.getRecipe(recipe.id);
        if (tmpRecipe != null) {
          setState(() {
            recipe = tmpRecipe;
          });
        }
      }
    }

    // load params
    if (shouldInit) {
      if (ModalRoute.of(context)?.settings.arguments != null) {
        final routeArgs = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
        if (routeArgs['recipe'] != null) {
          recipe = routeArgs['recipe']!;
          isNewRecipe = routeArgs['isNewRecipe'] ?? false;
        }
        else {
          Navigator.of(context).pushNamed(PageNotFound.route);
        }
      }
      else {
        Navigator.of(context).pushNamed(PageNotFound.route);
      }

      shouldInit = false;

      // trigger Edit recipe name
      WidgetsBinding.instance.addPostFrameCallback((_){
        if (isNewRecipe) {
          Navigator.pushNamed(context, "${RecipePage.route}/${recipe.id}/edition/rename", arguments: {
            "currentName": recipe.name
          }).then((value) => updateAfterRename(value));
        }
      });
    }

    // get is favorite recipe
    bool isFav = DatabaseMgr().localMgr.getUser()!.favoriteRecipes.contains(recipe.id);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic a) {
        if (didPop) {
          return;
        }
        Navigator.of(context).pop(updateRecipes);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(recipe.name),
          actions: [
            isEditMode ?
              Container(
                margin: const EdgeInsets.symmetric(vertical: 4),
                child: IconButton(
                  icon: const FaIcon(FontAwesomeIcons.penToSquare),
                  onPressed: () {
                    Navigator.pushNamed(context, "${RecipePage.route}/${recipe.id}/edition/rename", arguments: {
                      "currentName": recipe.name
                    }).then((value) => updateAfterRename(value));
                  },
                ),
              ) :
            PopupMenuButton(
                icon: const Icon(Icons.more_vert),
                onSelected: (item) async {
                  switch (item) {
                    case "copy_into":
                      return showBookPickerDialog(
                          context: context,
                          books: DatabaseMgr().localMgr.getUserBooks(getWritableOnly: true)
                      ).then((bookId) async {
                        if (bookId != null) {
                          print("add ${recipe.name} to $bookId");
                          DatabaseMgr().localMgr.duplicateRecipe(recipe, bookId);
                          if (mounted) Navigator.pop(context, "reloadBooks");
                        }
                      });
                    case "remove":
                      return showAlertDialog(
                          context: context,
                          title: S.of(context).popup_delete_title,
                          description: userAccess.index <= AccessLevel.write.index ?
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(S.of(context).popup_delete_ownership_warning, textAlign: TextAlign.center),
                                Text(S.of(context).popup_delete_description_as_collaborator, textAlign: TextAlign.center),
                                Text(recipe.name, style: const TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                                Text(S.of(context).popup_delete_description_user_warning, textAlign: TextAlign.center)
                              ],
                            )
                                :
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(S.of(context).popup_delete_description_as_owner, textAlign: TextAlign.center),
                                Text(recipe.name, style: const TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                                Text(S.of(context).popup_delete_description_user_warning, textAlign: TextAlign.center)
                              ],
                            )
                      ).then((value) {
                        if (value != null && value) {
                          DatabaseMgr().localMgr.deleteRecipe(recipe.id);
                          if (mounted) Navigator.pop(context, "reloadRecipes");
                        }
                      });
                    default:
                      throw UnimplementedError();
                  }
                },
                itemBuilder: (context) => makeRecipePopupMenu(context, userAccess)
            )
          ],
        ),
        floatingActionButton: userAccess.index > AccessLevel.read.index ?
          FloatingActionButton(
            child: Icon(isEditMode ? Icons.check : Icons.edit),
            onPressed: ()  {
              setState(() {
                isEditMode = !isEditMode;
              });
            },
          ) : null,
        body: SingleChildScrollView(
            child: Column(
              children: [
                Stack(
                  children: [
                    WidgetSelectionOverlay(
                      widget: MyImageSlideshow(
                          recipeId: recipe.id,
                      ),
                      editModeController: isEditMode,
                      opacity: ThemeMgr.isDarkTheme(context) ? 0.9 : 0.6,
                      borderRadius: 0,
                      margin: 0,
                      onTap: () {
                        Navigator.pushNamed(context, "${RecipePage.route}/${recipe.id}/edition/images", arguments: {
                          "recipe": recipe
                        }).then((value) async {
                          // reload local recipe
                          Recipe? _tmp = DatabaseMgr().localMgr.getRecipe(recipe.id);
                          if (_tmp != null) {
                            setState(() {
                              recipe = _tmp;
                            });
                          }
                        });
                      }
                    ),
                    Visibility(
                      visible: !isEditMode,
                      child: Positioned(
                          top: 4,
                          right: 4,
                          child: IconButton(
                            onPressed: () async {
                              //set favorite in database
                              DatabaseMgr().localMgr.toggleFavorite(recipe.id);
                              AppUser? newAppUser = DatabaseMgr().localMgr.getUser();

                              if (newAppUser != null && newAppUser.favoriteRecipes.contains(recipe.id)) {
                                setState(() {
                                  isFav = true;
                                });
                              } else {
                                setState(() {
                                  isFav = false;
                                });
                              }

                              // make refresh recipes
                              updateRecipes = "reloadRecipes";
                            },
                            icon: FaIcon(FontAwesomeIcons.solidStar, size: 21, color: isFav ? Colors.amber : ThemeMgr.getTheme(context)!.iconTheme.color!.withOpacity(0.5)),
                          )
                      ),
                    )
                  ],
                ),
                WidgetSelectionOverlay(
                    widget: RecipeTimeWidget(
                        preparationTime: recipe.preparationTime,
                        waitingTime: recipe.waitingTime,
                        cookingTime: recipe.cookingTime
                    ),
                    editModeController: isEditMode,
                    opacity: ThemeMgr.isDarkTheme(context) ? 0.9 : 0.6,
                    onTap: () {
                      Navigator.pushNamed(context, "${RecipePage.route}/${recipe.id}/edition/time", arguments: {
                        "id": recipe.id,
                        "preparation": recipe.preparationTime,
                        "waiting": recipe.waitingTime,
                        "cooking": recipe.cookingTime
                      }).then((value) async {
                        if (value != null && value == 'update') {
                          // make refresh recipes
                          updateRecipes = "reloadRecipes";

                          // reload local recipe
                          Recipe? tmpRecipe = DatabaseMgr().localMgr.getRecipe(recipe.id);
                          if (tmpRecipe != null) {
                            setState(() {
                              recipe = tmpRecipe;
                            });
                          }
                        }
                      });
                    }
                ),
                WidgetSelectionOverlay(
                    widget: RecipeTagsWidget(key: UniqueKey(), tags: recipe.tags),
                    editModeController: isEditMode,
                    opacity: ThemeMgr.isDarkTheme(context) ? 0.9 : 0.6,
                    onTap: () {
                      Navigator.pushNamed(context, "${RecipePage.route}/${recipe.id}/edition/tags", arguments: {
                        "currentTags": recipe.tags,
                        "id": recipe.id
                      }).then((value) async {
                        if (value != null && value == 'update') {
                          // make refresh recipes
                          updateRecipes = "reloadRecipes";

                          // reload local recipe
                          Recipe? tmpRecipe = DatabaseMgr().localMgr.getRecipe(recipe.id);
                          if (tmpRecipe != null) {
                            setState(() {
                              recipe = tmpRecipe;
                            });
                          }
                        }
                      });
                    },
                ),
                WidgetSelectionOverlay(
                    widget: RecipeIngredientsWidget(
                      key: ValueKey('recipe_ingredients_${recipe.id}'),
                      ingredients: recipe.recipeIngredients,
                      defaultQuantity: recipe.quantity,
                      quantityType: recipe.quantityType,
                    ),
                    editModeController: isEditMode,
                    opacity: ThemeMgr.isDarkTheme(context) ? 0.9 : 0.6,
                    onTap: () {
                      Navigator.pushNamed(context, "${RecipePage.route}/${recipe.id}/edition/ingredients", arguments: {
                        "id": recipe.id,
                        "ingredients": recipe.recipeIngredients,
                        "quantity": recipe.quantity,
                        "quantityType": recipe.quantityType
                      }).then((value) async {
                        if (value != null && value == 'update') {
                          // make refresh recipes
                          updateRecipes = "reloadRecipes";

                          // reload local recipe
                          Recipe? tmpRecipe = DatabaseMgr().localMgr.getRecipe(recipe.id);
                          if (tmpRecipe != null) {
                            setState(() {
                              recipe = tmpRecipe;
                            });
                          }
                        }
                      });
                    },
                ),
                WidgetSelectionOverlay(
                  widget: RecipeStepsWidget(steps: recipe.steps),
                  editModeController: isEditMode,
                  opacity: ThemeMgr.isDarkTheme(context) ? 0.9 : 0.6,
                  onTap: () {
                    Navigator.pushNamed(context, "${RecipePage.route}/${recipe.id}/edition/steps", arguments: {
                      "recipeId": recipe.id,
                      "steps": recipe.steps
                    }).then((value) async {
                      if (value != null && value == 'update') {
                        // make refresh recipes
                        updateRecipes = "reloadRecipes";

                        // reload local recipe
                        Recipe? tmpRecipe = DatabaseMgr().localMgr.getRecipe(recipe.id);
                          if (tmpRecipe != null) {
                            setState(() {
                              recipe = tmpRecipe;
                            });
                          }
                      }
                    });
                  },
                ),
                Transform(
                  transform: Matrix4.translationValues(0, -12, 0),
                  child: RecipeVariantsWidget(
                    recipeId: recipe.id,
                    variants: recipe.variants,
                    userAccess: userAccess,
                    onUpdate: () async {
                      // make refresh recipes
                      updateRecipes = "reloadRecipes";

                      // reload local recipe
                      Recipe? tmpRecipe = DatabaseMgr().localMgr.getRecipe(recipe.id);
                      if (tmpRecipe != null) {
                        setState(() {
                          recipe = tmpRecipe;
                        });
                      }
                    },
                  ),
                ),


                const SizedBox(height: 96)
              ],
            )
        )
      )
    );
  }
}

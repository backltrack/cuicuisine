import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:reorderables/reorderables.dart';

import '../../models/data_model.dart';
import '../../models/update_model.dart';
import '../../database/database_mgr.dart';
import '../../themes/theme_mgr.dart';
import '../../generated/l10n.dart';

import '../../widgets/recipe_widgets/image_slideshow.dart';
import '../../widgets/recipe_widgets/picture_list_tile_widget.dart';
import '../../widgets/core_widgets/alert_dialog.dart';

class RecipeImagesEditionPage extends StatefulWidget {
  const RecipeImagesEditionPage({super.key});

  @override
  State<RecipeImagesEditionPage> createState() => _RecipeImagesEditionPageState();
}

class _RecipeImagesEditionPageState extends State<RecipeImagesEditionPage> {

  // Create Image picker
  final ImagePicker _picker = ImagePicker();

  bool isInit = false;
  late Recipe _recipe;

  // Staged (uncommitted) picture list shown to the user. Newly picked images
  // are written to local storage right away so they can be previewed through
  // the same recipeId/imageId lookup as already-saved pictures, but they are
  // only queued/synced — and removals only applied — once "Update" commits.
  late List<String> _pictures;
  final Set<String> _pendingNewImageIds = {};
  final Set<String> _pendingRemovedImageIds = {};

  int maxPictures = 5;

  // image_picker has no Linux camera backend (it throws StateError without a
  // platform cameraDelegate, which Linux doesn't ship) — hide the option
  // there rather than letting it crash.
  bool get _supportsCamera => !kIsWeb && !Platform.isLinux;

  Future<void> _discardPending() async {
    for (String imageId in _pendingNewImageIds) {
      await DatabaseMgr().localMgr.discardStagedImage(_recipe.id, imageId);
    }
  }

  Future<void> _commit() async {
    for (String imageId in _pendingNewImageIds) {
      await DatabaseMgr().localMgr.commitStagedImage(_recipe.id, imageId);
    }
    for (String imageId in _pendingRemovedImageIds) {
      await DatabaseMgr().localMgr.removeRecipeImage(_recipe.id, imageId);
    }
    await DatabaseMgr().localMgr.updateRecipe(
      _recipe.id,
      RecipeUpdate(id: _recipe.id, pictures: _pictures),
    );
    _pendingNewImageIds.clear();
    _pendingRemovedImageIds.clear();
  }

  @override
  Widget build(BuildContext context) {

    // load params
    final routeArgs = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
    final Recipe recipe = routeArgs['recipe']!;

    // Init
    if (!isInit) {
      _recipe = recipe;
      _pictures = [..._recipe.pictures];

      isInit = true;
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        if (didPop) {
          return;
        }

        bool? leave = await showAlertDialog(
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
        );
        if (leave ?? false) {
          await _discardPending();
          if (context.mounted) Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(S.of(context).images_edition_title),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () async {
            await _commit();
            if (context.mounted) Navigator.pop(context);
          },
          label: Text(S.of(context).recipe_edition_update)
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        body: Column(
          children: [
            MyImageSlideshow(
              recipeId: recipe.id,
              pictureIds: _pictures,
            ),
            Container(
              margin: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("${_pictures.length}/$maxPictures", style: ThemeMgr.getTheme(context)!.textTheme.displayMedium),
                  Row(
                    children: [
                      FloatingActionButton(
                        backgroundColor: _pictures.length >= maxPictures ? Colors.grey : ThemeMgr.getTheme(context)!.primaryColorDark,
                        onPressed: _pictures.length >= maxPictures ? null : () async {
                          // Pick images from gallery
                          List<XFile> images = await _picker.pickMultiImage(maxHeight: 720);
                          // check images quantity
                          if (_pictures.length + images.length > maxPictures) {
                            images = images.sublist(0, maxPictures - _pictures.length);
                          }
                          for (XFile image in images) {
                            String? newImageId = await DatabaseMgr().localMgr.stageRecipeImage(image, recipe.id);
                            if (newImageId != null) {
                              setState(() {
                                _pictures.add(newImageId);
                                _pendingNewImageIds.add(newImageId);
                              });
                            }
                          }
                        },
                        heroTag: "btnGallery",
                        child: const FaIcon(FontAwesomeIcons.image),
                      ),
                      if (_supportsCamera) ...[
                        const SizedBox(width: 12),
                        FloatingActionButton(
                          backgroundColor: _pictures.length >= maxPictures ? Colors.grey : ThemeMgr.getTheme(context)!.primaryColorDark,
                          onPressed: _pictures.length >= maxPictures ? null : () async {
                            // take new picture
                            final XFile? photo = await _picker.pickImage(source: ImageSource.camera, maxHeight: 720);
                            if (photo != null) {
                              String? newImageId = await DatabaseMgr().localMgr.stageRecipeImage(photo, recipe.id);
                              if (newImageId != null) {
                                setState(() {
                                  _pictures.add(newImageId);
                                  _pendingNewImageIds.add(newImageId);
                                });
                              }
                            }
                          },
                          heroTag: "btnPhoto",
                          child: const FaIcon(FontAwesomeIcons.camera),
                        ),
                      ],
                    ],
                  )
                ],
              ),
            ),
            Expanded(
              child: ReorderableColumn(
                children: List<Widget>.generate(_pictures.length, (index) {
                  return PictureListTile(
                    key: UniqueKey(),
                    recipeId: recipe.id,
                    imageId: _pictures[index],
                    onRemove: () async {
                      await showAlertDialog(
                        context: context,
                        title: S.of(context).popup_delete_title,
                        description: Text(S.of(context).popup_remove_image_description)
                      ).then((value) async {
                        if (value != null && value) {
                          final String removedId = _pictures[index];
                          final bool wasPending = _pendingNewImageIds.remove(removedId);
                          setState(() {
                            _pictures.remove(removedId);
                          });
                          if (wasPending) {
                            // staged-new image removed before commit: drop its orphan
                            // file right away, nothing was ever queued/synced for it
                            await DatabaseMgr().localMgr.discardStagedImage(recipe.id, removedId);
                          } else {
                            _pendingRemovedImageIds.add(removedId);
                          }
                        }
                      });
                    },
                  );
                }),
                onReorder: (int oldIndex, int newIndex) {
                  setState(() {
                    String movedPicture = _pictures.removeAt(oldIndex);
                    _pictures.insert(newIndex, movedPicture);
                  });
                }
              )
            )
          ],
        ),
      ),
    );
  }
}

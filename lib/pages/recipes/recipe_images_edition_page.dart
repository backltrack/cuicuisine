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
  const RecipeImagesEditionPage({Key? key}) : super(key: key);

  @override
  State<RecipeImagesEditionPage> createState() => _RecipeImagesEditionPageState();
}

class _RecipeImagesEditionPageState extends State<RecipeImagesEditionPage> {

  // Create Image picker
  final ImagePicker _picker = ImagePicker();

  bool isInit = false;
  late Recipe _recipe;

  int maxPictures = 5;

  @override
  Widget build(BuildContext context) {

    // load params
    final routeArgs = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
    final Recipe recipe = routeArgs['recipe']!;

    // Init
    if (!isInit) {
      _recipe = recipe;

      isInit = true;
    }

    List<String> pictures = _recipe.pictures;

    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).images_edition_title),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pop(context);
        },
        label: Text(S.of(context).recipe_edition_update)
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: Column(
        children: [
          MyImageSlideshow(
            recipeId: recipe.id,
          ),
          Container(
            margin: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("${_recipe.pictures.length}/$maxPictures", style: ThemeMgr.getTheme(context)!.textTheme.displayMedium),
                Row(
                  children: [
                    FloatingActionButton(
                      backgroundColor: _recipe.pictures.length >= maxPictures ? Colors.grey : ThemeMgr.getTheme(context)!.primaryColorDark,
                      onPressed: _recipe.pictures.length >= maxPictures ? null : () async {
                        // Pick images from gallery
                        List<XFile> images = await _picker.pickMultiImage(maxHeight: 720);
                        // add pictures
                        // check images quantity
                        if (_recipe.pictures.length + images.length > maxPictures) {
                          images = images.sublist(0, maxPictures - _recipe.pictures.length);
                        }
                        await DatabaseMgr().localMgr.putPicturesToStorage(images, recipe.id);
                        Recipe? tmp = DatabaseMgr().localMgr.getRecipe(recipe.id);
                        if (tmp != null) {
                          setState(() {
                            _recipe = tmp;
                          });
                        }
                      },
                      heroTag: "btnGallery",
                      child: const FaIcon(FontAwesomeIcons.image),
                    ),
                    const SizedBox(width: 12),
                    FloatingActionButton(
                      backgroundColor: _recipe.pictures.length >= maxPictures ? Colors.grey : ThemeMgr.getTheme(context)!.primaryColorDark,
                      onPressed: _recipe.pictures.length >= maxPictures ? null : () async {
                        // take new picture
                        final XFile? photo = await _picker.pickImage(source: ImageSource.camera, maxHeight: 720);
                        if (photo != null) {
                          await DatabaseMgr().localMgr.putPicturesToStorage([photo], recipe.id);
                        }
                      },
                      heroTag: "btnPhoto",
                      child: const FaIcon(FontAwesomeIcons.camera),
                    ),
                  ],
                )
              ],
            ),
          ),
          Expanded(
            child: ReorderableColumn(
              children: List<Widget>.generate(pictures.length, (index) {
                return PictureListTile(
                  key: UniqueKey(),
                  recipeId: recipe.id,
                  imageId: pictures[index],
                  onRemove: () async {
                    await showAlertDialog(
                      context: context,
                      title: S.of(context).popup_delete_title,
                      description: Text(S.of(context).popup_remove_image_description)
                    ).then((value) async {
                      if (value != null && value) {
                        await DatabaseMgr().localMgr.removePictureFromStorage(_recipe.id, pictures[index]);

                        Recipe? tmp = DatabaseMgr().localMgr.getRecipe(recipe.id);
                        if (tmp != null) {
                          setState(() {
                            _recipe = tmp;
                          });
                        }
                      }
                    });
                  },
                );
              }),
              onReorder: (int oldIndex, int newIndex) async {
                // copy pictures
                List<String> pictures = [];
                pictures.addAll(_recipe.pictures);

                // move picture location
                String movedPicture = pictures[oldIndex];
                pictures.removeAt(oldIndex);
                pictures.insert(newIndex, movedPicture);

                // update 
                DatabaseMgr().localMgr.updateRecipe(
                  recipe.id,
                  RecipeUpdate(
                    id: recipe.id,
                    pictures: pictures
                  )
                );

                // reload recipe
                Recipe? tmp = DatabaseMgr().localMgr.getRecipe(recipe.id);
                if (tmp != null) {
                  setState(() {
                    _recipe = tmp;
                  });
                }
              }
            )
          )
        ],
      ),
    );
  }
}

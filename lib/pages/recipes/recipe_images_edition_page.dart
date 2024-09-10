import 'dart:io';

import 'package:cuicuisine/models/update_model.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:reorderables/reorderables.dart';

import '../../database/database_mgr.dart';
import '../../themes/theme_mgr.dart';
import '../../utilities/string_functions.dart';

import '../../widgets/recipe_widgets/image_slideshow.dart';
import '../../widgets/recipe_widgets/picture_list_tile_widget.dart';
import '../../generated/l10n.dart';
import '../../models/data_model.dart';
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
                        DatabaseMgr().localMgr.putPicturesToStorage(images, recipe.id);
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
                          DatabaseMgr().localMgr.putPicturesToStorage([photo], recipe.id);
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
          // Expanded(
          //   child: FutureBuilder(
          //     future: pictures,
          //     builder: (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
          //       if (!snapshot.hasData) {
          //         return const Center(
          //           child: CircularProgressIndicator(),
          //         );
          //       } else {
          //         return ReorderableColumn(
          //           children: List<Widget>.generate(snapshot.data!.length, (index) {
          //             return PictureListTile(
          //               key: UniqueKey(),
          //               picture: snapshot.data![index],
          //               onRemove: () async {
          //                 await showAlertDialog(
          //                   context: context,
          //                   title: S.of(context).popup_delete_title,
          //                   description: Text(S.of(context).popup_remove_image_description)
          //                 ).then((value) async {
          //                   if (value != null && value) {
          //                     removePicture(_recipe, index).then((_) async {
          //                       await updateRecipe(
          //                           recipeId: recipe.id,
          //                           data: {"pictures": FieldValue.arrayRemove([_recipe.pictures[index]])}
          //                       );

          //                       Recipe? tmp = await getRecipe(recipe.id);
          //                       if (tmp != null) {
          //                         setState(() {
          //                           _recipe = tmp;
          //                         });
          //                       }
          //                     });
          //                   }
          //                 });
          //               },
          //             );
          //           }),
          //           onReorder: (int oldIndex, int newIndex) async {
          //             print(oldIndex);
          //             print(newIndex);
          //             // copy pictures
          //             List<String> pictures = [];
          //             pictures.addAll(_recipe.pictures);

          //             // move picture location
          //             String movedPicture = pictures[oldIndex];
          //             pictures.removeAt(oldIndex);
          //             pictures.insert(newIndex, movedPicture);

          //             // update firebase
          //             await updateRecipe(
          //                 recipeId: recipe.id,
          //                 data: {"pictures": pictures}
          //             );

          //             // reload recipe
          //             Recipe? tmp = await getRecipe(recipe.id);
          //             if (tmp != null) {
          //               setState(() {
          //                 _recipe = tmp;
          //               });
          //             }
          //           }
          //         );
          //       }
          //     },
          //   )
          // )
        ],
      ),
    );
  }
}

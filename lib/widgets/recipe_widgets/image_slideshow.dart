import 'package:cuicuisine/database/database_mgr.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_slideshow/flutter_image_slideshow.dart';

class MyImageSlideshow extends StatefulWidget {
  const MyImageSlideshow({super.key, required this.recipeId, this.onTap, this.pictureIds});

  final String recipeId;
  final Function(Image)? onTap;
  // When provided, overrides which picture ids to display (in this order)
  // instead of the recipe's persisted Recipe.pictures — lets a caller (e.g.
  // the images edition page) preview staged/uncommitted changes that haven't
  // been saved yet.
  final List<String>? pictureIds;

  @override
  State<MyImageSlideshow> createState() => _MyImageSlideshowState();
}

class _MyImageSlideshowState extends State<MyImageSlideshow> {
  Image? _currentImage;

  Future<List<Image>> _loadImages() async {
    if (widget.pictureIds != null) {
      List<Image> images = [];
      for (String imageId in widget.pictureIds!) {
        images.add(await DatabaseMgr().localMgr.getRecipeImage(widget.recipeId, imageId));
      }
      return images;
    }
    return DatabaseMgr().localMgr.getRecipeImages(widget.recipeId);
  }

  @override
  Widget build(BuildContext context) {

    _loadImages().then((images) {
      if (images.isNotEmpty) {
        _currentImage = images[0];
      }
    });

    return InkWell(
      onTap: () {
        if (_currentImage != null) {
          widget.onTap?.call(_currentImage!);
        }
      },
      child: FutureBuilder(
        future: _loadImages(),
        builder: (BuildContext context, AsyncSnapshot<List<Image>> snapshot) {
          return ImageSlideshow(
            height: 300,
            onPageChanged: (value) {
              _currentImage = snapshot.data != null && snapshot.data!.isNotEmpty ? snapshot.data![value] : null;
            },
            children: [
            if (!snapshot.hasData)
              const Center(child:CircularProgressIndicator())
            else if (snapshot.hasData && snapshot.data!.isEmpty)
              Image.asset("assets/images/default_image.png")
            else
              ...List<Image>.generate(snapshot.data!.length, (index) {
                return snapshot.data![index];
              })
            ]
          );
        }
      )
    );
  }
}

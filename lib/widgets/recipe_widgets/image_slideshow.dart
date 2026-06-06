import 'package:cuicuisine/database/database_mgr.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_slideshow/flutter_image_slideshow.dart';

class MyImageSlideshow extends StatefulWidget {
  const MyImageSlideshow({super.key, required this.recipeId, this.onTap});

  final String recipeId;
  final Function(Image)? onTap;

  @override
  State<MyImageSlideshow> createState() => _MyImageSlideshowState();
}

class _MyImageSlideshowState extends State<MyImageSlideshow> {
  Image? _currentImage;

  @override
  Widget build(BuildContext context) {

    DatabaseMgr().localMgr.getRecipeImages(widget.recipeId).then((images) {
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
        future: DatabaseMgr().localMgr.getRecipeImages(widget.recipeId),
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

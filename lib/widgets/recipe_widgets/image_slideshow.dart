import 'package:cuicuisine/database/database_mgr.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_slideshow/flutter_image_slideshow.dart';

class MyImageSlideshow extends StatefulWidget {
  const MyImageSlideshow({super.key, required this.recipeId});

  final String recipeId;

  @override
  State<MyImageSlideshow> createState() => _MyImageSlideshowState();
}

class _MyImageSlideshowState extends State<MyImageSlideshow> {

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: DatabaseMgr().localMgr.getRecipeImages(widget.recipeId),
      builder: (BuildContext context, AsyncSnapshot<List<Image>> snapshot) {
        return ImageSlideshow(
          width: double.infinity,
          height: MediaQuery.of(context).size.width * 9 / 16,
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
      },
    );
  }
}

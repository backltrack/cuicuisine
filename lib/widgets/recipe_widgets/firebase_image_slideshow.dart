import 'package:flutter/material.dart';
import 'package:flutter_image_slideshow/flutter_image_slideshow.dart';

class FireBaseImageSlideshow extends StatefulWidget {
  FireBaseImageSlideshow({Key? key, required this.pictures}) : super(key: key);

  final Future<List<String>> pictures;

  @override
  State<FireBaseImageSlideshow> createState() => _FireBaseImageSlideshowState();
}

class _FireBaseImageSlideshowState extends State<FireBaseImageSlideshow> {

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: widget.pictures,
      builder: (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
        return ImageSlideshow(
          width: double.infinity,
          height: MediaQuery.of(context).size.width * 9 / 16,
          children: [
            if (!snapshot.hasData)
              Center(child:CircularProgressIndicator())
            else if (snapshot.hasData && snapshot.data!.isEmpty)
              Image.asset("assets/images/default_image.png")
            else
              ...List<Image>.generate(snapshot.data!.length, (index) {
                return Image.network(snapshot.data![index], fit: BoxFit.cover);
              })
          ]
        );
      },
    );
  }
}

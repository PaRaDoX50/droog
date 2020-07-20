import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class FullScreenImage extends StatelessWidget {
  static final String route = "/full_screen_image";
  @override
  Widget build(BuildContext context) {
    String imageUrl = ModalRoute.of(context).settings.arguments as String;

    return Scaffold(

      backgroundColor: Colors.transparent,
      appBar: AppBar(
        brightness: Brightness.dark,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Center(
        child:CachedNetworkImage(
            imageBuilder: (context, imageProvider) => PhotoView(minScale: PhotoViewComputedScale.contained ,maxScale: PhotoViewComputedScale.covered,
              heroAttributes:PhotoViewHeroAttributes(tag: imageUrl),
              imageProvider: imageProvider,
            ),
            imageUrl: imageUrl,
            width: double.infinity,
          ),

      ),
    );
  }
}

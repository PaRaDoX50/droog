import 'package:cached_network_image/cached_network_image.dart';
import 'package:droog/screens/full_screen_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:url_launcher/url_launcher.dart';

class ImageMessageTile extends StatelessWidget {
  final String imageUrl;
  String text = "";
  final Alignment alignment;

  ImageMessageTile({this.text, this.imageUrl, this.alignment});

  getWidgets(double width, BuildContext ctx) {
    if (alignment == Alignment.centerRight) {
      return [
        Container(
          padding: EdgeInsets.all(8 / 2),
          decoration: BoxDecoration(
            color: Color(0xff4481bc),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: <Widget>[
              GestureDetector(
                onTap: () => Navigator.pushNamed(ctx, FullScreenImage.route,
                    arguments: imageUrl),
                child: Hero(
                  tag: imageUrl,
                  child: CachedNetworkImage(
                    placeholder: (x, y) {
                      return Container(
                          child: Center(
                              child: CircularProgressIndicator(
                                backgroundColor: Colors.white,
                              )));
                    },
                    imageUrl: imageUrl,
                  ),
                ),
              ),
              text != ""
                  ? SizedBox(
                height: 2,
              )
                  : Container(),
              text != ""
                  ? SelectableLinkify(
                text: text,
                style: TextStyle(color: Colors.white),
                onOpen: (link) async {
                  print("opening");
                  if (await canLaunch(link.url)) {
                    print("opening");
                    await launch(link.url);
                  } else {
                    print(":cant launch url");
                  }
                },
                linkStyle: TextStyle(color:Color(0xffe8f5fd)),
              )
                  : Container()
            ],
          ),
          constraints: BoxConstraints(maxWidth: width / 1.5),
        ),
        SizedBox(
          width: width / 30,
        ),
      ];
    } else {
      return [
        Container(
          padding: EdgeInsets.all(8 / 2),
          decoration: BoxDecoration(
            color: Color(0xffe8f5fd),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: <Widget>[
              GestureDetector(
                onTap: () => Navigator.pushNamed(ctx, FullScreenImage.route,
                    arguments: imageUrl),
                child: Hero(
                  tag: imageUrl,
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    placeholder: (x, y) {
                      return Container(
                          child: Center(
                              child: CircularProgressIndicator(
                                backgroundColor: Colors.white,
                              )));
                    },
                  ),
                ),
              ),
              text != ""
                  ? SizedBox(
                height: 2,
              )
                  : Container(),
              text != ""
                  ? SelectableLinkify(
                text: text,

                onOpen: (link) async {
                  print("opening");
                  if (await canLaunch(link.url)) {
                    print("opening");
                    await launch(link.url);
                  } else {
                    print(":cant launch url");
                  }
                },
                linkStyle: TextStyle(color: Colors.blue),
              )
                  : Container()
            ],
          ),
          constraints: BoxConstraints(maxWidth: width / 1.5),
        ),
        SizedBox(
          width: width / 30,
        ),
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Padding(
      padding: EdgeInsets.all(width / 60),
      child: Row(
        mainAxisAlignment: alignment == Alignment.centerRight
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: getWidgets(width, context),
      ),
    );
  }
}
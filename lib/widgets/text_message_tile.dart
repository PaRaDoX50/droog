import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:url_launcher/url_launcher.dart';

class TextMessageTile extends StatelessWidget {
  final String message;
  final Alignment alignment;

  TextMessageTile({this.message, this.alignment});

  getWidgets(double width) {
    if (alignment == Alignment.centerRight) {
      return [
        Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Color(0xff4481bc),
            borderRadius: BorderRadius.circular(10),
          ),
          child: SelectableLinkify(
            text: message,
            onOpen: (link) async {
              print("opening");
              if (await canLaunch(link.url)) {
                print("opening");
                await launch(link.url);
              } else {
                print(":cant launch url");
              }
            },
            style: TextStyle(color: Colors.white),
            linkStyle: TextStyle(color:Color(0xffe8f5fd)),
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
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Color(0xffe8f5fd),
            borderRadius: BorderRadius.circular(10),
          ),
          child: SelectableLinkify(
            text: message,
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
          ),
          constraints: BoxConstraints(maxWidth: width / 1.5),
        ),
        SizedBox(
          width: width / 30,
        ),
      ].reversed.toList();
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
        children: getWidgets(width),
      ),
    );
  }
}
import 'dart:io';

import 'package:droog/data/constants.dart';
import 'package:droog/models/enums.dart';
import 'package:droog/models/message.dart';
import 'package:droog/models/user.dart';
import 'package:droog/services/database_methods.dart';
import 'package:flutter/material.dart';

class ImageMessageScreen extends StatefulWidget {
  static final String route = "/image_message_screen";

  @override
  _ImageMessageScreenState createState() => _ImageMessageScreenState();
}

class _ImageMessageScreenState extends State<ImageMessageScreen> {
  File image;

  String targetUserName;

  bool _showLoading = false;

  DatabaseMethods _databaseMethods = DatabaseMethods();

  final TextEditingController messageController = TextEditingController();

  sendMessage() async {
    setState(() {
      _showLoading = true;
    });

    String imageUrl = await _databaseMethods.uploadPicture(
        file: image, address: "messagePictures");
    final message = {
      "messageType": MessageType.image.index,
      "imageUrl": imageUrl,
      "time": DateTime
          .now()
          .millisecondsSinceEpoch,
      "text": messageController.text,
      "byUid": Constants.uid,
      "byUserName": Constants.userName
    };
    await _databaseMethods.sendMessage(targetUserName: targetUserName, message:message);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final arguments = ModalRoute
        .of(context)
        .settings
        .arguments as Map<String, dynamic>;

    image = arguments["file"] as File;
    targetUserName = arguments["targetUserName"] as String;


    final messageTextField = Container(
        constraints:
        BoxConstraints(maxHeight: MediaQuery
            .of(context)
            .size
            .height / 5),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Expanded(
              child: TextField(
                maxLines: null,
                controller: messageController,
                style: TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  hintText: "Type your message",
                  hintStyle: TextStyle(color: Colors.white),
                  contentPadding: EdgeInsets.only(
                    left: 16,
                  ),
                  filled: true,
                  fillColor: Colors.grey[300],
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(style: BorderStyle.solid),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(style: BorderStyle.solid),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),
            SizedBox(
              width: 8,
            ),
            IconButton(
              icon: Icon(Icons.send),
              onPressed: sendMessage,
            )
          ],
        ));

    return Scaffold(
      body: Container(color: Colors.black,
        child: Stack(children: <Widget>[
          Center(child: AspectRatio(aspectRatio: 4 / 3,
            child: Image.file(image, width: double.infinity,),)),
          Align(alignment: Alignment.bottomCenter, child: messageTextField),

        ],),
      ),
    );
  }
}
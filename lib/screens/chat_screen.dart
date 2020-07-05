import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:droog/data/constants.dart';
import 'package:droog/models/enums.dart';
import 'package:droog/models/message.dart';
import 'package:droog/models/post.dart';
import 'package:droog/models/user.dart';
import 'package:droog/screens/image_message_screen.dart';
import 'package:droog/screens/search.dart';
import 'package:droog/screens/share_screen.dart';
import 'package:droog/services/database_methods.dart';
import 'package:droog/utils/image_picker.dart';
import 'package:droog/widgets/feed_tile.dart';
import 'package:droog/widgets/post_message_tile.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class ChatScreen extends StatefulWidget {
  static final String route = "/chat_screen";

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final DatabaseMethods _databaseMethods = DatabaseMethods();
  final TextEditingController messageController = TextEditingController();
  User user;

  sendMessage(String userName) async {
    print(userName + messageController.text);
    if (messageController.text.isNotEmpty) {
      Map<String, dynamic> message = {
        "messageType": MessageType.onlyText.index,
        "text": messageController.text,
        "byUid": Constants.uid,
        "byUserName": Constants.userName,
        "time": DateTime.now().millisecondsSinceEpoch,
      };
      await _databaseMethods.sendMessage(
          targetUserName: userName, message: message);
      messageController.clear();
    }
  }

  pickImage(ImageSource imageSource) async {
    PickImage _pickImage = PickImage();
    File imageFile = await _pickImage.takePicture(imageSource: imageSource);
    File croppedFile = await _pickImage.cropImage(
        image: imageFile,
        ratioX: 4,
        ratioY: 3,
        pictureFor: PictureFor.messagePicture);
    if(croppedFile != null) {
      Navigator.of(context).pushNamed(ImageMessageScreen.route,
          arguments: {"file": croppedFile, "targetUserName": user.userName});
    }
  }

  returnAppropriateTile(Message message) {
    print(message.text);
    if (message.messageType == MessageType.onlyText) {
      if (message.byUserName == Constants.userName) {
        return TextMessageTile(
          message: message.text,
          alignment: Alignment.centerRight,
        );
      }
      return TextMessageTile(
        message: message.text,
        alignment: Alignment.centerLeft,
      );
    } else if (message.messageType == MessageType.image) {
      if (message.byUserName == Constants.userName) {
        return ImageMessageTile(
          imageUrl: message.imageUrl,
          text: message.text,
          alignment: Alignment.centerRight,
        );
      }
      return ImageMessageTile(
        imageUrl: message.imageUrl,
        text: message.text,
        alignment: Alignment.centerLeft,
      );
    }
    else{
      if (message.byUserName == Constants.userName) {
        return PostMessageTile(

          postId: message.postId,
          alignment: Alignment.centerRight,
        );
      }
      return PostMessageTile(
        postId: message.postId,
        alignment: Alignment.centerLeft,
      );
    }
  }

  List<String> messages = ["hello boi"];
  markIsSeen({DocumentSnapshot documentSnapshot}) async {
   try {
     await documentSnapshot.reference.updateData({"isSeen":true});
     print("markedSeen");

   }  catch (e) {
     // TODO
     print(e.message);
   }
  }

  @override
  Widget build(BuildContext context) {
    user = ModalRoute.of(context).settings.arguments as User;
    final messageTextField = Container(
        constraints:
            BoxConstraints(maxHeight: MediaQuery.of(context).size.height / 5),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: TextField(
                maxLines: null,
                controller: messageController,
                style: TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  hintText: "Type your message",
                  hintStyle: TextStyle(color: Colors.grey),
                  contentPadding: EdgeInsets.only(
                    left: 16,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(style: BorderStyle.solid),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(style: BorderStyle.solid),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            SizedBox(
              width: 8,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: InkWell(
                child: Icon(Icons.camera_alt),
                onTap: () => pickImage(ImageSource.camera),
              ),
            ),
           Padding(
             padding: const EdgeInsets.all(8.0),
             child: InkWell(
                child: Icon(Icons.attachment),
                onTap: () => pickImage(ImageSource.gallery),
              ),
           ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: InkWell(
                child: Icon(Icons.send),
                onTap: () => sendMessage(user.userName),
              ),
            )
          ],
        ));
    int largestIndexOfTargetUserMessage = 0;
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: CustomAppBar(
        userFullName: "${user.firstName} ${user.lastName}",
        userProfilePictureUrl: user.profilePictureUrl,
      ),
      body: Stack(
        children: <Widget>[
          ClipRRect(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20)),
            child: Container(
              color: Colors.white,
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).padding.bottom + 70),
              child: StreamBuilder<List<Message>>(
                  stream: _databaseMethods.getAConversation(
                      targetUserName: user.userName,limitToOne: false),
                  builder: (context, snapshot) {
                    List<Message> data = [];

                    if (snapshot.hasData) {
                      if (snapshot.data.isNotEmpty) {
                        data = snapshot.data;
                        //                      data.sort((b, a) {
                        //                        return a["time"].compareTo(b["time"]);
                        //                      });
                        if(data.first.byUserName != Constants.userName){
                         markIsSeen(documentSnapshot: snapshot.data.first.documentSnapshot);
                        }
                      }
                    }



                    return ListView.builder(

                      reverse: true,
                      itemBuilder: (_, index) {

                        return returnAppropriateTile(data[index]);
                      },
                      itemCount: data.length,
                    );
                  }),
            ),
          ),
          Align(alignment: Alignment.bottomCenter, child: messageTextField),
        ],
      ),
    );
  }
}

class CustomAppBar extends PreferredSize {
  final String userFullName;
  final String userProfilePictureUrl;

  CustomAppBar({this.userProfilePictureUrl, this.userFullName});

  @override
  Size get preferredSize => Size.fromHeight(100);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            InkWell(
              onTap: () => Navigator.pop(context),
              child: Icon(
                Icons.arrow_back_ios,
                color: Colors.white,
              ),
            ),
            Container(
              color: Theme.of(context).primaryColor,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  CircleAvatar(
                    radius: 25,
                    child: ClipOval(
                      child: CachedNetworkImage(
                        imageUrl: userProfilePictureUrl,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  Text(
                    userFullName,
                    style: TextStyle(color: Colors.white),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
             Icon(
                Icons.more_vert,
                color: Colors.white,

            ),
          ],
        ),
      ),
    );
  }
}

//class MessageTileLeft extends StatelessWidget {
//  final String message;
//
//
//  MessageTileLeft({this.message, });
//
//  @override
//  Widget build(BuildContext context) {
//    double width = MediaQuery.of(context).size.width;
//    return Padding(
//      padding: EdgeInsets.all(width / 60),
//      child: Row(
//        mainAxisSize: MainAxisSize.min,
//        children: <Widget>[
//
//          SizedBox(
//            width: width / 30,
//          ),
//          Container(
//            padding: EdgeInsets.all(10),
//            decoration: BoxDecoration(
//              color: Colors.grey[300],
//              borderRadius: BorderRadius.circular(10),
//            ),
//            child: Text(
//              message,
//            ),
//            constraints: BoxConstraints(maxWidth: width / 1.5),
//          )
//        ],
//      ),
//    );
//  }
//}

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
            color:Color(0xff2f66af),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            message,
            style: TextStyle(color: Colors.white),
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
          child: Text(
            message
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
        mainAxisAlignment:alignment == Alignment.centerRight ? MainAxisAlignment.end : MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: getWidgets(width),
      ),
    );
  }
}

class ImageMessageTile extends StatelessWidget {
  final String imageUrl;
  String text = "";
  final Alignment alignment;

  ImageMessageTile({this.text, this.imageUrl, this.alignment});

  getWidgets(double width) {
    if (alignment == Alignment.centerRight) {
      return [
        Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Color(0xff2f66af),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: <Widget>[
              CachedNetworkImage(
                imageUrl: imageUrl,
              ),
              SizedBox(
                height: 2,
              ),
              Text(text,
                style: TextStyle(color: Colors.white),)
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
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Color(0xffe8f5fd),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: <Widget>[
              CachedNetworkImage(
                imageUrl: imageUrl,
              ),
              SizedBox(
                height: 2,
              ),
              Text(text)
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

        mainAxisAlignment:alignment == Alignment.centerRight ? MainAxisAlignment.end : MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: getWidgets(width),
      ),
    );
  }
}

class PostMessageTile extends StatelessWidget {
  final String postId;
  final Alignment alignment;
  final DatabaseMethods _databaseMethods = DatabaseMethods();

  PostMessageTile({this.postId, this.alignment});

  Future<Post> _getPost() {
    return _databaseMethods.getPostByPostId(postId: postId);
  }

  getWidgets(double width) {
    if (alignment == Alignment.centerRight) {
      return [
        Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Color(0xff2f66af),
            borderRadius: BorderRadius.circular(10),
          ),
          child: FutureBuilder<Post>(
              future: _getPost(),
              builder: (_, snapshot) {
                if (snapshot.hasData) {
                  return PostMessageWidget(post: snapshot.data,);
                }
                return Center(child: CircularProgressIndicator(),);
              }),
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
          child: FutureBuilder<Post>(
              future: _getPost(),
              builder: (_, snapshot) {
                if (snapshot.hasData) {
                  return PostMessageWidget(post: snapshot.data,);
                }
                return Center(child: CircularProgressIndicator(),);
              }),
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
        mainAxisAlignment: alignment == Alignment.centerRight ? MainAxisAlignment.end : MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: getWidgets(width),
      ),
    );
  }
}

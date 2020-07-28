import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:droog/data/constants.dart';
import 'package:droog/models/enums.dart';
import 'package:droog/models/message.dart';
import 'package:droog/models/post.dart';
import 'package:droog/models/user.dart';
import 'package:droog/screens/image_message_screen.dart';
import 'package:droog/services/database_methods.dart';
import 'package:droog/utils/image_picker.dart';
import 'package:droog/widgets/image_message_tile.dart';
import 'package:droog/widgets/post_message_tile.dart';
import 'package:droog/widgets/profile_picture_loading.dart';
import 'package:droog/widgets/text_message_tile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_picker/image_picker.dart';

class ChatScreen extends StatefulWidget {
  static final String route = "/chat_screen";

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final DatabaseMethods _databaseMethods = DatabaseMethods();
  final TextEditingController messageController = TextEditingController();
  User user;
  bool sendingMessage = false;

  sendMessage(String userName) async {
    if (!sendingMessage) {
      setState(() {
        sendingMessage = true;
      });
      print(userName + messageController.text);
      if (messageController.text.trim().isNotEmpty) {

        Map<String, dynamic> message = {
          "messageType": MessageType.onlyText.index,
          "text": messageController.text,
          "byUid": Constants.uid,
          "byUserName": Constants.userName,
          "time": DateTime.now().millisecondsSinceEpoch,
        };
        messageController.clear();
        await _databaseMethods.sendMessage(
            targetUserName: userName, message: message);

      }
      setState(() {
        sendingMessage =false;
      });
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
    if (croppedFile != null) {
      Navigator.of(context).pushNamed(ImageMessageScreen.route,
          arguments: {"file": croppedFile, "targetUserName": user.userName});
    }
  }

  returnAppropriateTile({Message message, bool isLastMessage}) {
    print(message.text);
    if (message.messageType == MessageType.onlyText) {
      if (message.byUserName == Constants.userName) {
        return TextMessageTile(
          message: message.text,
          alignment: Alignment.centerRight,
          isLastMessage: isLastMessage,
          documentSnapshot: isLastMessage ? message.documentSnapshot : null,
        );
      }
      return TextMessageTile(
        message: message.text,
        alignment: Alignment.centerLeft,
//        isLastMessage: isLastMessage,
//        documentSnapshot: isLastMessage ? message.documentSnapshot : null,
      );
    } else if (message.messageType == MessageType.image) {
      if (message.byUserName == Constants.userName) {
        return ImageMessageTile(
          imageUrl: message.imageUrl,
          text: message.text,
          alignment: Alignment.centerRight,
          isLastMessage: isLastMessage,
          documentSnapshot: isLastMessage ? message.documentSnapshot : null,
        );
      }
      return ImageMessageTile(
        imageUrl: message.imageUrl,
        text: message.text,
        alignment: Alignment.centerLeft,
      );
    } else {
      if (message.byUserName == Constants.userName) {
        return PostMessageTile(
          postId: message.postId,
          alignment: Alignment.centerRight,
          isLastMessage: isLastMessage,
          documentSnapshot: isLastMessage ? message.documentSnapshot : null,
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
      await documentSnapshot.reference.updateData({"isSeen": true});
      print("markedSeen");
    } catch (e) {
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
        padding: const EdgeInsets.only(top: 0,bottom: 8, left: 8,right: 8),
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
                  bottom: MediaQuery.of(context).padding.bottom + 60),
              child: StreamBuilder<List<Message>>(
                  stream: _databaseMethods.getAConversation(
                      targetUserName: user.userName, limitToOne: false),
                  builder: (context, snapshot) {
                    List<Message> data = [];

                    if (snapshot.hasData) {
                      if (snapshot.data.isNotEmpty) {
                        data = snapshot.data;
                        //                      data.sort((b, a) {
                        //                        return a["time"].compareTo(b["time"]);
                        //                      });
                        if (data.first.byUserName != Constants.userName) {
                          markIsSeen(
                              documentSnapshot:
                                  snapshot.data.first.documentSnapshot);
                        }
                      }
                    }

                    return ListView.builder(
                        addAutomaticKeepAlives: true,
                        reverse: true,
                        itemBuilder: (_, index) {

                          return returnAppropriateTile(message:data[index],isLastMessage: index == 0 ? true : false);
                        },
                        itemCount: data.length,
                      );
                  }),
            ),
          ),
          FutureBuilder(future:_databaseMethods.isDroog(targetUid: user.uid),builder: (_,snapshot){
            if(snapshot.hasData){
              return snapshot.data ? Align(alignment: Alignment.bottomCenter, child: messageTextField) : Align(alignment: Alignment.bottomCenter, child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text("Can't send message, both of you are not connected."),
              ));
            }
            else{
              return Container();
            }
          },)
          ,
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
  Size get preferredSize => Size.fromHeight(150);

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
                  Hero(
                    tag:userProfilePictureUrl,
                    child: CircleAvatar(
                      radius: 35,
                      child: ClipOval(
                        child: CachedNetworkImage(
                          imageUrl: userProfilePictureUrl,
                          placeholder: (x, y) {
                            return  ProfilePictureLoading();
                          },
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  FittedBox(
                    child: Text(
                      userFullName,
                      style: TextStyle(color: Colors.white),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 25,
            ),
          ],
        ),
      ),
    );
  }
}



class PostMessageTile extends StatefulWidget {
  final String postId;
  final Alignment alignment;
  final bool isLastMessage;
  final DocumentSnapshot documentSnapshot;

  PostMessageTile({this.postId, this.alignment,this.documentSnapshot,this.isLastMessage});

  @override
  _PostMessageTileState createState() => _PostMessageTileState();
}

class _PostMessageTileState extends State<PostMessageTile> with  AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin{
  final DatabaseMethods _databaseMethods = DatabaseMethods();
  AnimationController _controller;
  Animation<Offset> _offsetAnimation;
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this,duration: Duration(milliseconds: 300));
    _offsetAnimation = Tween<Offset>( begin:const Offset(2, 0.0) ,
      end: Offset.zero,).animate(CurvedAnimation(curve: Curves.linear,parent: _controller));


  }
  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  Future<Post> _getPost() {
    return _databaseMethods.getPostByPostId(postId: widget.postId);
  }

  getWidgets(double width) {
    if (widget.alignment == Alignment.centerRight) {
      return [
        Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Color(0xff4481bc),
            borderRadius: BorderRadius.circular(10),
          ),
          child: FutureBuilder<Post>(
              future: _getPost(),
              builder: (_, snapshot) {
                if (snapshot.hasData) {
                  return PostMessageWidget(
                    post: snapshot.data,
                  );
                }
                return Center(
                  child: CircularProgressIndicator(),
                );
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
                  return PostMessageWidget(
                    post: snapshot.data,
                  );
                }
                return Center(
                  child: CircularProgressIndicator(),
                );
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Row(
            mainAxisAlignment: widget.alignment == Alignment.centerRight
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: getWidgets(width),
          ),
          widget.alignment == Alignment.centerRight ?
          (widget.isLastMessage ? StreamBuilder<DocumentSnapshot>(stream: widget.documentSnapshot.reference.snapshots(),builder: (_,snapshot){
            if(snapshot.hasData){
              if(snapshot.data.data["isSeen"] ?? false){
                _controller.forward();
                return Padding(
                  padding: EdgeInsets.only(right: width/20),
                  child: SlideTransition(child:Text("Seen",style: TextStyle(color: Colors.blueGrey,fontSize: 10),),position: _offsetAnimation,),
                );
              }

              return Container();
            }
            return Container();
          },):Container())
              :
          Container()
        ],
      ),
    );
  }
}

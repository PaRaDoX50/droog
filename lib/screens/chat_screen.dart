import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:droog/data/constants.dart';
import 'package:droog/models/user.dart';
import 'package:droog/screens/search.dart';
import 'package:droog/services/database_methods.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class ChatScreen extends StatefulWidget {
  static final String route = "/chat_screen";

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final DatabaseMethods _databaseMethods = DatabaseMethods();
  final TextEditingController messageController = TextEditingController();

  sendMessage(String userName) async {
    print(userName + messageController.text);
    Map<String, dynamic> message = {
      "message": messageController.text,
      "by": Constants.userName,
      "time": DateTime.now().millisecondsSinceEpoch,
    };
    await _databaseMethods.sendMessage(userName, message);
  }

  List<String> messages = ["hello boi"];

  @override
  Widget build(BuildContext context) {
    final user = ModalRoute.of(context).settings.arguments as User;
    final messageTextField = Container(
        constraints:
            BoxConstraints(maxHeight: MediaQuery.of(context).size.height / 5),
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
              onPressed: () => sendMessage(user.userName),
            )
          ],
        ));

    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: CustomAppBar(
        userFullName: "${user.firstName} ${user.lastName}" ,
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
              child: StreamBuilder<QuerySnapshot>(
                  stream:
                      _databaseMethods.getAConversation(targetUserName: user.userName),
                  builder: (context, snapshot) {
                    List<DocumentSnapshot> data = [];

                    if (snapshot.hasData) {
                      data = snapshot.data.documents;
                      data.sort((b, a) {
                        return a["time"].compareTo(b["time"]);
                      });
                    }

                    return ListView.builder(
                      reverse: true,
                      itemBuilder: (_, index) {
                        if (data[index]["by"] == Constants.userName) {
                          return MessageTileRight(

                              message: data[index]["message"],
                              ctx: context);
                        }
                        return MessageTileLeft(
                          message: data[index]["message"],
                        );
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
                    child: ClipOval(
                      child: Image.network(userProfilePictureUrl,),
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
            InkWell(
              onTap: () => Navigator.pushNamed(context, SearchScreen.route),
              child: Icon(
                Icons.more_vert,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MessageTileLeft extends StatelessWidget {
  final String message;


  MessageTileLeft({this.message, });

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Padding(
      padding: EdgeInsets.all(width / 60),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[

          SizedBox(
            width: width / 30,
          ),
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              message,
            ),
            constraints: BoxConstraints(maxWidth: width / 1.5),
          )
        ],
      ),
    );
  }
}

class MessageTileRight extends StatelessWidget {
  final String message;

  final BuildContext ctx;

  MessageTileRight({this.message,  this.ctx});

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(ctx).size.width;
    return Padding(
      padding: EdgeInsets.all(width / 60),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              message,
            ),
            constraints: BoxConstraints(maxWidth: width / 1.5),
          ),
          SizedBox(
            width: width / 30,
          ),

        ],
      ),
    );
  }
}

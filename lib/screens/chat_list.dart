import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:droog/data/constants.dart';
import 'package:droog/models/enums.dart';
import 'package:droog/models/message.dart';
import 'package:droog/models/user.dart';
import 'package:droog/screens/chat_screen.dart';
import 'package:droog/screens/new_message_screen.dart';
import 'package:droog/services/database_methods.dart';
import 'package:droog/utils/theme_data.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class ChatList extends StatefulWidget {
  static final String route = "/chat_list";

  @override
  _ChatListState createState() => _ChatListState();
}

class _ChatListState extends State<ChatList> {
  List<Map<String, String>> tempData = [];
  Stream userChatsStream;
  final DatabaseMethods _databaseMethods = DatabaseMethods();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {


    return Scaffold(
      floatingActionButton: FloatingActionButton(backgroundColor:Colors.blueGrey,
        onPressed: () {
          Navigator.pushNamed(context, NewMessageScreen.route);
        },
        child: Icon(Icons.add,color: Colors.white,),
      ),
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: <Widget>[
          SliverToBoxAdapter(
            child: Container(),
          ),
          StreamBuilder<QuerySnapshot>(
              stream: _databaseMethods.getCurrentUserChats(
                  userName: Constants.userName),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  List<DocumentSnapshot> data = snapshot.data.documents;
                  if (snapshot.data.documents.length > 0) {
                    return SliverList(
                      delegate: SliverChildBuilderDelegate((_, index) {
                        final targetUserName =
                            data[index]["users"][1] == Constants.userName
                                ? data[index]["users"][0]
                                : data[index]["users"][1];
                    
                        return InkWell(
                          onTap: () async {
                            try {
                              User user =
                                  await _databaseMethods.getUserDetailsByUsername(
                                      targetUserName: targetUserName);
                              Navigator.pushNamed(context, ChatScreen.route,
                                  arguments: user);
                            } catch (e) {
                              print(e.toString());
                            }
                          },
                          child: ChatTile(
                            targetUserName: targetUserName,
                          ),
                        );
                      }, childCount: data.length),
                    );
                  }
                  else{
                   return SliverFillRemaining(child: Center(child: Column(
                     mainAxisSize: MainAxisSize.min,
                     children: <Widget>[
                       Image.asset("assets/images/no_conversation.png"),
                       SizedBox(height: 8,),
                       FittedBox(child: Text("No conversations!",style: TextStyle(fontSize: 20,),))
                     ],
                   ),));
                  }
                } else {
                  return SliverToBoxAdapter(
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
              })
        ],
      ),
    );
  }
}

class ChatTile extends StatelessWidget {
  final String targetUserName;
  final DatabaseMethods _databaseMethods = DatabaseMethods();
  Message lastMessage;
  String date = " ";

  ChatTile({this.targetUserName});

  bool isNotSeen = false;

  TextStyle getAppropriateStyle() {
    if (lastMessage.byUserName == Constants.userName) {
      isNotSeen = false;
      return TextStyle();
    } else {
      if (lastMessage.isSeen) {
        isNotSeen = false;
        return TextStyle();
      } else {
        isNotSeen = true;
        return MyThemeData.blackBold12.copyWith(fontSize: 28 / 2);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Message>>(
        stream: _databaseMethods.getAConversation(
            targetUserName: targetUserName, limitToOne: true),
        builder: (context, snapshot) {
          List<Message> data = [];
          if (snapshot.hasData) {
            data = snapshot.data;
//            data.sort((b, a) {
//              return a["time"].compareTo(b["time"]);
//            });
            lastMessage = data.first;
            DateTime temp =
                DateTime.fromMillisecondsSinceEpoch(lastMessage.time);
            date = DateFormat.MMMd().format(temp);
            return FutureBuilder<User>(
                future: _databaseMethods.getUserDetailsByUsername(
                    targetUserName: targetUserName ),
                builder: (context, snapshot) {
                  return Container(
                    color: Colors.white,
                    child: Column(
                      children: <Widget>[
                        ListTile(
                          leading: Hero(
                            tag:snapshot.hasData ? snapshot.data.profilePictureUrl : "  ",
                            child: CircleAvatar(
                              radius: 25,
                              child: snapshot.hasData
                                  ? ClipOval(
                                      child: CachedNetworkImage(
                                      imageUrl: snapshot.data.profilePictureUrl,
                                    ))
                                  : Icon(Icons.account_circle),
                            ),
                          ),
                          title: Text(
                            targetUserName,
                            overflow: TextOverflow.ellipsis,
                            style: getAppropriateStyle(),
                          ),
                          subtitle:
                              lastMessage.messageType == MessageType.onlyText
                                  ? Text(
                                      lastMessage.text != null
                                          ? lastMessage.text
                                          : " ",
                                      overflow: TextOverflow.ellipsis,
                                      style: getAppropriateStyle(),
                                    )
                                  : Row(
                                      children: <Widget>[
                                        Icon(
                                          Icons.image,
                                          color: Colors.grey,
                                        ),
                                        SizedBox(
                                          width: 8,
                                        ),
                                        Text(lastMessage.messageType ==
                                                MessageType.image
                                            ? "Image"
                                            : "Post")
                                      ],
                                    ),
                          trailing: Text(
                            date,
                            style: getAppropriateStyle(),
                          ),
                        ),
                        Divider(
                          height: 1,
                          color: Colors.grey,
                        )
                      ],
                    ),
                  );
                });
          } else {
            return Container();
          }
        });
  }
}

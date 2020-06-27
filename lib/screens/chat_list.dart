import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:droog/data/constants.dart';
import 'package:droog/models/message.dart';
import 'package:droog/models/user.dart';
import 'package:droog/screens/chat_screen.dart';
import 'package:droog/services/database_methods.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
    final searchTextField = Center(
      child: Container(
        height: 70,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        child: TextField(
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: "Search",
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
    );

    final curveContainer = Container(
      height: 20,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
    );
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            bottom: PreferredSize(
              // Add this code
              preferredSize: Size.fromHeight(60.0), // Add this code
              child: Text(''), // Add this code
            ),
            backgroundColor: Theme
                .of(context)
                .primaryColor,
            flexibleSpace: SafeArea(child: searchTextField),
          ),
          SliverToBoxAdapter(
            child: Container(
                color: Theme
                    .of(context)
                    .primaryColor, child: curveContainer),
          ),
          StreamBuilder<QuerySnapshot>(
              stream: _databaseMethods.getCurrentUserChats(
                  userName: Constants.userName),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  List<DocumentSnapshot> data = snapshot.data.documents;
                  return SliverList(
                    delegate: SliverChildBuilderDelegate((_, index) {
                      final targetUserName =
                      data[index]["users"][1] == Constants.userName
                          ? data[index]["users"][0]
                          : data[index]["users"][1];

                      return InkWell(
                        onTap: () async {
                          try {
                            User user = await _databaseMethods
                                .getUserDetailsByUsername(targetUserName: targetUserName);
                            Navigator.pushNamed(
                                context, ChatScreen.route,
                                arguments: user);
                          }  catch (e) {
                            print(e.toString());
                          }
                        },
                        child: ChatTile(
                        targetUserName: targetUserName,
                      ),);
                    }, childCount: data.length),
                  );
                } else {
                  return SliverToBoxAdapter(
                    child: CircularProgressIndicator(),
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
  DatabaseMethods _databaseMethods = DatabaseMethods();
  Message lastMessage;
  String date = "";

  ChatTile({this.targetUserName});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Message>>(
        stream: _databaseMethods.getAConversation(targetUserName: targetUserName),
        builder: (context, snapshot) {
          List<Message> data = [];
          if (snapshot.hasData) {
            data = snapshot.data;
//            data.sort((b, a) {
//              return a["time"].compareTo(b["time"]);
//            });
            lastMessage = data.first;
            DateTime temp =
            DateTime.fromMicrosecondsSinceEpoch(lastMessage.time);
            date = DateFormat.MMMd().format(temp);
          }
          return Container(
            color: Colors.white,
            child: Column(
              children: <Widget>[
                ListTile(
                  leading: CircleAvatar(
                    child: Icon(Icons.account_circle),
                  ),
                  title: Text(targetUserName, overflow: TextOverflow.ellipsis),
                  subtitle: Text(
                    lastMessage.text,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Text(date),
                ),
                Divider(
                  height: 1,
                  color: Colors.grey,
                )
              ],
            ),
          );
        });
  }
}

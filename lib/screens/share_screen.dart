import 'package:droog/models/user.dart';
import 'package:droog/screens/chat_screen.dart';
import 'package:droog/screens/user_profile.dart';
import 'package:droog/data/constants.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:droog/services/database_methods.dart';
import 'package:flutter/cupertino.dart';
import 'package:droog/utils/theme_data.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:droog/models/enums.dart';


import 'package:flutter/material.dart';
String postId;
class ShareScreen extends StatefulWidget {
  static final String route = "/Share_screen";

  @override
  _ShareScreenState createState() => _ShareScreenState();
}

class _ShareScreenState extends State<ShareScreen> {
  final DatabaseMethods _databaseMethods = DatabaseMethods();
  final TextEditingController searchController = TextEditingController();
  List<User> searchResults = [];

  getSearchResults() async {
    searchResults = await _databaseMethods.searchUser(searchController.text);
    setState(() {

    });
  }

  @override
  Widget build(BuildContext context) {
    postId = ModalRoute.of(context).settings.arguments as String;
    return Scaffold(
      body: SafeArea(
        child: Column(children: <Widget>[
          TextField(
            controller: searchController,
            onChanged: (_) => getSearchResults(),
          ),
          Expanded(child: ListView.builder(
            itemCount: searchResults.length,
            itemBuilder: (_, index) {
              return ShareTile(user: searchResults[index],);
            },))
        ],),
      ),
    );
  }
}

class ShareTile extends StatefulWidget {
  final User user;

  ShareTile({this.user,});

  @override
  _ShareTileState createState() => _ShareTileState();
}

class _ShareTileState extends State<ShareTile> {
  bool _showLoading = false;
  bool _shared = false;
  DocumentReference documentReference;

  final DatabaseMethods _databaseMethods = DatabaseMethods();

  sharePostAsMessage() async {
    setState(() {
      _showLoading = true;
    });
    final message = {
      "messageType":MessageType.sharedPost.index,
      "byUserName":Constants.userName,
      "byUid":Constants.uid,
      "postId":postId,
      "time":DateTime.now().millisecondsSinceEpoch,

    };
    documentReference = await _databaseMethods.sendMessage(targetUserName: widget.user.userName,message: message);
    setState(() {
      _showLoading = false;
      _shared = true;
    });
  }

  showAppropriateButtonChild(){
    if(_shared){
      return Icon(Icons.check,color: Colors.white,);
    }
    else{
      if(_showLoading){
        return SizedBox(height:15,width:15,child: CircularProgressIndicator(backgroundColor: Colors.white,strokeWidth: 2,));

      }
      else{
        return Text("Share",style: MyThemeData.whiteBold14,);
      }
    }
  }

  onPressedButton() async {
    if(_shared){
      setState(() {
        _showLoading = true;
      });
     await _databaseMethods.deleteMessage(documentReference: documentReference);
     setState(() {
       _shared = false;
       _showLoading = false;

     });
    }
    else{
      if(_showLoading){

      }
      else{
        sharePostAsMessage();

      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Expanded(
          child: Row(mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircleAvatar(
                  child: ClipOval(
                    child: CachedNetworkImage(
                      imageUrl: widget.user.profilePictureUrl,
                    ),
                  ),
                ),
              ),
              Flexible(
                fit: FlexFit.loose,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(widget.user.userName,maxLines: 1,overflow: TextOverflow.ellipsis,),
                    SizedBox(
                      height: 2,
                    ),
                    Text(widget.user.fullName,maxLines: 1,overflow: TextOverflow.ellipsis,),
                  ],
                ),
              ),
            ],
          ),
        ),
        Row(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(right:8.0),
              child: SizedBox(
                height: 30,
                child: RaisedButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(5))),
                  child: FittedBox(
                      child: showAppropriateButtonChild()),
                  color: MyThemeData.buttonColorBlue,
                  textColor: Colors.white,
                  onPressed: onPressedButton,
                ),
              ),
            ),

          ],
        )
      ],
    );
  }
}
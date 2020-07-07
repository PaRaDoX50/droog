import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:droog/models/post.dart';
import 'package:droog/models/user.dart';
import 'package:droog/screens/new_response_screen.dart';
import 'package:droog/screens/responses_screen.dart';
import 'package:droog/screens/share_screen.dart';
import 'package:droog/services/database_methods.dart';
import 'package:droog/utils/theme_data.dart';
import 'package:droog/widgets/expandable_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PostMessageWidget extends StatefulWidget {
  final Post post;

  PostMessageWidget({
    this.post,
  });

  @override
  _PostMessageWidgetState createState() => _PostMessageWidgetState();
}

class _PostMessageWidgetState extends State<PostMessageWidget> {
  String responses = "6";

  bool _showContainer = false;

//  Timer _timer;
//  bool _onTapEnabled = true;

  DatabaseMethods _databaseMethods = DatabaseMethods();

  Future<User> _getUserDetails() async {
//    print("asdasd" + widget.post.postBy + widget.post.postId);
    return await _databaseMethods.getUserDetailsByUsername(
      targetUserName: widget.post.postByUserName,
    );
  }

//  showPostContainer(){
//
//    setState(() {
//      _onTapEnabled = false;
//      _showContainer = !_showContainer;
//    });
//    if (_showContainer ) {
//
//      _timer = Timer.periodic(Duration(seconds: 2),(timer){
//        setState(() {
//          _onTapEnabled = true;
//          _showContainer = false;
//        });
//      });
//    }
//    else{
//      _timer.cancel();
//    }
//  }
//  @override
//  void dispose() {
//    _timer.cancel();
//    super.dispose();
//
//
//  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(
        vertical: 2,
        horizontal: 2,
      ),
      child: Stack(
        children: <Widget>[
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, ResponseScreen.route,
                  arguments: widget.post);
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                FutureBuilder<User>(
                    future: _getUserDetails(),
                    builder: (context, snapshot) {
                      return ListTile(
                        leading: snapshot.hasData
                            ? ClipOval(
                                child:CachedNetworkImage(
                                  imageUrl:snapshot.data.profilePictureUrl,
//                                  loadingBuilder: (BuildContext context,
//                                      Widget child,
//                                      ImageChunkEvent loadingProgress) {
//                                    if (loadingProgress == null) return child;
//                                    return CircularProgressIndicator(
//                                      value: loadingProgress
//                                                  .expectedTotalBytes !=
//                                              null
//                                          ? loadingProgress
//                                                  .cumulativeBytesLoaded /
//                                              loadingProgress.expectedTotalBytes
//                                          : null,
//                                    );
//                                  },
                                ),
                              )
                            : CircleAvatar(
                                child: Icon(
                                  Icons.attachment,
                                ),
                              ),
                        title: snapshot.hasData
                            ? Text(
                                snapshot.data.userName,
                                overflow: TextOverflow.ellipsis,
                              )
                            : Text(
                                "",
                              ),
                        subtitle: Text(
                          DateFormat.MMMd().format(
                            DateTime.fromMicrosecondsSinceEpoch(
                              widget.post.time,
                            ),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }),
                widget.post.description != "" ? Padding(
                  padding: const EdgeInsets.all(
                    8.0,
                  ),
                  child: ExpandableText(
                    text: widget.post.description,
                  )
                ):Container(),
                widget.post.imageUrl != null
                    ? AspectRatio(
                        aspectRatio: 4 / 3,
                        child: CachedNetworkImage(
                          imageUrl: widget.post.imageUrl,
                          progressIndicatorBuilder:
                              (context, child, loadingProgress) {
//                if (loadingProgress == null) return ;
                            return CircularProgressIndicator(
                              value: loadingProgress.totalSize != null
                                  ? loadingProgress.progress
                                  : null,
                            );
                          },
                          width: double.infinity,
                          fit: BoxFit.fill,
                        ),
                      )
                    : Container(),
              ],
            ),
          ),
//          _showContainer ? Center(child: GestureDetector(
//            onTap: (){Navigator.pushNamed(context, ResponseScreen.route,arguments: widget.post);},
//            child: Container(decoration: BoxDecoration(
//              shape: BoxShape.rectangle,
//              borderRadius: BorderRadius.circular(10),
//
//              color: Colors.grey,),
//                height: 30,
//                padding: EdgeInsets.all(8),
//                child: Center(child: Text("Show Post", style: MyThemeData.whiteBold14,),),),
//          ),) : Container(),
        ],
      ),
    );
  }
}

import 'package:cached_network_image/cached_network_image.dart';
import 'package:droog/data/constants.dart';
import 'package:droog/models/post.dart';
import 'package:droog/models/user.dart';
import 'package:droog/screens/feed.dart';
import 'package:droog/screens/new_response_screen.dart';
import 'package:droog/screens/responses_screen.dart';
import 'package:droog/screens/share_screen.dart';
import 'package:droog/screens/user_profile.dart';
import 'package:droog/services/database_methods.dart';
import 'package:droog/utils/theme_data.dart';
import 'package:droog/widgets/expandable_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class FeedTile extends StatefulWidget {
  final Post post;
  bool showBottomOptions;
  final GlobalKey<ScaffoldState> feedKey;



  FeedTile({this.post, this.showBottomOptions, this.feedKey,});

  @override
  _FeedTileState createState() => _FeedTileState();
}

class _FeedTileState extends State<FeedTile> {
  String responses = "6";

  DatabaseMethods _databaseMethods = DatabaseMethods();

  Future<User> _getUserDetails() async {
//    print("asdasd" + post.postBy + post.postId);
    return await _databaseMethods.getUserDetailsByUsername(
      targetUserName: widget.post.postByUserName,
    );
  }

  clipPost() async {
    await _databaseMethods.clipPost(postId: widget.post.postId);

    widget.feedKey.currentState
        .showSnackBar(MyThemeData.getSnackBar(text: "Post clipped."),);
    setState(() {

    });
  }
  unClipPost() async {
    await _databaseMethods.unClipPost(postId: widget.post.postId);
    widget.feedKey.currentState
        .showSnackBar(MyThemeData.getSnackBar(text: "Post unclipped"),);
    setState(() {

    });
  }

  showOptions() {
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              contentPadding: EdgeInsets.zero,
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  InkWell(
                      onTap: () async {
                        try {
                          await _databaseMethods.reportAPost(
                              targetUid: widget.post.postByUid,
                              postId: widget.post.postId);
                          Navigator.pop(context);
                        } catch (e) {
                          // TODO
                          widget.feedKey.currentState.showSnackBar(MyThemeData.getSnackBar(text: "Something went wrong"));
                          Navigator.pop(context);
                        }
                      },
                      child: ListTile(
                        leading: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Icon(
                              Icons.report,
                              color: Color(0xff4481bc),
                            ),
                          ],
                        ),
                        title: Text("Report"),
                        subtitle: Text("This post is inappropriate"),
                      )),
                  Divider(
                    height: 1,
                    thickness: 1,
                  ),

                  FutureBuilder<bool>(
                    future: _databaseMethods.isDroog(targetUid: widget.post.postByUid),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        if (snapshot.data) {
                          return InkWell(
                            onTap: () async {
                              try {
                                await _databaseMethods.disconnectFromUser(
                                    targetUid: widget.post.postByUid);
                                Navigator.pop(context);
                              } catch (e) {
                                widget.feedKey.currentState.showSnackBar(MyThemeData.getSnackBar(text: "Something went wrong"));
                                Navigator.pop(context);
                                // TODO
                              }
                            },
                            child: ListTile(
                                leading: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Icon(
                                      Icons.clear,
                                      color: Color(0xff4481bc),
                                    ),
                                  ],
                                ),
                                title: Text("Disconnect"),
                                subtitle:
                                    Text("Split from ${widget.post.postByUserName}")),
                          );
                        }
                        else{
                          return Container();
                        }

                      }
                      else{
                        return Container();
                      }
                    }
                  )
                ],
              ),
            ));
  }

  String getDate() {
    return DateTime.fromMillisecondsSinceEpoch(
                  widget.post.time,
                ).difference(DateTime.now()).inDays *
                (-1) >
            0
        ? DateFormat.MMMd().format(
            DateTime.fromMillisecondsSinceEpoch(
              widget.post.time,
            ),
          )
        : DateFormat("hh:mm a").format(DateTime.fromMillisecondsSinceEpoch(
            widget.post.time,
          ));
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Color(0xfffcfcfd),
      elevation: 5,
      margin: EdgeInsets.symmetric(
        vertical: 8 / 2,
        horizontal: 8,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          FutureBuilder<User>(
              future: _getUserDetails(),
              builder: (context, snapshot) {
                return ListTile(
                  leading: snapshot.hasData
                      ? GestureDetector(
                          onTap: () => Navigator.pushNamed(
                              context, UserProfile.route,
                              arguments: snapshot.data),
                          child: ClipOval(
                            child: CachedNetworkImage(
                              imageUrl: snapshot.data.profilePictureUrl,
//                            loadingBuilder: (BuildContext context, Widget child,
//                                ImageChunkEvent loadingProgress) {
//                              if (loadingProgress == null) return child;
//                              return CircularProgressIndicator(
//                                value: loadingProgress.expectedTotalBytes !=
//                                        null
//                                    ? loadingProgress.cumulativeBytesLoaded /
//                                        loadingProgress.expectedTotalBytes
//                                    : null,
//                              );
//                            },
                            ),
                          ),
                        )
                      : null,
                  title: snapshot.hasData
                      ? GestureDetector(
                          onTap: () => Navigator.pushNamed(
                              context, UserProfile.route,
                              arguments: snapshot.data),
                          child: Text(
                            snapshot.data.userName,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(),
                          ),
                        )
                      : Text(
                          "",
                        ),
                  subtitle: Text(
                    getDate(),
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: widget.post.postByUserName != Constants.userName
                      ? IconButton(
                          onPressed: showOptions,
                          icon: Icon(
                            Icons.more_vert,
                          ),
                        )
                      : null,
                );
              }),
          widget.post.description != ""
              ? Padding(
                  padding: const EdgeInsets.all(
                    8.0,
                  ),
                  child: ExpandableText(
                    text: widget.post.description,
                  ))
              : Container(),
          widget.post.imageUrl != null
              ? AspectRatio(
                  aspectRatio: 4 / 3,
                  child: CachedNetworkImage(
                    imageUrl: widget.post.imageUrl,
//                    progressIndicatorBuilder:
//                        (context, child, loadingProgress) {
////                if (loadingProgress == null) return ;
//                      return Center(
//                        child: SizedBox(
//                          height: 0,
//                          width: 0,
//                          child: CircularProgressIndicator(
//
//                            value: loadingProgress.totalSize != null
//                                ? loadingProgress.progress
//                                : null,
//                          ),
//                        ),
//                      );
//                    },
                    width: double.infinity,
                    fit: BoxFit.fill,
                  ),
                )
              : Container(),
          Padding(
            padding: const EdgeInsets.all(
              8.0,
            ),
            child: widget.showBottomOptions != false
                ? Row(
                    children: <Widget>[
                      Expanded(
                        child: GestureDetector(
                          onTap: () => Navigator.pushNamed(
                            context,
                            ResponseScreen.route,
                            arguments: widget.post,
                          ),
                          child: FutureBuilder<int>(
                              future:
                                  _databaseMethods.getResponsesCountByPostId(
                                      widget.post.postId),
                              builder: (context, snapshot) {
                                return Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Text(
                                      snapshot.hasData
                                          ? "${snapshot.data} Responses"
                                          : "Responses",
                                      style: TextStyle(
                                          color:
                                              Theme.of(context).primaryColor),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                );
                              }),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: GestureDetector(
                          child: Icon(
                            Icons.add_comment,
                            color: Colors.blueGrey,
                          ),
                          onTap: () => Navigator.of(context).pushNamed(
                            NewResponse.route,
                            arguments: widget.post,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(
                          8.0,
                        ),
                        child: GestureDetector(
                            onTap: () {
                              Navigator.of(context).pushNamed(ShareScreen.route,
                                  arguments: widget.post.postId);
                            },
                            child: FaIcon(
                              FontAwesomeIcons.paperPlane,
                              color: Colors.blueGrey,
                            )),
                      ),
                      Padding(
                          padding: const EdgeInsets.all(
                            8.0,
                          ),
                          child: FutureBuilder<bool>(
                            future: _databaseMethods.isClipped(
                                postId: widget.post.postId),
                            builder: (_, snapshot) {
                              if (snapshot.hasData) {
                                if(snapshot.data){
                                  return GestureDetector(
                                      onTap: unClipPost,
                                      child: Icon(Icons.indeterminate_check_box,color: Colors.blueGrey,));

                                }
                                else{
                                  return GestureDetector(
                                      onTap: clipPost,
                                      child: Icon(Icons.content_paste,color: Colors.blueGrey,));
                                }
                              }
                              else{
                                return Container(height: 25,width: 25,);
                              }
                            },
                          )),
                    ],
                  )
                : Container(),
          )
        ],
      ),
    );
  }


}

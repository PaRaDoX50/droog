import 'package:cached_network_image/cached_network_image.dart';
import 'package:droog/models/post.dart';
import 'package:droog/models/user.dart';
import 'package:droog/screens/feed.dart';
import 'package:droog/screens/new_response_screen.dart';
import 'package:droog/screens/responses_screen.dart';
import 'package:droog/screens/share_screen.dart';
import 'package:droog/services/database_methods.dart';
import 'package:droog/widgets/expandable_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class FeedTile extends StatelessWidget {
  final Post post;
  String responses = "6";
  bool showBottomOptions;
  final GlobalKey<ScaffoldState> feedKey;
  FeedTile({
    this.post,
    this.showBottomOptions,
    this.feedKey
  });

  DatabaseMethods _databaseMethods = DatabaseMethods();

  Future<User> _getUserDetails() async {
//    print("asdasd" + post.postBy + post.postId);
    return await _databaseMethods.getUserDetailsByUsername(
      targetUserName: post.postBy,
    );
  }
  clipPost () async{await _databaseMethods.clipPost(postId: post.postId);
  feedKey.currentState.showSnackBar(SnackBar(content: Text("Post Clipped")));
  }

  @override
  Widget build(BuildContext context) {
    return Card(
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
                      ? ClipOval(
                          child: CachedNetworkImage(
                            imageUrl:snapshot.data.profilePictureUrl,
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
                    style: GoogleFonts.montserrat(),
                        )
                      : Text(
                          "",
                        ),
                  subtitle: Text(
                    DateFormat.MMMd().format(
                      DateTime.fromMicrosecondsSinceEpoch(
                        post.time,
                      ),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Icon(
                    Icons.more_vert,
                  ),
                );
              }),
          post.description != "" ? Padding(
              padding: const EdgeInsets.all(
                8.0,
              ),
              child: ExpandableText(
                text: post.description,
              )
          ):Container(),
          post.imageUrl != null
              ? AspectRatio(
                  aspectRatio: 4 / 3,
                  child: CachedNetworkImage(
                    imageUrl: post.imageUrl,
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
          Padding(
            padding: const EdgeInsets.all(
              8.0,
            ),
            child: showBottomOptions != false ? Row(
              children: <Widget>[
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.pushNamed(
                      context,
                      ResponseScreen.route,
                      arguments: post,
                    ),
                    child: FutureBuilder<int>(
                      future: _databaseMethods.getResponsesCountByPostId(post.postId),
                      builder: (context, snapshot) {
                        return Row(mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text(
                              snapshot.hasData ?
                              "See all ${snapshot.data} Responses":"See all Responses" ,
                              style: TextStyle(color: Theme.of(context).primaryColor),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        );
                      }
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GestureDetector(
                    child: Icon(Icons.message,color: Colors.grey,),

                    onTap: () => Navigator.of(context).pushNamed(
                      NewResponse.route,
                      arguments: post,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(
                    8.0,
                  ),
                  child: GestureDetector(
                    onTap: (){Navigator.of(context).pushNamed(ShareScreen.route,arguments: post.postId);},
                    child: Icon(
                      Icons.send,
                      color: Colors.grey,
                      semanticLabel: "Share",
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(
                    8.0,
                  ),
                  child: GestureDetector(
                    onTap: clipPost,
                    child: Icon(
                      Icons.content_paste,
                      color: Colors.grey,

                    ),
                  ),
                ),
              ],
            ):Container(),
          )
        ],
      ),
    );
  }
}

import 'package:cached_network_image/cached_network_image.dart';
import 'package:droog/models/post.dart';
import 'package:droog/models/user.dart';
import 'package:droog/screens/new_response_screen.dart';
import 'package:droog/screens/responses_screen.dart';
import 'package:droog/screens/share_screen.dart';
import 'package:droog/services/database_methods.dart';
import 'package:droog/widgets/expandable_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FeedTile extends StatelessWidget {
  final Post post;
  String responses = "6";

  FeedTile({
    this.post,
  });

  DatabaseMethods _databaseMethods = DatabaseMethods();

  Future<User> _getUserDetails() async {
    print("asdasd" + post.postBy + post.postId);
    return await _databaseMethods.getUserDetailsByUsername(
      targetUserName: post.postBy,
    );
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
          Padding(
            padding: const EdgeInsets.all(
              8.0,
            ),
            child: ExpandableText(
              text: post.description,
            ),
          ),
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
            child: Row(
              children: <Widget>[
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.pushNamed(
                      context,
                      ResponseScreen.route,
                      arguments: post,
                    ),
                    child: Text(
                      "$responses Responses",
                      style: TextStyle(color: Theme.of(context).primaryColor),
                      overflow: TextOverflow.ellipsis,
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
                  child: Icon(
                    Icons.content_paste,
                    color: Colors.grey,

                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

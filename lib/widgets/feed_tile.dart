import 'package:droog/models/post.dart';
import 'package:droog/models/user.dart';
import 'package:droog/services/database_methods.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FeedTile extends StatelessWidget {
  Post post;

  FeedTile({this.post});

  DatabaseMethods _databaseMethods = DatabaseMethods();

  Future<User> _getUserDetails() async {
    return await _databaseMethods.getUserDetailsByUsername(
        userName: post.postBy);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8),
      child: Column(
        children: <Widget>[
          FutureBuilder<User>(
              future: _getUserDetails(),
              builder: (context, snapshot) {
                return ListTile(
                  leading: snapshot.hasData
                      ? ClipOval(
                          child: Image.network(
                            snapshot.data.profilePictureUrl != null
                                ? snapshot.data.profilePictureUrl
                                : " ",
                            loadingBuilder: (BuildContext context, Widget child,
                                ImageChunkEvent loadingProgress) {
                              if (loadingProgress == null) return child;
                              return CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes !=
                                        null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes
                                    : null,
                              );
                            },
                            errorBuilder: (x, y, z) {
                              return CircleAvatar(child: Icon(Icons.error));
                            },
                          ),
                        )
                      : CircleAvatar(child: Icon(Icons.attachment)),
                  title: snapshot.hasData
                      ? Text(snapshot.data.userName)
                      : Text(""),
                  subtitle: Text(
                    DateFormat.MMMd().format(
                      DateTime.fromMicrosecondsSinceEpoch(
                        post.time,
                      ),
                    ),
                  ),
                  trailing: Icon(Icons.more_vert),
                );
              }),
          Text(post.description),
          post.imageUrl != null ? AspectRatio(
            aspectRatio: 1,

            child: Image.network(
              post.imageUrl,
              loadingBuilder: (BuildContext context, Widget child,
                  ImageChunkEvent loadingProgress) {
                if (loadingProgress == null) return child;
                return CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes !=
                      null
                      ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes
                      : null,
                );
              },
              width: double.infinity,fit: BoxFit.fill,


            ),
          ) : Container(),
        ],
      ),
    );
  }
}

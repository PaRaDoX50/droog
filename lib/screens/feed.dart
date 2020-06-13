import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:droog/models/post.dart';
import 'package:droog/services/database_methods.dart';
import 'package:droog/widgets/feed_tile.dart';
import 'package:flutter/material.dart';

class Feed extends StatefulWidget {
  @override
  _FeedState createState() => _FeedState();
}

class _FeedState extends State<Feed>{
  final DatabaseMethods _databaseMethods = DatabaseMethods();

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: StreamBuilder<QuerySnapshot>(
        stream: _databaseMethods.getPosts(),
        builder: (_, snapshot) {
          if (snapshot.hasData) {

            return ListView.builder(
              itemCount: snapshot.data.documents.length,
                itemBuilder: (_, index) {
              final post = _postFromFirebasePost(snapshot.data.documents[index]);
              return FeedTile(
                post: post,
              );
            });
          }


          return Center(child: Text("Loading...."));
        },
      ),
    );
  }
}

Post _postFromFirebasePost(DocumentSnapshot documentSnapshot) {
  return documentSnapshot != null ? Post(
      description: documentSnapshot["description"],
      imageUrl: documentSnapshot["imageUrl"],
      postBy: documentSnapshot["postBy"],
      time: documentSnapshot["time"]): null;
}
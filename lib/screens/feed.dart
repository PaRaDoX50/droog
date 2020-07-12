import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:droog/models/post.dart';
import 'package:droog/services/database_methods.dart';
import 'package:droog/widgets/feed_tile.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';

class Feed extends StatefulWidget {
  @override
  _FeedState createState() => _FeedState();
}

class _FeedState extends State<Feed> {
  final _feedScaffoldKey = GlobalKey<ScaffoldState>();

  final DatabaseMethods _databaseMethods = DatabaseMethods();
  List<Post> posts = [];
  List<String> followingUids = [];
  DocumentSnapshot lastDocument;
  int countOfMoreDocs;
  bool _isLoading = false;
  bool _isFirstTime = true;
  bool _isFirstSnapshot = true;
  bool _rebuildDueToSetState =  false;
  int buildCount = 0;


  // loadMore() async {
  //   if(posts.isEmpty){
  //     _databaseMethods.getPostsForFeed();
  //   }
  // }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      key: _feedScaffoldKey,
      backgroundColor: Colors.white,
      body: FutureBuilder<List<String>>(
          future: _databaseMethods.getConnectionUids(),
          builder: (_, snapshot) {
            if (snapshot.hasData) {
              followingUids = snapshot.data;
              Stream<QuerySnapshot> stream = _databaseMethods.getPostsForFeed(
                  droogsUids: followingUids);
              return StreamBuilder<QuerySnapshot>(
                stream:stream,
                builder: (_, snapshot) {

                  print("build"+(++buildCount).toString());
                  if (snapshot.hasData) {


                    if (_isFirstTime && snapshot.data.documents.length != 0) {
                      print("first time");
                      lastDocument = snapshot.data.documents.last;
                      posts = snapshot.data.documents.map((e) => _postFromFirebasePost(documentSnapshot: e)).toList();
                      countOfMoreDocs = posts.length;
//                      _isFirstTime = false;
                    }
                    if (!listEquals(snapshot.data.documents.map((e) => e.documentID).toList(), snapshot.data.documentChanges.map((e) => e.document.documentID).toList())) {
                        print("changes");
                        print(snapshot.data.documentChanges.length);
                        if(snapshot.data.documentChanges.isNotEmpty){

                            if (snapshot.data.documentChanges[0].type == DocumentChangeType.added) {
                              posts.insert(0, _postFromFirebasePost(documentSnapshot: snapshot.data.documentChanges[0].document));


                          }
                        }
                    }

                    return posts.length != 0 ? LazyLoadScrollView(
                      onEndOfPage: countOfMoreDocs == 10 ?_loadMore : (){},
                      isLoading: _isLoading,
                      scrollOffset: 100,
                      child: ListView(
                          children:posts.map((e) => FeedTile(post: e,feedKey: _feedScaffoldKey,)).toList() ,),
                    ) : Center(child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Image.asset("assets/images/empty_feed.png"),
                        FittedBox(child: Text("No Posts To Display",style: GoogleFonts.montserrat(fontSize: 20),)),
                      ],
                    ),);
                  }
                  else {
                    if(snapshot.connectionState == ConnectionState.done ){
                      return Center(child:  Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Image.asset("assets/images/empty_feed.png"),
                          FittedBox(child: Text("No Posts To Display",style: GoogleFonts.montserrat(fontSize: 20),)),
                        ],
                      ),);
                    }
                    return Center(child: CircularProgressIndicator());
                  }
                },
              );
            } else {
              if(snapshot.connectionState == ConnectionState.done){
                return Center(child: Text("No Posts To Display"),);
              }
              return Center(child:  CircularProgressIndicator());
            }
          }),
    );
  }

  void _loadMore() async {
    print("loadingmore");
    setState(() {
      _isFirstTime = false;
      _isLoading = true;
//      _rebuildDueToSetState = true;
    });
    List<DocumentSnapshot> moreDocuments = await _databaseMethods.getMorePostsForFeed(droogsUids: followingUids,documentSnapshot: lastDocument,);
    lastDocument = moreDocuments.last;
    List<Post> morePosts = moreDocuments.map((e) => _postFromFirebasePost(documentSnapshot: e)).toList();
    countOfMoreDocs = morePosts.length;
    posts.addAll(morePosts);
    setState(() {
//      _rebuildDueToSetState = true;
      _isFirstTime = false;
      _isLoading = false;
    });
  }
}

Post _postFromFirebasePost({DocumentSnapshot documentSnapshot}) {
  return documentSnapshot != null
      ? Post(
      description: documentSnapshot["description"],
      imageUrl: documentSnapshot["imageUrl"],
      postByUserName: documentSnapshot["postByUserName"],
      time: documentSnapshot["time"],
      postId: documentSnapshot.documentID,
      postByUid: documentSnapshot["postByUid"],
      solutionId: documentSnapshot["solutionId"])
      : null;
}

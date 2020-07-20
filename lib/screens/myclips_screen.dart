import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:droog/models/post.dart';
import 'package:droog/services/database_methods.dart';
import 'package:droog/widgets/feed_tile.dart';
import 'package:flutter/material.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';

class MyClipsScreen extends StatefulWidget {
  static final route = "/my_clips_screen";

  @override
  _MyClipsScreenState createState() => _MyClipsScreenState();
}

class _MyClipsScreenState extends State<MyClipsScreen> {
  final DatabaseMethods _databaseMethods = DatabaseMethods();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  DocumentSnapshot _lastDocument;

  List<Post> posts = [];

  bool _isFirstTime = true;

  bool _isLoading = false;

  int _countOfMoreDocuments;

  _loadMoreClips() async {
    print("loadingmore");
    setState(() {
      _isFirstTime = false;
      _isLoading = true;
//      _rebuildDueToSetState = true;
    });
    print(posts.length.toString() + "loadingmore");
    List<DocumentSnapshot> moreDocuments = await _databaseMethods.loadMoreClips(
      lastIndex: posts.length - 1,
    );
//    _lastDocument = moreDocuments.last;
    if (moreDocuments.isNotEmpty) {
      List<Post> morePosts = moreDocuments
          .map((e) => _databaseMethods.postFromFirebasePost(documentSnapshot: e))
          .toList();
      _countOfMoreDocuments = morePosts.length;
      posts.insertAll(0, morePosts);
    }
    else{
      _countOfMoreDocuments = 0;
    }
    setState(() {
//      _rebuildDueToSetState = true;
      _isFirstTime = false;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      appBar: AppBar(
          iconTheme: IconThemeData(color: Theme.of(context).primaryColor),
          elevation: 5,
          backgroundColor: Color(0xfffcfcfd),
          title: Text(
            "Clips",
            style: TextStyle(color: Theme.of(context).primaryColor),
          )),
      body: FutureBuilder<List<DocumentSnapshot>>(
          future: _databaseMethods.getClips(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              if (_isFirstTime) {
                posts.addAll(snapshot.data
                    .map((e) => _databaseMethods.postFromFirebasePost(
                        documentSnapshot: e))
                    .toList());
                _countOfMoreDocuments = snapshot.data.length;
                _lastDocument = snapshot.data.last;
              }
              if (posts.isNotEmpty) {
                return LazyLoadScrollView(
                  isLoading: _isLoading,
                  onEndOfPage:
                      _countOfMoreDocuments == 10 ? _loadMoreClips : () {},
                  scrollOffset: 300,
                  child: ListView.builder(
                    itemBuilder: (_, index) {

                      if (index == posts.length - 1 && _isLoading) {

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            FeedTile(
                              post: posts.reversed.toList()[index],
                              feedKey: _scaffoldKey,

                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: CircularProgressIndicator(),
                            )
                          ],
                        );
                      }
                      return FeedTile(
                        post: posts.reversed.toList()[index],
                        feedKey: _scaffoldKey,

                      );
                    },
                    itemCount: posts.length,
                  ),
                );
              } else {
                return Center(child: Image.asset("assets/images/no_clips.png"));
              }
            } else {
              if (snapshot.connectionState == ConnectionState.done) {
                return Center(child: Image.asset("assets/images/no_clips.png"));
              }
              return Center(
                child: CircularProgressIndicator(),
              );
            }
          }),
    );
  }
}

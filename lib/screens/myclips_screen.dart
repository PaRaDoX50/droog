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

  DocumentSnapshot _lastDocument;

  List<Post> posts = [];

  bool _isFirstTime = true;

  bool _isLoading = false;

  int _countOfMoreDocuments ;

  _loadMoreClips()async{
    print("loadingmore");
    setState(() {
      _isFirstTime = false;
      _isLoading = true;
//      _rebuildDueToSetState = true;
    });
    List<DocumentSnapshot> moreDocuments = await _databaseMethods.loadMoreClips(documentSnapshot: _lastDocument,);
    _lastDocument = moreDocuments.last;
    List<Post> morePosts = moreDocuments.map((e) => _databaseMethods.postFromFirebasePost(documentSnapshot: e)).toList();
    _countOfMoreDocuments = morePosts.length;
    posts.addAll(morePosts);
    setState(() {
//      _rebuildDueToSetState = true;
      _isFirstTime = false;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:  AppBar(
        title: Text("Clips"),
        flexibleSpace: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: <Color>[Theme.of(context).primaryColor, Colors.blue])),
        ),
      ),
      body: FutureBuilder<List<DocumentSnapshot>>(
      future: _databaseMethods.getClips(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (_isFirstTime) {

            posts.addAll(snapshot.data.map((e) => _databaseMethods.postFromFirebasePost(documentSnapshot: e)).toList());
            _countOfMoreDocuments = snapshot.data.length;
            _lastDocument = snapshot.data.last;
          }
          if (posts.isNotEmpty) {
            return LazyLoadScrollView(
              isLoading: _isLoading,
              onEndOfPage:_countOfMoreDocuments == 10 ?  _loadMoreClips:(){},
              scrollOffset: 100,
              child: ListView.builder(itemBuilder: (_,index){
                return FeedTile(post: posts[index],);
              },itemCount: posts.length,),
            );
          }
          else{
            return Center(child: Text("No clips"),);
          }
        }
        else{

          if(snapshot.connectionState == ConnectionState.done){
            return Center(child: Text("No clips"),);

          }
          return Center(child: CircularProgressIndicator(),);
        }
      }
    ),);
  }
}

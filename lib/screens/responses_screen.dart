import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:droog/models/post.dart';
import 'package:droog/models/response.dart';
import 'package:droog/services/database_methods.dart';
import 'package:droog/utils/theme_data.dart';
import 'package:droog/widgets/feed_tile.dart';
import 'package:droog/widgets/response_tile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ResponseScreen extends StatefulWidget {
  static String route = "/response_screen";

  @override
  ResponseScreenState createState() => ResponseScreenState();
}

class ResponseScreenState extends State<ResponseScreen> {
  Post post;
  DatabaseMethods _databaseMethods = DatabaseMethods();
  Future<List<Response>> responses;
  int buildMethodCount = 0;
  bool _showLoading = false;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
//    print("asdaddddddddddddddddddddd"+post.postId);
  }

  solutionChanged(
      {DocumentSnapshot documentSnapshot, bool markAsSolution}) async {
//    responses = _databaseMethods.getResponsesByPostId(post.postId);
//    setState(() {
//
//    });
    await _databaseMethods.toggleSolutionForPost(
        responseDocument: documentSnapshot, markAsSolution: markAsSolution);
    if (markAsSolution) {
      post.solutionId = documentSnapshot.documentID;
    } else {
      post.solutionId = null;
    }
    setState(() {});
  }

  toggleLoading() {
    setState(() {
      _showLoading = !_showLoading;
    });
  }

  @override
  Widget build(BuildContext context) {
    post = ModalRoute.of(context).settings.arguments as Post;

    if (buildMethodCount == 0) {
      responses = _databaseMethods.getResponsesByPostId(post.postId);
    }

    buildMethodCount++;

    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        iconTheme: IconThemeData(color: Theme.of(context).primaryColor),
        elevation: 5,
        backgroundColor: Color(0xfffcfcfd),
        title: Text("Responses",
            style:
                GoogleFonts.montserrat(color: Theme.of(context).primaryColor)),
      ),
      body: Stack(
        children: <Widget>[
          IgnorePointer(
            ignoring: _showLoading,
            child: CustomScrollView(
              slivers: <Widget>[
                SliverToBoxAdapter(
                  child: FeedTile(
                    post: post,
                    showBottomOptions: false,
                  ),
                ),
                SliverToBoxAdapter(
                    child: Divider(
                  color: Colors.grey[300],
                  thickness: 1,
                )),
                FutureBuilder<List<Response>>(
                    future: responses,
                    builder: (context, snapshot) {
                      return snapshot.hasData
                          ? SliverList(
                              delegate: SliverChildBuilderDelegate((_, index) {
                                bool isSolution =
                                    snapshot.data[index].document.documentID ==
                                            post.solutionId
                                        ? true
                                        : false;
                                return ResponseTile(
                                    isSolution: isSolution,
                                    toggleLoading: toggleLoading,
                                    solutionChanged: solutionChanged,
                                    response: snapshot.data[index],
                                    scaffoldKey: scaffoldKey,
                                    postByUserName: post.postByUserName);
                              }, childCount: snapshot.data.length),
                            )
                          : SliverToBoxAdapter(
                              child: Center(
                                child: CircularProgressIndicator(),
                              ),
                            );
                    })
              ],
            ),
          ),
          _showLoading
              ? Container(
                  height: double.infinity,
                  width: double.infinity,
                  color: Colors.transparent,
                  child: Center(
                    child: CircularProgressIndicator(),
                  ))
              : Container(),
        ],
      ),
    );
  }
}

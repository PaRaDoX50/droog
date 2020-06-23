import 'package:droog/models/post.dart';
import 'package:droog/models/response.dart';
import 'package:droog/services/database_methods.dart';
import 'package:droog/utils/theme_data.dart';
import 'package:droog/widgets/feed_tile.dart';
import 'package:droog/widgets/response_tile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ResponseScreen extends StatefulWidget {
  static String route = "/response_screen";

  @override
  _ResponseScreenState createState() => _ResponseScreenState();
}

class _ResponseScreenState extends State<ResponseScreen> {
  Post post;
  DatabaseMethods _databaseMethods = DatabaseMethods();
  Future<List<Response>> responses;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
//    print("asdaddddddddddddddddddddd"+post.postId);
  }

  @override
  Widget build(BuildContext context) {
    post = ModalRoute.of(context).settings.arguments as Post;
    responses = _databaseMethods.getResponsesByPostId(post.postId);

    return Scaffold(
      appBar: AppBar(
        title: Text("Responses"),
      ),
      body: CustomScrollView(
        slivers: <Widget>[
          SliverToBoxAdapter(
            child: FeedTile(
              post: post,
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
                          return ResponseTile(
                              response: snapshot.data[index],
                              postBy: post.postBy);
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
    );
  }
}

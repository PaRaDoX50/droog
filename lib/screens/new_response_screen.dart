import 'package:droog/models/enums.dart';
import 'package:droog/models/post.dart';
import 'package:droog/widgets/feed_tile.dart';
import 'package:droog/widgets/new_post_box.dart';
import 'package:flutter/material.dart';

class NewResponse extends StatelessWidget {
  static final String route = "/new_response";
  Post post;
  @override
  Widget build(BuildContext context) {
    post = ModalRoute.of(context).settings.arguments as Post;

    return Scaffold(body:SingleChildScrollView(
      child: Column(children: <Widget>[
        FeedTile(post: post,),
        SizedBox(height: 8,),
        NewPostBox(postIs: PostIs.response,postId: post.postId,),
      ],),
    ),);
  }
}

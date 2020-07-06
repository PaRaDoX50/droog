import 'package:droog/models/enums.dart';
import 'package:droog/models/post.dart';
import 'package:droog/widgets/feed_tile.dart';
import 'package:droog/widgets/new_post_box.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NewResponse extends StatefulWidget {
  static final String route = "/new_response";

  @override
  _NewResponseState createState() => _NewResponseState();
}

class _NewResponseState extends State<NewResponse> {
  Post post;
  bool _showLoading = false;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  toggleLoading(){
    setState(() {
      _showLoading = !_showLoading;
    });
  }

  @override
  Widget build(BuildContext context) {
    post = ModalRoute.of(context).settings.arguments as Post;

    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
          iconTheme: IconThemeData(color: Theme.of(context).primaryColor),
          elevation: 5,
          backgroundColor: Color(0xfffcfcfd),
          title: Text(
            "Respond",
            style:
                GoogleFonts.montserrat(color: Theme.of(context).primaryColor),
          )),
      body: Stack(
        children: <Widget>[
          SingleChildScrollView(
            child: Column(
              children: <Widget>[
                FeedTile(
                  post: post,
                  showBottomOptions: false,
                ),

                NewPostBox(
                  postIs: PostIs.response,
                  post: post,
                  toggleLoading: toggleLoading,
                ),
              ],
            ),
          ),
          _showLoading ? Center(child: CircularProgressIndicator(),) : Container(),
        ],
      ),
    );
  }
}


import 'package:droog/models/enums.dart';
import 'package:droog/widgets/new_post_box.dart';
import 'package:flutter/material.dart';

class NewPost extends StatefulWidget {
  static final String route = "/new_post";

  @override
  _NewPostState createState() => _NewPostState();
}

class _NewPostState extends State<NewPost> {

  final scaffoldKey = GlobalKey<ScaffoldState>();
  bool _showLoading = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }


  toggleLoading(){
    setState(() {
      _showLoading = !_showLoading;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Color(0xfffcfcfd),
      body: Stack(
        children: <Widget>[
          Center(child: NewPostBox(postIs: PostIs.normalPost,toggleLoading: toggleLoading,scaffoldKey: scaffoldKey,)),
          _showLoading ? Center(child: CircularProgressIndicator(),) : Container(),
        ],
      )
    );
  }
}

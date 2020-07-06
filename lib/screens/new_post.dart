import 'dart:io';

import 'package:droog/data/constants.dart';
import 'package:droog/models/enums.dart';
import 'package:droog/services/database_methods.dart';
import 'package:droog/widgets/new_post_box.dart';
import 'file:///P:/androidProjects/Droog/droog/lib/utils/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

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
      backgroundColor: Color(0xfffcfcfd),
      body: Stack(
        children: <Widget>[
          Center(child: NewPostBox(postIs: PostIs.normalPost,toggleLoading: toggleLoading,)),
          _showLoading ? Center(child: CircularProgressIndicator(),) : Container(),
        ],
      )
    );
  }
}

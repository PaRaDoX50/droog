import 'package:flutter/material.dart';

class Home extends StatelessWidget {
  static final String route = "/home";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text("This will open after you successfully log in"),
      ),
    );
  }
}

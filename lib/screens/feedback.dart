import 'package:droog/services/database_methods.dart';
import 'package:droog/utils/theme_data.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FeedbackScreen extends StatelessWidget {
  static final String route = "/feedback_screen";
  final feedbackController = TextEditingController();
  DatabaseMethods _databaseMethods = DatabaseMethods();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  bool allowed = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Theme.of(context).primaryColor),
        elevation: 5,
        backgroundColor: Color(0xfffcfcfd),
        title: Text(
          "Share Feedback",
          style: TextStyle(color: Theme.of(context).primaryColor),
        ),
      ),
      key: _scaffoldKey,
      body: Center(
        child: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: feedbackController,
                  maxLines: 11,
                  decoration: InputDecoration(
                    border:
                        OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    hintText: "Your feedback",
                  ),
                ),
              ),

              ButtonTheme(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Container(
                  height: 29,
                  width: MediaQuery.of(context).size.width * .3,
                  child: RaisedButton(
                    child: Text(
                      "Send",
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    color: Theme.of(context).buttonColor,
                    onPressed: sendFeedback,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future sendFeedback() async {
    if (feedbackController.text != "") {
      if (allowed) {
        try {
          await _databaseMethods.sendFeedback(
              feedback: feedbackController.text);
          feedbackController.clear();
          _scaffoldKey.currentState.showSnackBar(MyThemeData.getSnackBar(text: "Thanks for the feedback"));
          allowed = false;
        } catch (e) {
          // TODO
          _scaffoldKey.currentState.showSnackBar(MyThemeData.getSnackBar(text: "Something went wrong"));
        }
      } else {
        _scaffoldKey.currentState.showSnackBar(MyThemeData.getSnackBar(text: "Only allowed to send feedback once per app session"));
      }
    }
  }
}

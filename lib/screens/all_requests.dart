import 'package:droog/models/user.dart';
import 'package:droog/services/database_methods.dart';
import 'package:droog/widgets/request_tile.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AllRequests extends StatefulWidget {
  static final String route = "/all_requests";

  @override
  _AllRequestsState createState() => _AllRequestsState();
}

class _AllRequestsState extends State<AllRequests> {
  Future userRequests;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  DatabaseMethods _databaseMethods = DatabaseMethods();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    userRequests = _databaseMethods.getRequests(limitTo3: false);
  }

  showSnackBarAndSetState(String text) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      backgroundColor: Theme.of(context).primaryColor,
      content: Text(text),
    ));
    setState(() {
      userRequests = _databaseMethods.getRequests(limitTo3: false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Theme.of(context).primaryColor),
        elevation: 5,
        backgroundColor: Color(0xfffcfcfd),
        title: Text(
          "All Requests",
          style: GoogleFonts.montserrat(color: Theme.of(context).primaryColor),
        ),
      ),
      body: FutureBuilder(
          future: userRequests,
          builder: (_, snapshot) {
            if (snapshot.hasData) {
              return ListView.builder(
                itemBuilder: (_, index) {
                  return RequestTile(
                    user: snapshot.data[index],
                    snackBarAndSetState: showSnackBarAndSetState,
                  );
                },
                itemCount: snapshot.data.length,
              );
            } else {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
          }),
    );
  }
}

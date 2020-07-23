import 'package:droog/data/constants.dart';
import 'package:droog/models/user.dart';
import 'package:droog/services/database_methods.dart';

import 'package:droog/widgets/search_tile.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:transparent_image/transparent_image.dart';


class DroogsList extends StatefulWidget {
  static final String route = "/droogs_list";

  @override
  _DroogsListState createState() => _DroogsListState();
}

class _DroogsListState extends State<DroogsList> {
  final DatabaseMethods _databaseMethods = DatabaseMethods();
  final TextEditingController searchController = TextEditingController();
  List<User> searchResults = [];
  final scaffoldKey = GlobalKey<ScaffoldState>();

//  getSearchResults() async {
//    searchResults = await _databaseMethods.searchUser(searchController.text);
//    setState(() {});
//  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Theme
            .of(context)
            .primaryColor),
        elevation: 5,
        backgroundColor: Color(0xfffcfcfd),
        title: Text(
          "Your Droogs",
          style: GoogleFonts.lato(color: Theme
              .of(context)
              .primaryColor),
        ),

      ),
      key: scaffoldKey,
      backgroundColor: Colors.white,
      body: SafeArea(
          child: FutureBuilder<List<User>>(
              future: _databaseMethods.getListOfYourDroogs(),
              builder: (_, snapshot) {
                if (snapshot.hasData) {
                  searchResults = snapshot.data;
                  return (searchResults.isNotEmpty
                      ? Expanded(
                      child: ListView.builder(
                        itemCount: searchResults.length,
                        itemBuilder: (_, index) {
//                      searchResults[index].userName != Constants.userName
                          if (searchResults[index].userName !=
                              Constants.userName) {
                            return SearchTile(
                              scaffoldKey: scaffoldKey,
                              user: searchResults[index],
                            );
                          } else {
                            return Container();
                          }
                        },
                      ))
                      : Expanded(
                      child: Center(
                          child: AspectRatio(
                              aspectRatio: 1,
                              child: FadeInImage(
                                image: AssetImage(
                                  "assets/images/no_results.png",),
                                width: double.infinity,
                                placeholder: MemoryImage(
                                    kTransparentImage),)))));
                } else {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return Center(
                      child: AspectRatio(
                          aspectRatio: 1,
                          child:
                          FadeInImage(
                            image: AssetImage("assets/images/no_results.png",),
                            width: double.infinity,
                            placeholder: MemoryImage(kTransparentImage),)));
//                            Image.asset(
//                              "assets/images/no_results.png",
//                              width: double.infinity,
//                            )));
                          }
                          return Center(
                          child: CircularProgressIndicator(),
                    );
                  }
                })),
    );
  }
}



import 'package:cached_network_image/cached_network_image.dart';
import 'package:droog/data/constants.dart';
import 'package:droog/models/enums.dart';
import 'package:droog/models/user.dart';
import 'package:droog/screens/user_profile.dart';
import 'package:droog/services/database_methods.dart';
import 'package:droog/utils/theme_data.dart';
import 'package:droog/widgets/search_textfield.dart';
import 'package:droog/widgets/search_tile.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';

DatabaseMethods _databaseMethods = DatabaseMethods();

class SearchScreen extends StatefulWidget {
  static final String route = "/search_screen";

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final DatabaseMethods _databaseMethods = DatabaseMethods();
  final TextEditingController searchController = TextEditingController();
  List<User> searchResults = [];
  final scaffoldKey = GlobalKey<ScaffoldState>();

  getSearchResults() async {
    searchResults = await _databaseMethods.searchUser(searchController.text);
    setState(() {});
  }

//  Widget _buildSearchTextField() {
//    return Row(
//      crossAxisAlignment: CrossAxisAlignment.center,
//      children: <Widget>[
//        Expanded(
//          child: Padding(
//            padding: const EdgeInsets.all(8.0),
//            child: SizedBox(
//              height: 35,
//              child: TextField(
//                maxLines: null,
//                controller: searchController,
//                style: TextStyle(color: Colors.black),
//                onChanged: (_) => getSearchResults(),
//                decoration: InputDecoration(
//                  hintText: "Search Users",
//                  hintStyle: TextStyle(color: Colors.white),
//                  contentPadding: EdgeInsets.only(
//                    left: 16,
//                  ),
//
////              focusedBorder: OutlineInputBorder(
////
////                borderSide: BorderSide(style: BorderStyle.solid),
////                borderRadius: BorderRadius.circular(20),
////              ),
//                  border: OutlineInputBorder(
//                    borderSide: BorderSide(style: BorderStyle.solid),
//                    borderRadius: BorderRadius.circular(20),
//                  ),
//                ),
//              ),
//            ),
//          ),
//        ),
//        Padding(
//          padding: const EdgeInsets.all(8.0),
//          child: Icon(Icons.search),
//        ),
//      ],
//    );
//  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SearchTextField(
                onTextChanged: getSearchResults,
                controller: searchController,
              ),
            ),
            searchResults.isNotEmpty
                ? Expanded(
                    child: ListView.builder(
                    itemCount: searchResults.length,
                    itemBuilder: (_, index) {
//                      searchResults[index].userName != Constants.userName
                      if (searchResults[index].userName != Constants.userName) {
                        return SearchTile(
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
                            child: Image.asset(
                              "assets/images/no_results.png",
                              width: double.infinity,
                            ),
                        ))),
          ],
        ),
      ),
    );
  }
}


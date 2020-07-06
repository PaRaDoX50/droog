import 'package:cached_network_image/cached_network_image.dart';
import 'package:droog/data/constants.dart';
import 'package:droog/models/enums.dart';
import 'package:droog/models/user.dart';
import 'package:droog/screens/chat_screen.dart';
import 'package:droog/screens/user_profile.dart';
import 'package:droog/services/database_methods.dart';
import 'package:droog/utils/theme_data.dart';
import 'package:droog/widgets/search_textfield.dart';
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
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            SearchTextField(
              onTextChanged: getSearchResults,
              controller: searchController,
            ),
            searchResults.isNotEmpty
                ? Expanded(
                    child: ListView.builder(
                    itemCount: searchResults.length,
                    itemBuilder: (_, index) {

                      if(searchResults[index].userName != Constants.userName) {
                        return SearchTile(
                          user: searchResults[index],
                        );
                      }
                      else{
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
                            )))),
          ],
        ),
      ),
    );
  }
}

class SearchTile extends StatefulWidget {
  final User user;

  SearchTile({this.user});

  @override
  _SearchTileState createState() => _SearchTileState();
}

class _SearchTileState extends State<SearchTile> {
  ConnectionStatus _connectionStatus;
  bool _showLoading = false;

  getAppropriateChild(String data) {
    return _showLoading
        ? SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              backgroundColor: Colors.white,
            ),
          )
        : FittedBox(
            child: Text(
            data,
            style: Theme.of(context).textTheme.button,
          ));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      child: Column(
        children: <Widget>[
          ListTile(
            onTap: () {
              Navigator.pushNamed(context, UserProfile.route,
                  arguments: widget.user);
            },
            leading: CircleAvatar(
              radius: 30,
              child: ClipOval(
                child: CachedNetworkImage(
                  imageUrl: widget.user.profilePictureUrl,
                ),
              ),
            ),
            title: Text("${widget.user.firstName} ${widget.user.lastName}",
                overflow: TextOverflow.ellipsis),
            subtitle: Text(
              widget.user.userName,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: RaisedButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(5))),
              child: FutureBuilder<String>(
                  future: _followButtonText,
                  builder: (context, snapshot) {
                    return snapshot.hasData
                        ? getAppropriateChild(snapshot.data)
                        : SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              backgroundColor: Colors.white,
                              strokeWidth: 2,
                            ));
                  }),
              color: MyThemeData.buttonColorBlue,
              textColor: Colors.white,
              onPressed: () {
                switch (_connectionStatus) {
                  case ConnectionStatus.requestNotSent:
                    _sendRequest();
                    break;
                  case ConnectionStatus.requestSent:
                    _cancelRequest();
                    break;
                  case ConnectionStatus.droogs:
                    _unFollow();
                    break;
                }
              },
            ),
          ),
          Divider(
            height: 1,
            color: Colors.grey,
          )
        ],
      ),
    );
  }

  Future<String> get _followButtonText async {
    _connectionStatus =
        await _databaseMethods.getConnectionStatus(targetUid: widget.user.uid);
    switch (_connectionStatus) {
      case ConnectionStatus.requestSent:
        return "Cancel Request";
      case ConnectionStatus.droogs:
        return "Disconnect";
      case ConnectionStatus.requestNotSent:
        return "Connect";
      default:
        return "";
    }
  }

  Future _sendRequest() async {
    print(widget.user.firstName);
    print(widget.user.uid.toString());
    setState(() {
      _showLoading = true;
    });
    await _databaseMethods.sendConnectionRequest(targetUid: widget.user.uid);

    setState(() {
      _showLoading = false;
    });
  }

  Future _cancelRequest() async {
    setState(() {
      _showLoading = true;
    });
    await _databaseMethods.cancelConnectionRequest(targetUid: widget.user.uid);
    print("Sed");
    setState(() {
      _showLoading = false;
    });
  }

  Future _unFollow() async {
    setState(() {
      _showLoading = true;
    });
    await _databaseMethods.disconnectFromUser(targetUid: widget.user.uid);
    print("Snd");
    setState(() {
      _showLoading = false;
    });
  }
}

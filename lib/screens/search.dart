import 'package:droog/models/user.dart';
import 'package:droog/screens/chat_screen.dart';
import 'package:droog/screens/user_profile.dart';
import 'package:droog/services/database_methods.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';

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
    setState(() {

    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(children: <Widget>[
          TextField(
            controller: searchController,
            onChanged: (_) => getSearchResults(),
          ),
          Expanded(child: ListView.builder(
            itemCount: searchResults.length,
            itemBuilder: (_, index) {
              return SearchTile(user: searchResults[index],);
            },))
        ],),
      ),
    );
  }
}

class SearchTile extends StatelessWidget {


  final User user;


  SearchTile({this.user});


  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: <Widget>[
          ListTile(
            onTap: () {
              Navigator.pushNamed(context, UserProfile.route, arguments: user);
            },
            leading: CircleAvatar(
              child: ClipOval(child: Image.network(
                user.profilePictureUrl, cacheWidth: 80, height: 80,),),
            ),
            title: Text("${user.firstName} ${user.lastName}",
                overflow: TextOverflow.ellipsis),
            subtitle: Text(user.userName, overflow: TextOverflow.ellipsis,),


          ),
          Divider(
            height: 1,
            color: Colors.grey,
          )
        ],
      ),
    );
  }
}


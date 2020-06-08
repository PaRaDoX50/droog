import 'package:droog/models/user.dart';
import 'package:droog/screens/chat_screen.dart';
import 'package:droog/services/database_methods.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  static final String route = "/search_screen";
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final DatabaseMethods _databaseMethods = DatabaseMethods();
  final TextEditingController searchController = TextEditingController();
   List<User> searchResults =[];

  getSearchResults()async {
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
            onChanged: (_)=>getSearchResults(),
          ),
          Expanded(child: ListView.builder(
            itemCount: searchResults.length,
            itemBuilder: (_,index){
            return SearchTile(userEmail: searchResults[index].userEmail,);
          },))
        ],),
      ),
    );
  }
}

class SearchTile extends StatelessWidget {


  final String userEmail;


  SearchTile({this.userEmail});

  final DatabaseMethods _databaseMethods = DatabaseMethods();




  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: <Widget>[
          ListTile(
            leading: CircleAvatar(
              child: Icon(Icons.account_circle),
            ),
            title: Text(userEmail, overflow: TextOverflow.ellipsis),

            trailing: RaisedButton(child: Text("Message"),
            onPressed: ()  {Navigator.pushNamed(context, ChatScreen.route,arguments: userEmail);},),
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


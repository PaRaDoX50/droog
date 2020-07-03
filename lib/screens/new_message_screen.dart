import 'package:cached_network_image/cached_network_image.dart';
import 'package:droog/models/user.dart';
import 'package:droog/screens/chat_screen.dart';
import 'package:droog/services/database_methods.dart';
import 'package:droog/widgets/search_textfield.dart';
import 'package:flutter/material.dart';

class NewMessageScreen extends StatefulWidget {
  static final String route = "/new_message_screen";
  @override
  _NewMessageScreenState createState() => _NewMessageScreenState();
}

class _NewMessageScreenState extends State<NewMessageScreen> {
  List<User> searchResults = [];
  TextEditingController searchController = TextEditingController();
  DatabaseMethods _databaseMethods = DatabaseMethods();

  getSearchResults() async {
    searchResults = await _databaseMethods.searchUserForANewMessage(keyword: searchController.text);
    setState(() {

    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(children: <Widget>[
        SearchTextField(controller: searchController,onTextChanged: getSearchResults,),
        Expanded(child: ListView.builder(
            itemCount: searchResults.length,
            itemBuilder: (_, index) {
          return NewMessageTile(user: searchResults[index],);
        }),)
      ],),
    );
  }
}

class NewMessageTile extends StatelessWidget {
  final User user;

  NewMessageTile({this.user});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushReplacementNamed(
            ChatScreen.route, arguments: user);
      },
      child: ListTile(
        leading: CircleAvatar(child: ClipOval(
          child: CachedNetworkImage(imageUrl: user.profilePictureUrl,),),),
        title: Text(user.userName),
        subtitle: Text(
            user.fullName),),
    );
  }
}


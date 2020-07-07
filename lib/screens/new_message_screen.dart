import 'package:cached_network_image/cached_network_image.dart';
import 'package:droog/data/constants.dart';
import 'package:droog/models/user.dart';
import 'package:droog/screens/chat_screen.dart';
import 'package:droog/services/database_methods.dart';
import 'package:droog/widgets/search_textfield.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
    searchResults = await _databaseMethods.searchUserForANewMessage(
        keyword: searchController.text);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
          iconTheme: IconThemeData(color: Theme.of(context).primaryColor),
          elevation: 5,
          backgroundColor: Color(0xfffcfcfd),
          title: Text(
            "New Message",
            style:
                GoogleFonts.montserrat(color: Theme.of(context).primaryColor),
          )),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SearchTextField(
              controller: searchController,
              onTextChanged: getSearchResults,
            ),
          ),
          searchResults.isNotEmpty ?
          Expanded(
            child: ListView.builder(
                itemCount: searchResults.length,
                itemBuilder: (_, index) {

                  if(searchResults[index].userName != Constants.userName) {
                    return NewMessageTile(
                      user: searchResults[index],
                    );
                  }
                  else{
                    return Container();
                  }
                })
          ):
          Expanded(
              child: Center(
                  child: AspectRatio(
                      aspectRatio: 1,
                      child: Image.asset(
                        "assets/images/no_results.png",
                        width: double.infinity,
                      )))),
        ],
      ),
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
        Navigator.of(context)
            .pushReplacementNamed(ChatScreen.route, arguments: user);
      },
      child: ListTile(
        leading: CircleAvatar(
          child: ClipOval(
            child: CachedNetworkImage(
              imageUrl: user.profilePictureUrl,
            ),
          ),
        ),
        title: Text(user.userName),
        subtitle: Text(user.fullName),
      ),
    );
  }
}

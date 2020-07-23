import 'package:cached_network_image/cached_network_image.dart';
import 'package:droog/data/constants.dart';
import 'package:droog/models/user.dart';
import 'package:droog/screens/chat_screen.dart';
import 'package:droog/services/database_methods.dart';
import 'package:droog/utils/theme_data.dart';
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
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _showLoading = false;

  getSearchResults() async {
    if(searchController.text.trim() != "") {
      searchResults =
      await _databaseMethods.searchYourDroogs(keyword: searchController.text);
    }
    else{
      searchResults = await _databaseMethods.getListOfYourDroogs();
    }

    setState(() {});
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadInitialData();
  }

  Future<bool> loadInitialData() async {
    try {
      setState(() {
        _showLoading = true;
      });
      print(Constants.uid + "tryyy");
      searchResults = await _databaseMethods.getListOfYourDroogs();

      setState(() {
        _showLoading = false;
      });
      return true;
    } catch (e) {
      setState(() {
        _showLoading = false;
      });
      print(e.toString() + "adsaasd");

      _scaffoldKey.currentState.showSnackBar(
          (MyThemeData.getSnackBar(text: "Something went wrong.")));

      return false;
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      appBar: AppBar(
          iconTheme: IconThemeData(color: Theme.of(context).primaryColor),
          elevation: 5,
          backgroundColor: Color(0xfffcfcfd),
          title: Text(
            "New Message",
            style: TextStyle(color: Theme.of(context).primaryColor),
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
          Expanded(
            child: AnimatedSwitcher(
              duration: Duration(milliseconds: 300),
              child: _showLoading
                  ?  Center(
                        child: CircularProgressIndicator(),
                      )

                  : (searchResults.isNotEmpty
                      ?  ListView.builder(
                              itemCount: searchResults.length,
                              itemBuilder: (_, index) {
                                if (searchResults[index].userName !=
                                    Constants.userName) {
                                  return NewMessageTile(
                                    user: searchResults[index],
                                  );
                                } else {
                                  return Container();
                                }
                              })
                      : Center(
                            child: AspectRatio(
                              aspectRatio: 1,
                              child: Image.asset(
                                "assets/images/no_results.png",
                                width: double.infinity,
                              ),

                          ),
                        )),
            ),
          ),
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

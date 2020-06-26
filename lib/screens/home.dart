import 'dart:io';

import 'package:droog/data/constants.dart';
import 'package:droog/screens/chat_list.dart';
import 'package:droog/screens/feed.dart';
import 'package:droog/screens/new_post.dart';
import 'package:droog/screens/notifications_screen.dart';
import 'package:droog/screens/search.dart';
import 'package:droog/utils/theme_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Home extends StatefulWidget {
  static final String route = "/home";

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Future _profilePicturePath;

  List<Widget> widgets = [
    Feed(),
    SearchScreen(),
    NewPost(),
    ChatList(),
    NotificationsScreen(),
  ];
  int _currentIndex = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getProfilePicturePath();
  }

  _getProfilePicturePath() {
    _profilePicturePath = Constants.getProfilePicturePath();
  }

  void onTabTapped(int newIndex) {
    setState(() {
      _currentIndex = newIndex;
    });
  }

  Widget _createDrawerHeader() {
    final totalHeight = MediaQuery.of(context).size.height;
    return Padding(
      padding: EdgeInsets.zero,
      child: Container(
        child: Center(
          child: ListTile(
            leading: ClipOval(
              child: FutureBuilder(
                  future: _profilePicturePath,
                  builder: (context, snapshot) {
                    return Image.file(
                      File(snapshot.hasData ? snapshot.data : " "),
                      errorBuilder: (x, y, z) => Icon(Icons.error_outline),
                    );
                  }),
            ),
            title: Text(
              Constants.fullName,
              style: MyThemeData.whiteBold14,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Icon(Icons.edit,color: Colors.white,),
          ),
        ),
        height: totalHeight * .2,
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          gradient: LinearGradient(
            colors: [
              Color(0xff1948a0),
              Color(0xff4481bc),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
      ),
    );
  }

  Widget _createDrawerItem(IconData icon, Text title) {
    return Padding(
      padding: const EdgeInsets.all(0.0),
      child: ListTile(
        leading: Icon(icon),
        title: title,
        onTap: (){Navigator.pop(context);},
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      drawer: Drawer(
        child: ListView(
            padding:EdgeInsets.zero ,
            children: <Widget>[
              _createDrawerHeader(),
              _createDrawerItem(Icons.home, Text("Home")),
              Divider(
                thickness: .5,
              ),
              _createDrawerItem(Icons.home, Text("Home")),
              Divider(
                thickness: .5,
              ),
              _createDrawerItem(Icons.home, Text("Home")),
              Divider(
                thickness: .5,
              ),
            ],
          ),

      ),
      body: IndexedStack(children: widgets,index: _currentIndex,),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        unselectedItemColor: Colors.grey,
        onTap: onTabTapped,
        currentIndex: _currentIndex,
        selectedItemColor: Theme.of(context).primaryColor,
        items: [
          BottomNavigationBarItem(

            title: Text(
              "Feed",
              style: MyThemeData.blackBold12,
            ),
            icon: Icon(Icons.home),

          ),
          BottomNavigationBarItem(
            title: Text(
              "Search",
              style: MyThemeData.blackBold12,
            ),
            icon: Icon(Icons.search),
          ),
          BottomNavigationBarItem(
            title: Text(
              "Post",
              style: MyThemeData.blackBold12,
            ),
            icon: Icon(Icons.add),
          ),
          BottomNavigationBarItem(
            title: Text(
              "Messages",
              style: MyThemeData.blackBold12,
            ),
            icon: Icon(Icons.message),
          ),
          BottomNavigationBarItem(
            title: Text(
              "Alert",
              style: MyThemeData.blackBold12,
            ),
            icon: Icon(Icons.add_alert),
          ),
        ],
      ),
    );
  }
}

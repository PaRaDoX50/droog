import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:droog/data/constants.dart';
import 'package:droog/models/enums.dart';
import 'package:droog/models/user.dart';
import 'package:droog/screens/chat_list.dart';
import 'package:droog/screens/feed.dart';
import 'package:droog/screens/feedback.dart';
import 'package:droog/screens/myclips_screen.dart';
import 'package:droog/screens/new_post.dart';
import 'package:droog/screens/notifications_screen.dart';
import 'package:droog/screens/profile_setup.dart';
import 'package:droog/screens/search.dart';
import 'package:droog/screens/signup.dart';
import 'package:droog/screens/skills_setup.dart';
import 'package:droog/screens/user_profile.dart';
import 'package:droog/services/auth.dart';
import 'package:droog/services/database_methods.dart';
import 'package:droog/utils/theme_data.dart';
import 'package:droog/widgets/animated_indexed_stack.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

class Home extends StatefulWidget {
  static final String route = "/home";

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  AuthService _authService = AuthService();
//  Future _profilePicturePath;
  String appBarTitle = "Feed";
  final _scaffoldKey = GlobalKey<ScaffoldState>();
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
//    _getProfilePicturePath();
  }

//  _getProfilePicturePath() {
//    _profilePicturePath = Constants.getProfilePicturePath();
//  }

  String _getAppBarTitle() {
    switch (_currentIndex) {
      case 0:
        return "Feed";
      case 1:
        return "Discover";
      case 2:
        return "Post";
      case 3:
        return "Messages";
      case 4:
        return "Notifications";
    }
  }

  void onTabTapped(int newIndex) {
    FocusScope.of(context).unfocus();
    setState(() {
      _currentIndex = newIndex;
    });
  }

  Widget _createDrawerHeader() {

    final totalHeight = MediaQuery.of(context).size.height;
    return  Padding(
        padding: EdgeInsets.zero,
        child: Container(
          child: Center(
            child: ListTile(
              onTap: ()async{
                DatabaseMethods databaseMethods = DatabaseMethods();
                User user = await databaseMethods.getUserDetailsByUid(targetUid: Constants.uid);
                Navigator.pushNamed(context, UserProfile.route,arguments:user);},
              leading: ClipOval(
                  child: CachedNetworkImage(
                imageUrl: Constants.profilePictureUrl,
              )),
              title: Text(
                Constants.fullName,
                style: MyThemeData.whiteBold14,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                Constants.userName,
                style: MyThemeData.whiteBold14,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: GestureDetector(
                onTap: () => Navigator.of(context).pushNamed(ProfileSetup.route,
                    arguments: RoutedProfileSetupFor.edit),
                child: Icon(
                  Icons.edit,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          height: totalHeight * .2,
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            gradient: LinearGradient(
              colors: [
                Theme.of(context).primaryColor,
//              Color(0xff1948a0),
//              Color(0xff4481bc),
                Colors.blue
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      );
  }
  Widget _logoutItem(){
    return  Padding(
      padding: const EdgeInsets.all(0.0),
      child: ListTile(
        leading: FaIcon(FontAwesomeIcons.doorOpen),
        title: SizedBox(child: Text("Logout")),
        onTap: () {
          try{
            _authService.logout();
            Navigator.pushNamedAndRemoveUntil(context, SignUp.route, (route) => false);
          }
          catch(e){
            _scaffoldKey.currentState.showSnackBar(MyThemeData.getSnackBar(text: "Something went wrong"));
            print(e.message);
          }


        },
      ),
    );
  }
  Widget _createDrawerItem(IconData icon, Text title, String route) {
    return Padding(
      padding: const EdgeInsets.all(0.0),
      child: ListTile(
        leading: FaIcon(icon),
        title: SizedBox(child: title),
        onTap: () {
          Navigator.pop(context);
          if (route != Home.route) {
            Navigator.pushNamed(context, route);
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    print(_currentIndex.toString() + "asdasd");
//setState(() {
//  _currentIndex = _currentIndex;
//});
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Theme.of(context).primaryColor),
        elevation: 5,
        backgroundColor:Color(0xfffcfcfd),
        title: Text(
          _getAppBarTitle(),
          style: GoogleFonts.lato(color: Theme.of(context).primaryColor),
        ),

      ),
      drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.all(0),
            children: <Widget>[
              _createDrawerHeader(),
              _createDrawerItem(Icons.home, Text("Home"), Home.route),
              Divider(
                thickness: .5,
              ),
              _createDrawerItem(
                  Icons.content_paste, Text("My Clips"), MyClipsScreen.route),
              Divider(
                thickness: .5,
              ),
              _createDrawerItem(
                  FontAwesomeIcons.medal, Text("Skills and Achievements"), SkillsSetup.route),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal:16.0,vertical: 8),
                child: Text("More",style: MyThemeData.blackBold12,),
              ),
              _logoutItem(),
              Divider(
                thickness: .5,
              ),
              _createDrawerItem(
                  FontAwesomeIcons.handsHelping, Text("Share feedback"), FeedbackScreen.route),
            ],
          ),

      ),
      body: GestureDetector(
        onHorizontalDragStart: (_)=>FocusScope.of(context).unfocus(),
        onTap: ()=>FocusScope.of(context).unfocus(),
        child: FadeIndexedStack(
          duration: Duration(milliseconds: 390),
          children: widgets,
          index: _currentIndex,
        ),
      ),
      bottomNavigationBar:  ConvexAppBar(

          onTap: onTabTapped,
          initialActiveIndex: _currentIndex,
          backgroundColor: Color(0xfffcfcfd),
          style: TabStyle.fixedCircle,
          color: Theme.of(context).primaryColor,
          activeColor: Theme.of(context).primaryColor,
          items: [
            TabItem(
              activeIcon: Icon(
                Icons.home,
                color: Theme.of(context).primaryColor,
              ),
              icon: Icon(
                Icons.home,
                color: Colors.grey,
              ),
            ),
            TabItem(
                icon: Icon(
                  Icons.search,
                  color: Colors.grey,
                ),
                activeIcon: Icon(
                  Icons.search,
                  color: Theme.of(context).primaryColor,
                )),
            TabItem(
              icon: Icon(
                Icons.add,
                color: Colors.white,
              ),
            ),
            TabItem(
                icon: Icon(
                  Icons.chat_bubble_outline,
                  color: Colors.grey,
                ),
                activeIcon: Icon(
                  Icons.chat_bubble_outline,
                  color: Theme.of(context).primaryColor,
                )),
            TabItem(
                icon:FaIcon(FontAwesomeIcons.bell,color: Colors.grey,),
                activeIcon:FaIcon(FontAwesomeIcons.bell,color: Theme.of(context).primaryColor,)),
          ],
        ),

    );
  }
}

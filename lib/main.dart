import 'package:droog/models/enums.dart';
import 'package:droog/screens/chat_list.dart';
import 'package:droog/screens/chat_screen.dart';
import 'package:droog/screens/feed.dart';
import 'package:droog/screens/image_message_screen.dart';
import 'package:droog/screens/myclips_screen.dart';
import 'package:droog/screens/new_message_screen.dart';
import 'package:droog/screens/new_response_screen.dart';
import 'package:droog/screens/responses_screen.dart';
import 'package:droog/screens/share_screen.dart';
import 'package:droog/screens/skills_setup.dart';
import 'package:droog/screens/user_profile.dart';

import 'package:droog/screens/home.dart';
import 'package:droog/screens/introduction_screen.dart';
import 'package:droog/screens/mobile_verification.dart';
import 'package:droog/screens/new_post.dart';
import 'package:droog/screens/otp_screen.dart';
import 'package:droog/screens/profile_setup.dart';
import 'package:droog/screens/search.dart';
import 'package:droog/screens/signup.dart';
import 'package:droog/services/sharedprefs_methods.dart';
import 'package:droog/widgets/profile_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  // This widget is the root of your application.

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  SharedPrefsMethods _sharedPrefsMethods = SharedPrefsMethods();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.dark.copyWith(statusBarColor: Colors.transparent),
    );

    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
          primaryColor: Color(0xff1948a0),
          buttonColor: Color(0xff2d80d7),
          textTheme: ThemeData.light().textTheme.copyWith(
              button: TextStyle(color: Colors.white),
              headline6: TextStyle(
                  fontSize: 20,
                  color: Colors.black,
                  fontWeight: FontWeight.w600))),
      home: FutureBuilder(
        future: _sharedPrefsMethods.getLoggedInStatusAndBuildConstants(),
        builder: (_, snapshot) {
          if (snapshot.hasData) {
            print(snapshot.data);
            if(snapshot.data == LoggedInStatus.loggedIn.index){
              return Home();
            }
            else if(snapshot.data == LoggedInStatus.halfProfileLeft.index){
              return ProfileSetup();
            }
            return IntroductionScreen();

          }
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        },
      ),
      routes: {
        Home.route: (_) => Home(),
        SignUp.route: (_) => SignUp(),
        OTPscreen.route: (_) => OTPscreen(),
        MobileVerification.route: (_) => MobileVerification(),
        ChatList.route: (_) => ChatList(),
        SearchScreen.route: (_) => SearchScreen(),
        ChatScreen.route: (_) => ChatScreen(),
        NewPost.route: (_) => NewPost(),
        UserProfile.route: (_) => UserProfile(),
        ProfileSetup.route: (_) => ProfileSetup(),
        ResponseScreen.route:(_) => ResponseScreen(),
        NewResponse.route:(_) => NewResponse(),
        ImageMessageScreen.route:(_) => ImageMessageScreen(),
        ShareScreen.route:(_) => ShareScreen(),
        NewMessageScreen.route:(_) => NewMessageScreen(),
        MyClipsScreen.route:(_)=> MyClipsScreen(),
        SkillsSetup.route:(_)=>SkillsSetup(),
      },
    );
  }
}

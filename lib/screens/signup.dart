import 'package:droog/models/enums.dart';
import 'package:droog/models/user.dart';
import 'package:droog/screens/home.dart';
import 'package:droog/screens/mobile_verification.dart';
import 'package:droog/screens/profile_setup.dart';
import 'package:droog/services/auth.dart';
import 'package:droog/services/database_methods.dart';
import 'package:droog/services/sharedprefs_methods.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignUp extends StatelessWidget {
  static final String route = "/sign_up";
  AuthService _authService = AuthService();
  DatabaseMethods _databaseMethods = DatabaseMethods();
  SharedPrefsMethods _sharedPrefsMethods = SharedPrefsMethods();

  @override
  Widget build(BuildContext context) {
    final availableHeight = MediaQuery.of(context).size.height -
        MediaQuery.of(context).padding.vertical;

    final googleSigninButton = ButtonTheme(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: RaisedButton(
          color: Color(0xff4688f1),
          child: Container(
            width: double.infinity,
            height: availableHeight * .05,
            child: Row(
              children: <Widget>[
                Image.asset(
                  "assets/images/facebook_icon.png",
                  height: 20,
                  width: 20,
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      "Sign In with Google",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
          onPressed: () async {
            dynamic user = await _authService.googleSignIn();
            if (user == null) {
              print("Something went wrong");
            } else {
              final firebaseUser = user as FirebaseUser;
              print(firebaseUser.phoneNumber);
              if (firebaseUser.phoneNumber == null) {
                Navigator.pushReplacementNamed(
                    context, MobileVerification.route);
              } else {
                User user = await _databaseMethods.getUserDetailsByUid(targetUid: firebaseUser.uid);
                if (user.firstName != null) {
                  await _sharedPrefsMethods.saveCompleteUserDetails(
                      userEmail: firebaseUser.email,
                      userPhone: firebaseUser.phoneNumber,
                      uid: firebaseUser.uid,

                      loggedInStatus: LoggedInStatus.loggedIn,user: user);
                  //building constants
                  Navigator.pushReplacementNamed(context, Home.route);
                }
                else{
                  await _sharedPrefsMethods.saveUserDetails(
                    userEmail: firebaseUser.email,
                    userPhone: firebaseUser.phoneNumber,
                    uid: firebaseUser.uid,
                    loggedInStatus: LoggedInStatus.halfProfileLeft,);
                  //building constants
                  Navigator.pushReplacementNamed(context, ProfileSetup.route,arguments: RoutedProfileSetupFor.setup);
                }
              }
            }
          },
        ),
      ),
    );

    final facebookSigninButton = ButtonTheme(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: RaisedButton(
          color: Color(0xff3b5998),
          child: SizedBox(
            width: double.infinity,
            height: availableHeight * .05,
            child: Row(
              children: <Widget>[
                Image.asset(
                  "assets/images/facebook_icon.png",
                  height: 20,
                  width: 20,
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      "Sign In with Facebook",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
          onPressed: () async {
            dynamic user = await _authService.facebookSignIn();
            if (user == null) {
              print("Something went wrong");
            } else {
              final firebaseUser = user as FirebaseUser;
              print(firebaseUser.phoneNumber);
              if (firebaseUser.phoneNumber == null) {
                Navigator.pushReplacementNamed(
                    context, MobileVerification.route);
              } else {
                User user = await _databaseMethods.getUserDetailsByUid(targetUid: firebaseUser.uid);
                if (user.firstName != null) {
                  await _sharedPrefsMethods.saveCompleteUserDetails(
                      userEmail: firebaseUser.email,
                      userPhone: firebaseUser.phoneNumber,
                      uid: firebaseUser.uid,
                      loggedInStatus: LoggedInStatus.loggedIn,user: user);
                  //building constants
                  Navigator.pushReplacementNamed(context, Home.route);
                }
                else{
                  await _sharedPrefsMethods.saveUserDetails(
                    userEmail: firebaseUser.email,
                    userPhone: firebaseUser.phoneNumber,
                    uid: firebaseUser.uid,
                    loggedInStatus: LoggedInStatus.halfProfileLeft,);
                  //building constants
                  Navigator.pushReplacementNamed(context, ProfileSetup.route);
                }
              }
            }
          },
        ),
      ),
    );

    final dividerOR = Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        SizedBox(
          width: MediaQuery.of(context).size.width * .39,
          child: Divider(
            color: Colors.grey,
          ),
        ),
        Text(
          "OR",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width * .39,
          child: Divider(
            color: Colors.grey,
          ),
        ),
      ],
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Image.asset("assets/images/signup.png", width: double.infinity),
          googleSigninButton,
          facebookSigninButton,
        ],
      ),
    );
  }
}

//class SignUpForm extends StatefulWidget {
//  @override
//  _SignUpFormState createState() => _SignUpFormState();
//}
//
//class _SignUpFormState extends State<SignUpForm> {
//  TextEditingController emailController = TextEditingController();
//  TextEditingController passwordController = TextEditingController();
//  AuthService _authService = AuthService();
//
//  final _formKey = GlobalKey<FormState>();
//
//  @override
//  Widget build(BuildContext context) {
//    final availableHeight = MediaQuery.of(context).size.height -
//        MediaQuery.of(context).padding.vertical;
//
//
//    final emailField = Padding(
//        padding: EdgeInsets.all(8),
//        child: TextFormField(
//          controller: emailController,
//          validator: (value) {
//            if (EmailValidator.validate(value)) {
//              return null;
//            }
//            return "Enter valid Email";
//          },
//          decoration: InputDecoration(
//
//              prefixIcon: Icon(Icons.email),
//              hintText: "Email",
//              border:
//                  OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
//              contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 8)),
//        ));
//
//    final passwordField = Padding(
//
//      padding: EdgeInsets.all(8),
//      child: TextFormField(
//        controller: passwordController,
//        decoration: InputDecoration(
//            prefixIcon: Icon(Icons.vpn_key),
//            hintText: "Password",
//            border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
//            contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 8)),
//      ),
//    );
//
//    final signUpButton = ButtonTheme(
//      shape: RoundedRectangleBorder(
//        borderRadius: BorderRadius.circular(10),
//      ),
//      child: Padding(
//        padding: const EdgeInsets.all(16.0),
//        child: Container(
//            height: availableHeight * .06,
//            width: double.infinity,
//            child: RaisedButton(
//              color: Color(0xffdf1d38),
//              child: Text(
//                "Sign Up",
//                style: TextStyle(
//                  color: Colors.white,
//                ),
//              ),
//              onPressed: () async {
//                if (_formKey.currentState.validate()) {
//
//                   try {
//                     dynamic user = await _authService.emailSignUp(emailController.text, passwordController.text);
//                   }  catch (e) {
//                     print(e.toString()+"ASDasdasda");
//                   }
//
//
//                }
//              },
//            )),
//      ),
//    );
//
//    return Form(
//      key: _formKey,
//      child: Column(
//        crossAxisAlignment: CrossAxisAlignment.start,
//        children: <Widget>[
//          Padding(
//            padding: const EdgeInsets.only(left: 8.0),
//            child: Text("Sign Up"),
//          ),
//          emailField,
//          passwordField,
//          signUpButton,
//        ],
//      ),
//    );
//  }
//}

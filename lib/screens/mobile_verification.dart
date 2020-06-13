import 'package:droog/models/enums.dart';
import 'package:droog/screens/otp_screen.dart';
import 'package:droog/screens/search.dart';
import 'package:droog/services/database_methods.dart';
import 'package:droog/services/sharedprefs_methods.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MobileVerification extends StatefulWidget {
  static final String route = "/mobile_verification";

  @override
  _MobileVerificationState createState() => _MobileVerificationState();
}

class _MobileVerificationState extends State<MobileVerification> {
  final TextEditingController mobileController = TextEditingController();

  bool showLoading = false;

  void codeSentFunc(String codeSent, BuildContext context) {
    Navigator.pushReplacementNamed(context, OTPscreen.route,
        arguments: {"no": mobileController.text, "code": codeSent});
  }

  Future<void> mobileSignIn(String phoneNo, BuildContext context) async {
    FirebaseAuth _auth = FirebaseAuth.instance;
    DatabaseMethods _databaseMethods = DatabaseMethods();
    SharedPrefsMethods _sharedPrefsMethods = SharedPrefsMethods();

    final vF = (AuthException exception) {
      print("helloooo");
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text("Something went wrong"),
      ));
    };

    final vC = (AuthCredential credential) async {
      try {
        FirebaseUser user = await _auth.currentUser();
        await user.updatePhoneNumberCredential(credential);
        user = await _auth.currentUser();
        await _sharedPrefsMethods.saveUserDetails(
            userEmail: user.email,
            userPhone: user.phoneNumber,
            uid: user.uid,
            isLoggedIn: LoggedInStatus.halfProfileLeft);
        //consta
        await _databaseMethods.createHalfUserProfile(
            userEmail: user.email, mobileNo: user.phoneNumber, uid: user.uid);

        Navigator.pushReplacementNamed(context, SearchScreen.route);
      } catch (e) {
        Scaffold.of(context).showSnackBar(SnackBar(
          content: Text("Something went wrong"),
        ));
      }
    };
    final cS = (codeSent, [forceResend]) {
      print(codeSent);
      codeSentFunc(codeSent, context);
    };
    final cART = (codeSent) {
      print("autoretrieval");
      codeSentFunc(codeSent, context);
    };

    await _auth.verifyPhoneNumber(
        phoneNumber: "+91" + phoneNo,
        timeout: Duration(milliseconds: 30000),
        verificationCompleted: vC,
        verificationFailed: vF,
        codeSent: cS,
        codeAutoRetrievalTimeout: cART);
  }

  @override
  Widget build(BuildContext context) {
    final mobileField = TextField(
      style: TextStyle(fontSize: 35),
      controller: mobileController,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        prefixIcon: Container(
          width: MediaQuery.of(context).size.width * .23,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "+91 |",
              style: TextStyle(fontSize: 35),
            ),
          ),
        ),
      ),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: <Widget>[
          SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 16,
                  left: 16,
                  right: 16),
              child: Column(
                children: <Widget>[
                  Image.asset("assets/images/droog_pattern.png"),
                  SizedBox(
                    height: 16,
                  ),
                  Text(
                    "Enter Mobile Number",
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.w400),
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  Text(
                    "SMS verification code will be sent",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  mobileField,
                  SizedBox(
                    height: 16,
                  ),
                  Text("By clicking continue you are accepting to droog's",
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w400)),
                  Text("Terms and Conditions",
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: Color(0xffdf1d38))),
                  SizedBox(
                    height: 16,
                  ),
                  Builder(
                    builder: (ctx) {
                      return ButtonTheme(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Container(
                          height: 29,
                          width: MediaQuery.of(context).size.width * .6,
                          child: RaisedButton(
                            child: Text(
                              "Continue",
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                            color: Color(0xffdf1d38),
                            onPressed: () async {
                              setState(() {
                                showLoading = true;
                              });

                              try {
                                await mobileSignIn(mobileController.text, ctx);

                              } catch (e) {
                                setState(() {
                                  showLoading = false;
                                });
                                print("errooooooooorr" + e.toString());
                              }
                            },
                          ),
                        ),
                      );
                    },
                  ),
                  Image.asset("assets/images/mobile_verification.png"),
                ],
              ),
            ),
          ),
          showLoading == true ? Center(child: CircularProgressIndicator()) : Container()
        ],
      ),
    );
  }
}

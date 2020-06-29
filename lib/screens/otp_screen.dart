import 'package:droog/models/enums.dart';
import 'package:droog/screens/home.dart';
import 'package:droog/screens/mobile_verification.dart';
import 'package:droog/screens/search.dart';
import 'package:droog/services/database_methods.dart';
import 'package:droog/services/sharedprefs_methods.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class OTPscreen extends StatefulWidget {
  static final String route = "/otp_screen";
  String number;
  String code;
  OTPscreen({@required this.code,@required this.number});

  @override
  _OTPscreenState createState() => _OTPscreenState();
}

class _OTPscreenState extends State<OTPscreen> {
  TextEditingController codeController = TextEditingController();
  DatabaseMethods _databaseMethods = DatabaseMethods();
  SharedPrefsMethods _sharedPrefsMethods = SharedPrefsMethods();
  bool showLoading = true;

  Future phoneVerification(AuthCredential credential, BuildContext ctx) async {
    try {
      print("vC OTP");
      FirebaseAuth _auth = FirebaseAuth.instance;
      FirebaseUser user = await _auth.currentUser();

      await user.updatePhoneNumberCredential(credential);
      user = await _auth.currentUser();
      await _sharedPrefsMethods.saveUserDetails(
          userEmail: user.email,
          userPhone: user.phoneNumber,
          uid: user.uid,
          loggedInStatus: LoggedInStatus.halfProfileLeft);

      await _databaseMethods.createHalfUserProfile(
          userEmail: user.email, mobileNo: user.phoneNumber, uid: user.uid);
      Navigator.pushReplacementNamed(context, SearchScreen.route);
      print("doneeeeeee");
    } catch (e) {
      setState(() {
        showLoading = false;
      });
      print(e.message + "vcOTPERROR");
    }
  }

  void compareOTP(String sentCode, String enteredCode, BuildContext ctx) {
    print(sentCode);
    print(enteredCode);

    AuthCredential authCredential = PhoneAuthProvider.getCredential(
        verificationId: sentCode, smsCode: enteredCode);
    print(authCredential.toString() + "helllll");
    phoneVerification(authCredential, ctx);
  }

  @override
  Widget build(BuildContext context) {
//    final argument =
//        ModalRoute.of(context).settings.arguments as Map<dynamic, dynamic>;
    return Scaffold(
      backgroundColor: Colors.white,
      body: StreamBuilder<FirebaseUser>(
        stream: FirebaseAuth.instance.onAuthStateChanged,
        builder: (context, snapshot) {
          if(snapshot.hasData){
            if(snapshot.data.phoneNumber != null){

              Navigator.pushReplacementNamed(context, Home.route);
            }
          }

          return SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Column(
                  children: <Widget>[
                    Image.asset("assets/images/droog_pattern.png"),
                    SizedBox(
                      height: 32,
                    ),
                    Text(
                      "Enter confirmation code",
                      style: TextStyle(fontSize: 25),
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    Text(
                      "Enter the code to verify your number",
                      style: TextStyle(fontSize: 15),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          widget.number,
                          style: TextStyle(fontSize: 15),
                        ),
                        SizedBox(
                          width: 8,
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pushReplacementNamed(
                              context, MobileVerification.route),
                          child: Text(
                            "Change",
                            style:
                                TextStyle(fontSize: 15, color: Color(0xffdf1d38)),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    Container(
                        width: MediaQuery.of(context).size.width * .7,
                        child: PinCodeTextField(
                          controller: codeController,
                          length: 6,
                          textInputType: TextInputType.number,
                        )),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: <Widget>[
                      Text(
                        "Resend OTP",
                        style: TextStyle(
                          color: Color(0xffdf1d38),
                          fontSize: 15,
                        ),
                      ),
                      SizedBox(
                        height: 16,
                      ),
                      Builder(builder: (ctx) {
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
                                compareOTP(
                                    widget.code, codeController.text, ctx);
                              },
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
          );
        }
      ),
    );
  }
}

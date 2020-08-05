import 'package:droog/models/enums.dart';
import 'package:droog/screens/otp_screen.dart';
import 'package:droog/screens/profile_setup.dart';
import 'package:droog/services/database_methods.dart';
import 'package:droog/services/sharedprefs_methods.dart';
import 'package:droog/utils/theme_data.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:transparent_image/transparent_image.dart';

class MobileVerification extends StatefulWidget {
  static final String route = "/mobile_verification";

  @override
  _MobileVerificationState createState() => _MobileVerificationState();
}

class _MobileVerificationState extends State<MobileVerification> {
  final TextEditingController mobileController = TextEditingController();

  bool showLoading = false;
  bool isCodeSent = false;
  bool vCrunning = false;
  String verificationCode;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();

  void codeSentFunc(String codeSent) {
    setState(() {
      showLoading = false;
      isCodeSent = true;
      verificationCode = codeSent;
    });
  }

  Future<void> mobileSignIn(String phoneNo) async {
    FirebaseAuth _auth = FirebaseAuth.instance;
    DatabaseMethods _databaseMethods = DatabaseMethods();
    SharedPrefsMethods _sharedPrefsMethods = SharedPrefsMethods();

    final vF = (AuthException exception) {
      setState(() {
        showLoading = false;
      });
      print("vF" + exception.message);

      _scaffoldKey.currentState.showSnackBar(
          (MyThemeData.getSnackBar(text: "Something went wrong.")));
    };

    final vC = (AuthCredential credential) async {
      try {
        setState(() {
          vCrunning = true;
        });
        print("vC MobileVerification");
        FirebaseUser user = await _auth.currentUser();
        await user.updatePhoneNumberCredential(credential);
        user = await _auth.currentUser();
        await _sharedPrefsMethods.saveUserDetails(
            userEmail: user.email,
            userPhone: user.phoneNumber,
            uid: user.uid,
            loggedInStatus: LoggedInStatus.halfProfileLeft);
        //consta
        await _databaseMethods.createHalfUserProfile(
            userEmail: user.email, mobileNo: user.phoneNumber, uid: user.uid);
        setState(() {
          vCrunning = false;
        });
        Navigator.pushReplacementNamed(context, ProfileSetup.route,
            arguments: RoutedProfileSetupFor.setup);
      } catch (e) {
        setState(() {
          vCrunning = false;
        });
        _scaffoldKey.currentState.showSnackBar(
            (MyThemeData.getSnackBar(text: "Something went wrong.")));
      }
    };
    final cS = (codeSent, [forceResend]) {
      print("cS");
      print(codeSent);

      codeSentFunc(codeSent);
    };
    final cART = (codeSent) {
      print("cART");
      print("autoretrieval");
      codeSentFunc(codeSent);
    };

    await _auth.verifyPhoneNumber(
        phoneNumber: "+91" + phoneNo,
        timeout: Duration(milliseconds: 60000),
        verificationCompleted: vC,
        verificationFailed: vF,
        codeSent: cS,
        codeAutoRetrievalTimeout: cART);
  }

  @override
  Widget build(BuildContext context) {
    final mobileField = Form(
        key: _formKey,
        child: TextFormField(
          validator: (string) {
            if (string.length == 10) {
              return null;
            }
            return "Enter a valid number";
          },
          style: TextStyle(fontSize: 35),
          controller: mobileController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            prefixIcon: Container(
              width: MediaQuery
                  .of(context)
                  .size
                  .width * .23,
              child: Align(
                alignment: Alignment.centerLeft,
                child: FittedBox(
                  child: Text(
                    "+91 | ",
                    style: TextStyle(fontSize: 35),
                  ),
                ),
              ),
            ),
          ),
        ));

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      body: isCodeSent == true
          ? IgnorePointer(
        ignoring: showLoading || vCrunning,
        child: Stack(
          children: <Widget>[
            OTPscreen(
              code: verificationCode,
              number: mobileController.text,
            ),
            showLoading || vCrunning
                ? Center(child: CircularProgressIndicator())
                : Container()
          ],
        ),
      )
          : Stack(
        children: <Widget>[
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.only(
                    top: MediaQuery
                        .of(context)
                        .padding
                        .top + 16,
                    left: 16,
                    right: 16),
                child: Column(mainAxisSize: MainAxisSize.min,

                  children: <Widget>[

//                  Image.asset("assets/images/droog_pattern.png"),
//                  SizedBox(
//                    height: 16,
//                  ),
                    FittedBox(
                      child: Text(
                        "Enter Mobile Number",
                        style: TextStyle(
                            fontSize: 28, fontWeight: FontWeight.w400),
                      ),
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    FittedBox(
                      child: Text(
                        "SMS verification code will be sent",
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w400),
                      ),
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    mobileField,
                    SizedBox(
                      height: 16,
                    ),
                    FittedBox(
                      child: Text(
                          "By clicking continue you are accepting to Droog's",
                          style: TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w400)),
                    ),
                    FittedBox(
                      child: Text("Terms and Conditions",
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                              color: Theme
                                  .of(context)
                                  .buttonColor)),
                    ),
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
                            width: MediaQuery
                                .of(context)
                                .size
                                .width * .6,
                            child: RaisedButton(
                              child: Text(
                                "Continue",
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                              color: Theme
                                  .of(context)
                                  .buttonColor,
                              onPressed: () async {
                                try {
                                  if (_formKey.currentState.validate()) {
                                    setState(() {
                                      showLoading = true;
                                    });
                                    await mobileSignIn(
                                        mobileController.text);
                                  }
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
                    SizedBox(
                      height: 16,
                    ),
                    FadeInImage(image: AssetImage(
                        "assets/images/mobile_verification.png"),placeholder: MemoryImage(kTransparentImage),)
//                    Image.asset("assets/images/mobile_verification.png"),
                  ],
                ),
              ),
            ),
          ),
          showLoading || vCrunning
              ? Center(child: CircularProgressIndicator())
              : Container()
        ],
      ),
    );
  }
}

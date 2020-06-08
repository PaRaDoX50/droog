import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  FirebaseAuth _auth = FirebaseAuth.instance;

  Future<dynamic> googleSignIn() async {
    GoogleSignIn _googleSignIn = GoogleSignIn();

    try {
      GoogleSignInAccount googleSignInAccount = await _googleSignIn.signIn();
      GoogleSignInAuthentication gSA = await googleSignInAccount.authentication;
      final AuthCredential credential = GoogleAuthProvider.getCredential(
          idToken: gSA.idToken, accessToken: gSA.accessToken);
      FirebaseUser user = (await _auth.signInWithCredential(credential)).user;

      return user;
    } catch (e) {
      print(e);
      return null;
    }
  }


  Future<dynamic> facebookSignIn() async {
    FacebookLogin _facebookLogin = FacebookLogin();

    try {
      FacebookLoginResult result = await _facebookLogin.logIn(['email','user_friends','public_profile']);
      switch (result.status) {
        case FacebookLoginStatus.error:
          print(result.errorMessage);
          print("error");
          break;
        case FacebookLoginStatus.loggedIn:
          final FacebookAccessToken accessToken = result.accessToken;
          AuthCredential credential = FacebookAuthProvider.getCredential(accessToken: accessToken.token);
          AuthResult authResult = await _auth.signInWithCredential(credential);
          return authResult.user;
          break;
        case FacebookLoginStatus.cancelledByUser:
          print("cancled");
          return null;
          break;

        default:
          print("default");
          break;
      }


      } catch (e) {
      print(e.toString()+"DSFsdfsdf");
      return null;
    }

  }

    Future phoneVerificationCompleted(AuthCredential credential) async {
    FirebaseUser user = await _auth.currentUser();
    await user.updatePhoneNumberCredential(credential);
    print("doneeeeeee");

    }

//  void phoneVerificationFailed(AuthException exception) {
//    print(exception.message + " Verificatio failed");
//  }

//  Future mobileSignIn(String phoneNo,) async {
//
//
//
//    _auth.verifyPhoneNumber(phoneNumber: phoneNo,
//        timeout: Duration(seconds: 30),
//        verificationCompleted: (credential){phoneVerificationCompleted(credential);},
//        verificationFailed:(exception){phoneVerificationFailed(exception);} ,
//        codeSent: null,
//        codeAutoRetrievalTimeout: null);
//
//  }
    void compareOTP(String sentCode,String enteredCode) {
    print(sentCode);
    print(enteredCode);
    AuthCredential authCredential = PhoneAuthProvider.getCredential(verificationId: sentCode, smsCode: enteredCode);
    print(authCredential.toString()+"helllll");
    phoneVerificationCompleted(authCredential);

    }


//  Future emailSignUp(String email, String password) async {
//   try {
//     AuthResult result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
//
//     return result.user;
//   } catch (e) {
//     print("Something went wrong"+ e.toString());
//     return Future.error(e.message);
//   }
//  }


  }

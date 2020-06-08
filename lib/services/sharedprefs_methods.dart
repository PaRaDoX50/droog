import 'package:droog/data/constants.dart';
import 'package:droog/models/enums.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsMethods {
  Future<void> saveUserDetails(
      {String userEmail,
      String userPhone,
      String uid,
      LoggedInStatus isLoggedIn}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("userEmail", userEmail);
    prefs.setString("uid", uid);
    prefs.setString("userPhone", userPhone);
    prefs.setInt("isLoggedIn", isLoggedIn.index);
    Constants.uid = uid;
    Constants.userEmail = userEmail;
    Constants.userPhoneNo = userPhone;
  }

  Future<void> saveUserName(
      {String userName, LoggedInStatus loggedInStatus}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("userName", userName);
    prefs.setInt("isLoggedIn", loggedInStatus.index);
  }

//  Future<void> saveUserName({String userName}) async {
//    SharedPreferences prefs = await SharedPreferences.getInstance();
//    prefs.setString("userName", userName);
//  }

  Future<String> getUserEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("userEmail");
  }

  Future<String> getUserPhone() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("userPhone");
  }

  Future<String> getUID() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("uid");
  }

  Future<String> getUserName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("userName");
  }

  Future<int> getLoggedInStatusAndBuildConstants() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    int status = prefs.getInt("isLoggedIn") ?? -1;
    print(status.toString()+"statttttusssss");
    if (LoggedInStatus.halfProfileLeft.index == status) {
      await buildHalfProfileConstants();
    } else if (LoggedInStatus.loggedIn.index == status) {
      await buildHalfProfileConstants();
      Constants.userName = await getUserName();
    }
    return status;
  }

  buildHalfProfileConstants() async {
    Constants.userEmail = await getUserEmail();
    Constants.userPhoneNo = await getUserPhone();
    Constants.uid = await getUID();
  }

  Future saveProfilePicturePath(String path) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("profilePicture", path);
  }

  Future getProfilePicturePath() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("profilePicture");
  }

//  Future<String> getUserName() async {
//    SharedPreferences prefs = await SharedPreferences.getInstance();
//    return prefs.getString("userName");
//  }
}

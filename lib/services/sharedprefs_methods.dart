import 'package:droog/data/constants.dart';
import 'package:droog/models/enums.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsMethods {
  Future<void> saveUserDetails({String userEmail,
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

  Future<void> completeUserPrefs(
      {String userName, String firstName, String lastName, LoggedInStatus loggedInStatus}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("userName", userName);
    prefs.setString("firstName", firstName);
    prefs.setString("lastName", lastName);
    prefs.setInt("isLoggedIn", loggedInStatus.index);
  }

//  Future<void> saveUserName({String userName}) async {
//    SharedPreferences prefs = await SharedPreferences.getInstance();
//    prefs.setString("userName", userName);
//  }

  Future<Map<String, String>> getFirstHalfUserDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return {"userEmail": prefs.getString("userEmail"),
      "uid": prefs.getString("uid"),
      "userPhone": prefs.getString("userPhone")
    };
  }

//  Future<String> getUserPhone() async {
//    SharedPreferences prefs = await SharedPreferences.getInstance();
//    return;
//  }
//
//  Future<String> getUID() async {
//    SharedPreferences prefs = await SharedPreferences.getInstance();
//    return;
//  }

  Future<Map<String,String>> getSecondHalfUserDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return {"userName":prefs.getString("userName"),"firstName":prefs.getString("firstName"),"lastName":prefs.getString("lastName")};
  }

  Future<int> getLoggedInStatusAndBuildConstants() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    int status = prefs.getInt("isLoggedIn") ?? -1;
    print(status.toString() + "statttttusssss");
    if (LoggedInStatus.halfProfileLeft.index == status) {
      await buildHalfProfileConstants();
    } else if (LoggedInStatus.loggedIn.index == status) {
      await buildHalfProfileConstants();
      final data =  await getSecondHalfUserDetails();
      Constants.lastName = data["lastName"];
      Constants.firstName = data["firstName"];
      Constants.userName = data["userName"];
    }
    return status;
  }

  buildHalfProfileConstants() async {
    Map<String, String> data = await getFirstHalfUserDetails();
    Constants.userEmail = data["userEmail"];
    Constants.userPhoneNo = data["userPhone"];
    Constants.uid = data["uid"];
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

import 'package:droog/data/constants.dart';
import 'package:droog/models/enums.dart';
import 'package:droog/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsMethods {
  Future<void> saveUserDetails(
      {String userEmail,
      String userPhone,
      String uid,
      LoggedInStatus loggedInStatus}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("userEmail", userEmail);
    prefs.setString("uid", uid);
    prefs.setString("userPhone", userPhone);
    prefs.setInt("isLoggedIn", loggedInStatus.index);
    Constants.uid = uid;
    Constants.userEmail = userEmail;
    Constants.userPhoneNo = userPhone;
  }

  Future<void> saveCompleteUserDetails(
      {String userEmail,
      String userPhone,
      String uid,
      LoggedInStatus loggedInStatus,
      User user}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("userEmail", userEmail);
    prefs.setString("uid", uid);
    prefs.setString("userPhone", userPhone);

    prefs.setString("userName", user.userName);
    prefs.setString("profilePictureUrl", user.profilePictureUrl);
    prefs.setString("description", user.description);

    prefs.setString("firstName", user.firstName);
    prefs.setString("lastName", user.lastName);
    prefs.setInt("isLoggedIn", loggedInStatus.index);
    Constants.uid = uid;
    Constants.userEmail = userEmail;
    Constants.userPhoneNo = userPhone;
    Constants.firstName = user.firstName;
    Constants.lastName = user.lastName;
    Constants.userName = user.userName;
    Constants.profilePictureUrl = user.profilePictureUrl;
    Constants.descriptiom = user.description;
  }

  Future<void> completeUserPrefs(
      {String userName,
      String firstName,
      String lastName,
      String profilePictureUrl,
      String description,
      LoggedInStatus loggedInStatus}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("userName", userName);
    prefs.setString("firstName", firstName);
    prefs.setString("lastName", lastName);
    prefs.setString("profilePictureUrl", profilePictureUrl);
    prefs.setString("description", description);

    prefs.setInt("isLoggedIn", loggedInStatus.index);
    Constants.firstName = firstName;
    Constants.lastName = lastName;
    Constants.userName = userName;
    Constants.profilePictureUrl = profilePictureUrl;
    Constants.descriptiom = description;
  }

//  Future<void> saveUserName({String userName}) async {
//    SharedPreferences prefs = await SharedPreferences.getInstance();
//    prefs.setString("userName", userName);
//  }

  Future<Map<String, String>> getFirstHalfUserDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return {
      "userEmail": prefs.getString("userEmail"),
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

  Future<Map<String, String>> getSecondHalfUserDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return {
      "userName": prefs.getString("userName"),
      "firstName": prefs.getString("firstName"),
      "lastName": prefs.getString("lastName"),
      "profilePictureUrl": prefs.getString("profilePictureUrl"),
      "description": prefs.getString("description"),
    };
  }

  Future<int> getLoggedInStatusAndBuildConstants() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    int status = prefs.getInt("isLoggedIn") ?? -1;
    print(status.toString() + "statttttusssss");
    if (LoggedInStatus.halfProfileLeft.index == status) {
      await buildHalfProfileConstants();
    } else if (LoggedInStatus.loggedIn.index == status) {
      await buildHalfProfileConstants();
      final data = await getSecondHalfUserDetails();
      Constants.lastName = data["lastName"];
      Constants.firstName = data["firstName"];
      Constants.userName = data["userName"];
      Constants.profilePictureUrl = data["profilePictureUrl"];
      Constants.descriptiom = data["description"];
    }
    return status;
  }

  buildHalfProfileConstants() async {
    Map<String, String> data = await getFirstHalfUserDetails();
    Constants.userEmail = data["userEmail"];
    Constants.userPhoneNo = data["userPhone"];
    Constants.uid = data["uid"];
  }

//  Future saveProfilePicturePath(String path) async {
//    SharedPreferences prefs = await SharedPreferences.getInstance();
//    prefs.setString("profilePicture", path);
//  }

//  Future getProfilePicturePath() async {
//    SharedPreferences prefs = await SharedPreferences.getInstance();
//    return prefs.getString("profilePicture");
//  }

//  Future<String> getUserName() async {
//    SharedPreferences prefs = await SharedPreferences.getInstance();
//    return prefs.getString("userName");
//  }
}

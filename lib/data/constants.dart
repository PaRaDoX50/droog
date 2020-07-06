import 'package:path_provider/path_provider.dart';

class Constants {
  static String userEmail;
  static String userPhoneNo;
  static String userName;
  static String uid;
  static String firstName;
  static String lastName;
  static String profilePictureUrl;
  static String descriptiom;


//  static Future getProfilePicturePath()async{
//    final appDir = await getApplicationDocumentsDirectory();
//    return '${appDir.path}/profilePicture.jpg';
//
//  }
  static String get fullName{
    return"$firstName $lastName";
  }

}
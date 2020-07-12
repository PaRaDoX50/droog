class User {
  String uid;
  String userEmail;
  String phoneNo;
  String userName;
  String profilePictureUrl;
  String firstName;
  String lastName;
  String description;
  int droogsCount;
  int askedCount;
  int solvedCount;
  List<dynamic> skills;
  List<dynamic> achievements;

  String get fullName {
    return "$firstName $lastName";
  }

  User(
      {this.userEmail,
      this.userName,
      this.phoneNo,
      this.uid,
      this.profilePictureUrl,
      this.description,
      this.lastName,
      this.firstName,
      this.achievements,
      this.skills,
      this.solvedCount,
      this.askedCount,
      this.droogsCount});
}

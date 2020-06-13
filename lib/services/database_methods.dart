import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:droog/data/constants.dart';
import 'package:droog/models/enums.dart';
import 'package:droog/models/user.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class DatabaseMethods {
  Firestore _database = Firestore.instance;
  FirebaseStorage _storage = FirebaseStorage.instance;

  Future<bool> userNameAvailable(String userName) async {
    QuerySnapshot data = await _database
        .collection("users")
        .where("userName", isEqualTo: userName)
        .getDocuments();

    if (data.documents.isEmpty) {
      return true;
    }
    return false;
  }

  Future uploadProfilePicture(File file) async {
    StorageUploadTask task = _storage
        .ref()
        .child('userProfilePictures/${Constants.uid}.jpg')
        .putFile(file);
    StorageTaskSnapshot snapshot = await task.onComplete;
    return snapshot.ref.getDownloadURL();
  }

  Future completeUserProfile(
      {String firstName,
      String lastName,
      String description,
      String userName,
      String profilePictureUrl}) async {
    Map<String, String> data = {
      "firstName": firstName,
      "lastName": lastName,
      "description": description,
      "userName": userName,
      "profilePictureUrl": profilePictureUrl
    };
    _database
        .collection("users")
        .document(Constants.uid)
        .setData(data, merge: true);
  }

  Future createHalfUserProfile(
      {String userEmail, String mobileNo, String uid}) async {
    List<String> searchParams = [];
    for (int i = 0; i < userEmail.length; i++) {
      print(userEmail.substring(0, i + 1));
      searchParams.add(userEmail.substring(0, i + 1));
    }
    Map<String, dynamic> data = {
      "email": userEmail,
      "phone": mobileNo,
      "searchParams": searchParams
    };

    return _database.collection("users").document(uid).setData(data);
  }

  Stream<QuerySnapshot> getCurrentUserChats({String userEmail}) {
    print(userEmail + "stream");
    return _database
        .collection("chatRooms")
        .where("users", arrayContains: userEmail)
        .snapshots();
  }

  Future getUserDetailsByUsername({String userName}) async {
    QuerySnapshot snapshot = await _database
        .collection("users")
        .where("userName", isEqualTo: userName)
        .getDocuments();
    final data = snapshot.documents.first;
    print(data["userName"].toString() + "dddddddd");

    return User(
        userEmail: data["email"],
        phoneNo: data["phoneNo"],
        uid: data["uid"],
        userName: data["userName"],
        profilePictureUrl: data["profilePictureUrl"]);
  }

  Future searchUser(String keyword) async {
    QuerySnapshot snapshot = await _database
        .collection("users")
        .where("searchParams", arrayContains: keyword)
        .getDocuments();

    List<User> searchResults = [];

    for (int i = 0; i < snapshot.documents.length; i++) {
      List<DocumentSnapshot> data = snapshot.documents;
      searchResults.add(User(
          userEmail: data[i]["email"],
          phoneNo: data[i]["phoneNo"],
          uid: data[i]["uid"]));
    }

    return searchResults;
  }

  Future sendMessage(String userEmail, Map<String, dynamic> message) async {
    String chatRoomId = _chatRoomIdGenerator(userEmail);
    print(chatRoomId);

    DocumentSnapshot document = await _database
        .collection("chatRooms")
        .document(chatRoomId)
        .get()
        .catchError((onError) {
      print(onError);
    });

    if (!document.exists) {
      print("firstTime");
      final data = {
        "users": [Constants.userEmail, userEmail],
      };
      await _database
          .collection("chatRooms")
          .document(chatRoomId)
          .setData(data);
      await _database
          .collection("chatRooms")
          .document(chatRoomId)
          .collection("chats")
          .add(message);
    } else {
      print("notTheFirstTime");
      await _database
          .collection("chatRooms")
          .document(chatRoomId)
          .collection("chats")
          .add(message);
    }
  }

  Stream<QuerySnapshot> getUserConversationsByEmail(String userEmail) {
    String chatRoomId = _chatRoomIdGenerator(userEmail);
    return _database
        .collection("chatRooms")
        .document(chatRoomId)
        .collection("chats")
        .snapshots();
  }

  Future uploadPictureForPost({File file}) async {
    String fileName = Uuid().v4();
    StorageUploadTask task =
        _storage.ref().child("postPictures/${fileName}.jpg").putFile(file);
    StorageTaskSnapshot snapshot = await task.onComplete;
    return snapshot.ref.getDownloadURL();
  }

  Future makeAPost({String description, String imageUrl}) async {
    Map<String, dynamic> data;
      data = {
        "description": description,
        "imageUrl": imageUrl,
        "postBy": Constants.userName,
        "time": DateTime
            .now()
            .millisecondsSinceEpoch
      };


    DocumentReference reference = await _database.collection("posts").add(data);
    Map<String, String> documentIdData = {"documentID": reference.documentID};
    await _database
        .collection("users")
        .document(Constants.uid)
        .collection("posts")
        .add(documentIdData);
  }

  Stream<QuerySnapshot> getPosts() {
    QuerySnapshot querySnapshot;
//
    Stream<QuerySnapshot> stream = _database.collection("posts").orderBy("time",descending: true).snapshots();
    return stream;
//        .map((event) =>
//        event.documents.map((e) => _postFromFirebasePost(e)));
//  return _database.collection("posts").snapshots();
  }

  String _chatRoomIdGenerator(String userEmail) {
    if (Constants.userEmail.codeUnitAt(0) > userEmail.codeUnitAt(0)) {
      return "${Constants.userEmail}_$userEmail";
    } else {
      return "${userEmail}_${Constants.userEmail}";
    }
  }
  Future<void> sendFollowRequest(String uid) async {
    await _database.collection("users").document(uid).collection("requests").document(Constants.uid).setData({"requestBy":Constants.uid});
    //access user by its uid -> under collections(requests) add document by uid of user who sent the request.
  }

  Future getFollowStatus(String uid) async {
    QuerySnapshot snapshotFollowers = await _database.collection("users").document(uid).collection("followers").where("uid",isEqualTo: Constants.uid).getDocuments();
    
    QuerySnapshot snapshotRequests = await _database.collection("users").document(uid).collection("requests").where("requestBy",isEqualTo: Constants.uid).getDocuments();
    if(snapshotFollowers.documents.isEmpty && snapshotRequests.documents.isEmpty){
      return FollowStatus.requestNotSent;
    }
    else if(snapshotFollowers.documents.isNotEmpty){
      return FollowStatus.following;
    }
    else if(snapshotRequests.documents.isNotEmpty){
      return FollowStatus.requestSent;
    }
  }
  Future acceptFollowRequest(String uid) async {
    await _database.collection("users").document(Constants.uid).collection("followers").document(uid).setData({"uid":uid});

//    sleep(Duration(milliseconds: 200));
    await _database.collection("users").document(Constants.uid).collection("requests").document(uid).delete();
  }
  Stream<QuerySnapshot> getPostsForFeed() async* {
    QuerySnapshot snapshotFollowing = await _database.collection("users").document(Constants.uid).collection("following").getDocuments();
    List<String> followingUids = [];
    for(int i = 0; i < snapshotFollowing.documents.length;i++){
      followingUids.add(snapshotFollowing.documents[i].data["uid"]);
    }
     Stream stream = _database.collection("posts").where("postBy",whereIn: followingUids).orderBy("time",descending: true).snapshots();
    yield* stream;

  }





//  Post _postFromFirebasePost(DocumentSnapshot documentSnapshot) {
//    return documentSnapshot != null ? Post(
//        description: documentSnapshot["description"],
//        imageUrl: documentSnapshot["imageUrl"],
//        postBy: documentSnapshot["postBy"],
//        time: documentSnapshot["time"]): null;
//  }


}

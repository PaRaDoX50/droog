import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:droog/data/constants.dart';
import 'package:droog/models/enums.dart';
import 'package:droog/models/response.dart';
import 'package:droog/models/user.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class DatabaseMethods {
  Firestore _database = Firestore.instance;
  FirebaseStorage _storage = FirebaseStorage.instance;

  Future<bool> userNameAvailable({String userName}) async {
    QuerySnapshot data = await _database
        .collection("users")
        .where("userName", isEqualTo: userName)
        .getDocuments();

    if (data.documents.isEmpty) {
      return true;
    }
    return false;
  }

  Future uploadProfilePicture({File file}) async {
    StorageUploadTask task = _storage
        .ref()
        .child('userProfilePictures/${Constants.uid}.jpg')
        .putFile(file);
    StorageTaskSnapshot snapshot = await task.onComplete;
    return snapshot.ref.getDownloadURL();
  }

  Future completeUserProfile({String firstName,
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
      "uid": uid,
      "searchParams": searchParams
    };

    return _database.collection("users").document(uid).setData(data);
  }

  Stream<QuerySnapshot> getCurrentUserChats({String userName}) {
    print(userName + "stream");
    return _database
        .collection("chatRooms")
        .where("users", arrayContains: userName)
        .snapshots();
  }

  Future getUserDetailsByUsername({String targetUserName}) async {
    QuerySnapshot snapshot = await _database
        .collection("users")
        .where("userName", isEqualTo: targetUserName)
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

  Future<List<User>> searchUser(String keyword) async {
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
        uid: data[i]["uid"],
        description: data[i]["description"],
        profilePictureUrl: data[i]["profilePictureUrl"],
        userName: data[i]["userName"],
        lastName: data[i]["lastName"],
        firstName: data[i]["firstName"],
      ));
    }

    return searchResults;
  }

  Future sendMessage(String targetUserName,
      Map<String, dynamic> message) async {
    String chatRoomId = _chatRoomIdGenerator(targetUserName: targetUserName);
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
        "users": [Constants.userName, targetUserName],
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

  Stream<QuerySnapshot> getAConversation({String targetUserName}) {
    String chatRoomId = _chatRoomIdGenerator(targetUserName: targetUserName);
    return _database
        .collection("chatRooms")
        .document(chatRoomId)
        .collection("chats")
        .snapshots();
  }

  Future uploadPictureForPost({File file}) async {
    String fileName = Uuid().v4();
    StorageUploadTask task =
    _storage.ref().child("postPictures/$fileName.jpg").putFile(file);
    StorageTaskSnapshot snapshot = await task.onComplete;
    return snapshot.ref.getDownloadURL();
  }

  Future uploadPictureForResponse({File file}) async {
    String fileName = Uuid().v4();
    StorageUploadTask task =
    _storage.ref().child("responsePictures/$fileName.jpg").putFile(file);
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
    Future makeAResponse(
        {String description, String imageUrl, String postId}) async {
      Map<String, dynamic> data;
      data = {
        "response": description,
        "imageUrl": imageUrl,
        "responseBy": Constants.userName,
        "postId": postId,
        "time": DateTime
            .now()
            .millisecondsSinceEpoch
      };
      DocumentReference reference = await _database.collection("responses").add(
          data);
    }

    Stream<QuerySnapshot> getPosts() {
//    QuerySnapshot querySnapshot;
//
      Stream<QuerySnapshot> stream = _database
          .collection("posts")
          .orderBy("time", descending: true)
          .snapshots();
      return stream;
//        .map((event) =>
//        event.documents.map((e) => _postFromFirebasePost(e)));
//  return _database.collection("posts").snapshots();
    }

    String _chatRoomIdGenerator({String targetUserName}) {
      if (Constants.userName.codeUnitAt(0) > targetUserName.codeUnitAt(0)) {
        return "${Constants.userName}_$targetUserName";
      } else {
        return "${targetUserName}_${Constants.userName}";
      }
    }

    Future<void> sendFollowRequest({String targetUid}) async {
      print(Constants.userName + "hellllsldla");
      print(targetUid + "hellllsldla");


      print(Constants.firstName + "hellllsldla");

      await _database
          .collection("users")
          .document(targetUid)
          .collection("requests")
          .document(Constants.uid)
          .setData({"requestBy": Constants.uid});
      //Access target user by its uid -> under collections of "requests", add document  naming it the uid of the user who sent the request.
    }

    Future<void> cancelFollowRequest({String targetUid}) async {
      //Un-send Follow Request
      await _database
          .collection("users")
          .document(targetUid)
          .collection("requests")
          .document(Constants.uid)
          .delete();

      //Access target user by its uid -> under collections of "requests", delete document named the uid of the user who sent the request.
    }

    Future<FollowStatus> getFollowStatus({String targetUid}) async {
      QuerySnapshot snapshotFollowers = await _database
          .collection("users")
          .document(targetUid)
          .collection("followers")
          .where("uid", isEqualTo: Constants.uid)
          .getDocuments();

      QuerySnapshot snapshotRequests = await _database
          .collection("users")
          .document(targetUid)
          .collection("requests")
          .where("requestBy", isEqualTo: Constants.uid)
          .getDocuments();
      if (snapshotFollowers.documents.isEmpty &&
          snapshotRequests.documents.isEmpty) {
        return FollowStatus.requestNotSent;
      } else if (snapshotFollowers.documents.isNotEmpty) {
        return FollowStatus.following;
      } else {
        return FollowStatus.requestSent;
      }
    }

    Future acceptFollowRequest({String targetUid}) async {
      await _database
          .collection("users")
          .document(Constants.uid)
          .collection("followers")
          .document(targetUid)
          .setData({"uid": targetUid});

      await _database
          .collection("users")
          .document(targetUid)
          .collection("following")
          .document(Constants.uid)
          .setData({"uid": Constants.uid});


//    sleep(Duration(milliseconds: 200));
      await _database
          .collection("users")
          .document(Constants.uid)
          .collection("requests")
          .document(targetUid)
          .delete();
    }

    Stream<QuerySnapshot> getPostsForFeed() async* {
      QuerySnapshot snapshotFollowing = await _database
          .collection("users")
          .document(Constants.uid)
          .collection("following")
          .getDocuments();
      List<String> followingUids = [];
      for (int i = 0; i < snapshotFollowing.documents.length; i++) {
        followingUids.add(snapshotFollowing.documents[i].data["uid"]);
      }
      Stream stream = _database
          .collection("posts")
          .where("postBy", whereIn: followingUids)
          .orderBy("time", descending: true)
          .snapshots();
      yield* stream;
    }

    unFollowUser({String targetUid}) async {
      await _database
          .collection("users")
          .document(targetUid)
          .collection("followers")
          .document(Constants.uid)
          .delete();
    }

    Response _responseFromFirebaseResponse(DocumentSnapshot documentSnapshot) {
      return Response(
          time: documentSnapshot["time"],
          imageUrl: documentSnapshot["imageUrl"],
          isSolution: documentSnapshot["isSolution"],
          postId: documentSnapshot["postId"],
          response: documentSnapshot["response"],
          responseBy: documentSnapshot["responseBy"],
          votes: documentSnapshot["votes"],
          document: documentSnapshot
      );
    }

    Future<List<Response>> getResponsesByPostId(String postId) async {
      QuerySnapshot snapshot = await _database.collection("responses").where(
          "postId", isEqualTo: postId).getDocuments();
      List<DocumentSnapshot> documents = snapshot.documents;
      return documents.map((document) =>
          _responseFromFirebaseResponse(document)).toList();
    }

    Future<void> toggleSolutionForPost(
        {bool isSolution, DocumentSnapshot responseDocument}) async {
      await responseDocument.reference.updateData({"isSolution": isSolution});
    }
    Future<void> voteAResponse({DocumentSnapshot responseDocument}) async {
      int votes = responseDocument["votes"];
      await responseDocument.reference.updateData({"votes": votes + 1});
    }


//  Post _postFromFirebasePost(DocumentSnapshot documentSnapshot) {
//    return documentSnapshot != null ? Post(
//        description: documentSnapshot["description"],
//        imageUrl: documentSnapshot["imageUrl"],
//        postBy: documentSnapshot["postBy"],
//        time: documentSnapshot["time"]): null;
//  }

  }

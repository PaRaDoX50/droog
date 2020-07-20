import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:droog/data/constants.dart';
import 'package:droog/models/enums.dart';
import 'package:droog/models/message.dart';
import 'package:droog/models/post.dart';
import 'package:droog/models/response.dart';
import 'package:droog/models/update.dart';
import 'package:droog/models/user.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

//  Future uploadProfilePicture({File file}) async {
//    StorageUploadTask task = _storage
//        .ref()
//        .child('userProfilePictures/${Constants.uid}.jpg')
//        .putFile(file);
//    StorageTaskSnapshot snapshot = await task.onComplete;
//    return snapshot.ref.getDownloadURL();
//  }

  Future completeUserProfile(
      {String firstName,
      String lastName,
      String description,
      String userName,
      String profilePictureUrl}) async {
    List<String> searchParams = [];
    for (int i = 0; i < userName.length; i++) {
      print(userName.substring(0, i + 1));
      searchParams.add(userName.toLowerCase().substring(0, i + 1));
    }
    for (int i = 0; i < firstName.length + lastName.length + 1; i++) {
      String fullName = "$firstName $lastName";
      print(fullName.substring(0, i + 1));
      searchParams.add(fullName.toLowerCase().substring(0, i + 1));
    }

    Map<String, dynamic> data = {
      "askedCount": 0,
      "droogsCount":0,
      "solvedCount":0,
      "firstName": firstName,
      "lastName": lastName,
      "description": description,
      "userName": userName,
      "profilePictureUrl": profilePictureUrl,
      "searchParams": searchParams,
    };
    _database
        .collection("users")
        .document(Constants.uid)
        .setData(data, merge: true);
  }

  Future editSkills({List<dynamic> skills, List<dynamic> achievements}) async {
    await _database
        .collection("users")
        .document(Constants.uid)
        .updateData({"skills": skills});
    await _database
        .collection("users")
        .document(Constants.uid)
        .updateData({"achievements": achievements});
  }

  Future createHalfUserProfile(
      {String userEmail, String mobileNo, String uid}) async {
    Map<String, dynamic> data = {
      "email": userEmail,
      "phone": mobileNo,
      "uid": uid,
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

  Future<User> getUserDetailsByUsername({String targetUserName}) async {
    QuerySnapshot snapshot = await _database
        .collection("users")
        .where("userName", isEqualTo: targetUserName)
        .getDocuments();
    final data = snapshot.documents.first;
    print(data["userName"].toString() + "dddddddd");

    return _userFromFirebaseUser(userDocument: data);
  }

  Future<User> getUserDetailsByUid({String targetUid}) async {
    DocumentSnapshot snapshot =
        await _database.collection("users").document(targetUid).get();

//    print(data["userName"].toString() + "dddddddd");

    return _userFromFirebaseUser(userDocument: snapshot);
  }

  Future<Post> getPostByPostId({String postId}) async {
    print("gpvpi1");
    DocumentSnapshot snapshot =
        await _database.collection("posts").document(postId).get();
    print("gpvpi2");
    return postFromFirebasePost(documentSnapshot: snapshot);

  }
  Future<DocumentSnapshot> getPostDocByPostId({String postId}) async {
    DocumentSnapshot snapshot =
    await _database.collection("posts").document(postId).get();
    return snapshot;
  }

  Future<List<User>> searchUser(String keyword) async {
    QuerySnapshot snapshot = await _database
        .collection("users")
        .where("searchParams", arrayContains: keyword.toLowerCase())
        .getDocuments();

    List<User> searchResults = snapshot.documents
        .map((e) => _userFromFirebaseUser(userDocument: e))
        .toList();

    return searchResults;
  }

  Future<List<User>> searchUserForANewMessage({String keyword}) async {
    QuerySnapshot snapshotDroogs = await _database
        .collection("users")
        .document(Constants.uid)
        .collection("droogs")
        .getDocuments();
//    QuerySnapshot snapshotFollowers = await _database
//        .collection("users")
//        .document(Constants.uid)
//        .collection("followers")
//        .getDocuments();
//    _database.collection("users").where()
    final uids = (snapshotDroogs.documents.map((e) => e["uid"]).toList());
//    uids.addAll(
//        snapshotFollowers.documents.map((e) => e["uid"]).toList());
    if (uids.isNotEmpty) {
      QuerySnapshot snapshotResults = await _database
          .collection("users")
          .where("uid", whereIn: uids)
          .where("searchParams", arrayContains: keyword)
          .getDocuments();
      List<User> results = snapshotResults.documents
          .map((e) => _userFromFirebaseUser(userDocument: e))
          .toList();
      return results;
    } else {
      return [];
    }
  }

  Future sendFeedback({String feedback}) async {
    await _database.collection("feedback").add({
      "feedbackByUid": Constants.uid,
      "feedbackByUserName": Constants.userName,
      "feedback": feedback
    });
  }

  Future sendMessage(
      {String targetUserName, Map<String, dynamic> message}) async {
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
      DocumentReference reference = await _database
          .collection("chatRooms")
          .document(chatRoomId)
          .collection("chats")
          .add(message);
      return reference;
    } else {
      print("notTheFirstTime");
      DocumentReference reference = await _database
          .collection("chatRooms")
          .document(chatRoomId)
          .collection("chats")
          .add(message);
      return reference;
    }
  }

  Future deleteMessage({
    DocumentReference documentReference,
  }) async {
    await documentReference.delete();
  }

  Stream<List<Message>> getAConversation(
      {String targetUserName, bool limitToOne}) {
    String chatRoomId = _chatRoomIdGenerator(targetUserName: targetUserName);
    if (!limitToOne) {
      Stream<QuerySnapshot> stream = _database
          .collection("chatRooms")
          .document(chatRoomId)
          .collection("chats")
          .orderBy("time", descending: true)
          .snapshots();
      return stream.map((querySnapshot) => querySnapshot.documents
          .map((e) => _messageFromFirebaseMessage(documentSnapshot: e))
          .toList());
    } else {
      Stream<QuerySnapshot> stream = _database
          .collection("chatRooms")
          .document(chatRoomId)
          .collection("chats")
          .orderBy("time", descending: true)
          .limit(1)
          .snapshots();
      return stream.map((querySnapshot) => querySnapshot.documents
          .map((e) => _messageFromFirebaseMessage(documentSnapshot: e))
          .toList());
    }
  }

  Future uploadPicture({File file, String address}) async {
    String fileName = Uuid().v4();
    StorageUploadTask task =
        _storage.ref().child("$address/$fileName.jpg").putFile(file);
    StorageTaskSnapshot snapshot = await task.onComplete;
    return snapshot.ref.getDownloadURL();
  }

//  Future uploadPictureForResponse({File file}) async {
//    String fileName = Uuid().v4();
//    StorageUploadTask task =
//        _storage.ref().child("responsePictures/$fileName.jpg").putFile(file);
//    StorageTaskSnapshot snapshot = await task.onComplete;
//    return snapshot.ref.getDownloadURL();
//  }

  Future makeAPost({String description, String imageUrl}) async {
    Map<String, dynamic> data;
    List<String> connectionUids = await getConnectionUids();

    data = {
      "description": description,
      "imageUrl": imageUrl,
      "postByUserName": Constants.userName,
      "postByUid": Constants.uid,
      "time": DateTime.now().millisecondsSinceEpoch,
      "postFor": connectionUids,
    };
    DocumentReference reference = await _database.collection("posts").add(data);
    Map<String, String> documentIdData = {"postId": reference.documentID};
    await _database
        .collection("users")
        .document(Constants.uid)
        .collection("posts")
        .add(documentIdData);
    await _database
        .collection("users")
        .document(Constants.uid)
        .updateData({"askedCount": FieldValue.increment(1)});
    await _database
        .collection("posts")
        .document(reference.documentID)
        .updateData(documentIdData);
  }

  Future makeAResponse(
      {String description, String imageUrl, String postId}) async {
    Map<String, dynamic> data;
    data = {
      "response": description,
      "imageUrl": imageUrl,
      "responseByUserName": Constants.userName,
      "postId": postId,
      "time": DateTime.now().millisecondsSinceEpoch,
      "isSolution": false,
      "votes": 0,
      "responseByUid": Constants.uid,
    };

        await _database.collection("responses").add(data);

    DocumentSnapshot documentSnapshot =
        await _database.collection("posts").document(postId).get();
    String postByUid = documentSnapshot["postByUid"];
    DocumentSnapshot snapshot =
        await _database.collection("users").document(postByUid).get();
    await snapshot.reference.collection("updates").add({
      "updateType": 0,
      "uidInvolved": Constants.uid,
      "postInvolved": postId,
      "time": DateTime.now().millisecondsSinceEpoch,
    });
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
  Future<bool> isDroog({String targetUid}) async {
  DocumentSnapshot documentSnapshot =  await _database.collection("users").document(Constants.uid).collection("droogs").document(targetUid).get();
  return documentSnapshot.exists;
  }

  Future<void> sendConnectionRequest({String targetUid}) async {
//    print(Constants.userName + "hellllsldla");
    print(targetUid + "hellllsldla");

//    print(Constants.firstName + "hellllsldla");

    await _database
        .collection("users")
        .document(targetUid)
        .collection("requests")
        .document(Constants.uid)
        .setData({"uid": Constants.uid});
    //Access target user by its uid -> under collections of "requests", add document  naming it the uid of the user who sent the request.
  }

  Future<void> cancelConnectionRequest({String targetUid}) async {
    //Un-send Follow Request
    await _database
        .collection("users")
        .document(targetUid)
        .collection("requests")
        .document(Constants.uid)
        .delete();

    //Access target user by its uid -> under collections of "requests", delete document named the uid of the user who sent the request.
  }

  Future<List<User>> getRequests({bool limitTo3}) async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    print(user.uid);
    print("reachedMethod");
    if (limitTo3) {
      print("reachedLimit");
      QuerySnapshot snapshot = await _database
          .collection("users")
          .document(Constants.uid)
          .collection("requests")
          .limit(3)
          .getDocuments();
      print("reachedsnapshot");
      List<DocumentSnapshot> documents = snapshot.documents;
      print("reachedsnapshot1" + documents.length.toString());
      List<User> users = [];
      for (int i = 0; i < documents.length; i++) {
        print(i.toString() + "index" + documents[i].data.toString());
        print(documents[i]["uid"] + "documentrequest");
        User user = await getUserDetailsByUid(targetUid: documents[i]["uid"]);
        users.add(user);
      }
      print("reachedsnapshot2");
      return users;
    } else {
      print("reached else");
      QuerySnapshot snapshot = await _database
          .collection("users")
          .document(Constants.uid)
          .collection("requests")
          .getDocuments();
      print("reached else2");
      List<DocumentSnapshot> documents = snapshot.documents;
      print("reached else" + documents.length.toString());
      List<User> users = [];
      for (int i = 0; i < documents.length; i++) {
        User user = await getUserDetailsByUid(targetUid: documents[i]["uid"]);
        users.add(user);
      }
//      print("reached else3");
      return users;
    }
  }

  Future<ConnectionStatus> getConnectionStatus({String targetUid}) async {
//    QuerySnapshot snapshotFollowers = await _database
//        .collection("users")
//        .document(targetUid)
//        .collection("followers")
//        .where("uid", isEqualTo: Constants.uid)
//        .getDocuments();

    QuerySnapshot snapshotDroogs = await _database
        .collection("users")
        .document(targetUid)
        .collection("droogs")
        .where("uid", isEqualTo: Constants.uid)
        .getDocuments();

    QuerySnapshot snapshotRequests = await _database
        .collection("users")
        .document(targetUid)
        .collection("requests")
        .where("uid", isEqualTo: Constants.uid)
        .getDocuments();
    if (snapshotDroogs.documents.isEmpty &&
        snapshotRequests.documents.isEmpty) {
      return ConnectionStatus.requestNotSent;
    } else if (snapshotDroogs.documents.isNotEmpty) {
      return ConnectionStatus.droogs;
    } else {
      return ConnectionStatus.requestSent;
    }
  }

  Future acceptConnectionRequest({String targetUid}) async {
    await _database
        .collection("users")
        .document(Constants.uid)
        .collection("droogs")
        .document(targetUid)
        .setData({"uid": targetUid});

    await _database
        .collection("users")
        .document(targetUid)
        .collection("droogs")
        .document(Constants.uid)
        .setData({"uid": Constants.uid});
    await _database
        .collection("users")
        .document(Constants.uid)
        .updateData({"droogsCount": FieldValue.increment(1)});

    await _database
        .collection("users")
        .document(targetUid)
        .updateData({"droogsCount": FieldValue.increment(1)});

//    sleep(Duration(milliseconds: 200));
    await _database
        .collection("users")
        .document(Constants.uid)
        .collection("requests")
        .document(targetUid)
        .delete();
    await _database
        .collection("users")
        .document(targetUid)
        .collection("updates")
        .add({
      "updateType": 2,
      "uidInvolved": Constants.uid,
      "time": DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<List<String>> getConnectionUids() async {
    QuerySnapshot snapshotDroogs = await _database
        .collection("users")
        .document(Constants.uid)
        .collection("droogs")
        .getDocuments();
    List<String> droogsUids = [Constants.uid,];
    for (int i = 0; i < snapshotDroogs.documents.length; i++) {
      droogsUids.add(snapshotDroogs.documents[i].data["uid"]);
    }
    if (droogsUids.isNotEmpty) {
      return droogsUids;
    } else {
      return null;
    }
  }

  Future<List<DocumentSnapshot>> getMorePostsForFeed({
    List<String> droogsUids,
    DocumentSnapshot documentSnapshot,
  }) async {
    if (droogsUids.isNotEmpty) {
      QuerySnapshot snapshot = await _database
          .collection("posts")
          .where("postFor",arrayContains: Constants.uid)
          .orderBy("time", descending: true)
          .startAfterDocument(documentSnapshot)
          .limit(10)
          .getDocuments();
      List<DocumentSnapshot> moreDocuments = snapshot.documents;
      //    List<Post> morePosts = moreDocuments.map((e) => _postFromFirebasePost(documentSnapshot: e)).toList();
      return moreDocuments;
    } else {
      return null;
    }
  }

  Stream<QuerySnapshot> getPostsForFeed(
      {List<String> droogsUids,
      bool isFirstTime,
      DocumentSnapshot documentSnapshot}) {
    if (droogsUids.isNotEmpty) {
      Stream stream = _database
          .collection("posts")
          .where("postFor", arrayContains: Constants.uid)
          .orderBy("time", descending: true)
          .limit(10)
          .snapshots();
      return stream;
    } else {
      return null;
    }
  }
//  Future<List<DocumentSnapshot>> getPostsForFeed  (
//      {List<String> droogsUids,
//        bool isFirstTime,
//        DocumentSnapshot documentSnapshot}) async {
//    List<DocumentSnapshot> postDocs = [];
//    if (droogsUids.isNotEmpty) {
//      if (droogsUids.length < 11) {
//        QuerySnapshot qSnapshot = await _database
//            .collection("posts")
//            .orderBy("time", descending: true)
//            .where("postByUid", whereIn: droogsUids)
//            .orderBy("time", descending: true)
//            .limit(10)
//            .getDocuments();
//        postDocs.addAll(qSnapshot.documents);
//      }
//      else{
//        for(int i = 0;i<droogsUids.length~/10;i++){
//
//          QuerySnapshot qSnapshot = await _database
//              .collection("posts")
//              .orderBy("time", descending: true)
//              .where("postByUid", whereIn: droogsUids.sublist(i*10,(10*i)+10))
//              .orderBy("time", descending: true)
//              .limit(10)
//              .getDocuments();
//          postDocs.addAll(qSnapshot.documents);
//        }
//      }
////      return stream;
//    } else {
//      return null;
//    }
//  }

  Future<List<Post>> getAUsersPosts({
    String targetUid,
  }) async {
    QuerySnapshot snapshot = await _database
        .collection("posts")
        .where("postByUid", isEqualTo: targetUid)
        .orderBy("time", descending: true)
        .getDocuments();
    return snapshot.documents
        .map((e) => postFromFirebasePost(documentSnapshot: e))
        .toList();
  }

  Future<List<Post>> getAUsersSolvedDoubts({
    String targetUid,
  }) async {
    QuerySnapshot snapshot = await _database
        .collection("users")
        .document(targetUid)
        .collection("solvedDoubts")
        .getDocuments();

    List<Post> solved = [];

    for (int i = 0; i < snapshot.documents.length; i++) {
      DocumentSnapshot documentSnapshot = await _database
          .collection("posts")
          .document(snapshot.documents[i]["postId"])
          .get();

      solved.add(postFromFirebasePost(documentSnapshot: documentSnapshot));
    }
    return solved;
  }
  Future<bool> isClipped({String postId})async{
  try {
    DocumentSnapshot snapshot = await _database.collection("users").document(Constants.uid).get();
//    print((snapshot["clippedPosts"] as List).contains(postId).toString()+"backkoff");
    bool isClipped = snapshot["clippedPosts"] != null ? (snapshot["clippedPosts"] as List).contains(postId) : false;
    return isClipped;
  }  catch (e) {
    // TODO
    print(e.toString()+"backkofffbtach");
  }
  }

  Future clipPost({String postId}) async {
    await _database.collection("users").document(Constants.uid).updateData({
      "clippedPosts": FieldValue.arrayUnion([postId])
    });
  }
  Future unClipPost({String postId}) async {
    await _database.collection("users").document(Constants.uid).updateData({
      "clippedPosts": FieldValue.arrayRemove([postId])
    });
  }

  Future loadMoreClips({int lastIndex}) async {
    print("hellllllfiree"+"more");

//    DocumentSnapshot snapshot =
//        await _database.collection("users").document(Constants.uid).get();
//    QuerySnapshot qSnapshot = await _database
//        .collection("posts")
//        .where("postId", whereIn: snapshot["clippedPosts"])
//        .orderBy("time", descending: true)
//        .startAfterDocument(documentSnapshot)
//        .limit(10)
//        .getDocuments();
//    List<Post> posts = qSnapshot.documents
//        .map((e) => postFromFirebasePost(documentSnapshot: e))
//        .toList();
//    return posts;
    DocumentSnapshot snapshot =
    await _database.collection("users").document(Constants.uid).get();
    print(snapshot["clippedPosts"].toString());
    print(snapshot.data["clippedPosts"].toString() + "clipped");
    if ((snapshot["clippedPosts"] as List).isNotEmpty) {
//      QuerySnapshot qSnapshot = await _database
//          .collection("posts")
//          .where("postId", whereIn: snapshot["clippedPosts"])
//          .orderBy("time", descending: true)
//          .limit(10)
//          .getDocuments();
      List<DocumentSnapshot> postDocs = [];
      print( lastIndex.toString()+" "+min((snapshot["clippedPosts"] as List).length.toDouble() -lastIndex - 1,(lastIndex+10).toDouble()).toString());
      for(int i = lastIndex ;i< min((snapshot["clippedPosts"] as List).length.toDouble() ,(lastIndex+10).toDouble()).toInt(); i++){
        print(i.toString()+"hellllllfiree"+"more");
        DocumentSnapshot postDoc = await getPostDocByPostId(postId: (snapshot["clippedPosts"] as List)[i]);
        postDocs.add(postDoc);
      }

      if (postDocs.isNotEmpty) {
        return postDocs;
      } else {
        return null;
      }
    } else {
      return null;
    }
  }

  Future<List<DocumentSnapshot>> getClips() async {
    try {
      DocumentSnapshot snapshot =
          await _database.collection("users").document(Constants.uid).get();
      print(snapshot["clippedPosts"].toString());
      print(snapshot.data["clippedPosts"].toString() + "clipped");
      if ((snapshot["clippedPosts"] as List).isNotEmpty) {
      //      QuerySnapshot qSnapshot = await _database
      //          .collection("posts")
      //          .where("postId", whereIn: snapshot["clippedPosts"])
      //          .orderBy("time", descending: true)
      //          .limit(10)
      //          .getDocuments();
        print("hellllllfiree");
      List<DocumentSnapshot> documents = [];
      for(int i = 0 ; i< min((snapshot["clippedPosts"] as List).length.toDouble(),10.toDouble()).toInt(); i++){
        print(i.toString()+"hellllllfiree");
        DocumentSnapshot documentSnapshot = await getPostDocByPostId(postId: (snapshot["clippedPosts"] as List)[i]);
        documents.add(documentSnapshot);
      }
      print("complete forloop");


        if (documents.isNotEmpty) {
          return documents;
        } else {
          return null;
        }
      } else {
        return null;

      }
    }  catch (e) {
      // TODO
      print(e);
    }

//    List<Post> posts = qSnapshot.documents.map((e) => postFromFirebasePost(documentSnapshot: e)).toList();
  }

  disconnectFromUser({String targetUid}) async {
    await _database
        .collection("users")
        .document(targetUid)
        .collection("droogs")
        .document(Constants.uid)
        .delete();
    await _database
        .collection("users")
        .document(Constants.uid)
        .collection("droogs")
        .document(targetUid)
        .delete();
    await _database
        .collection("users")
        .document(targetUid)
        .updateData({"droogsCount":FieldValue.increment(-1)});
    await _database
        .collection("users")
        .document(Constants.uid)
        .updateData({"droogsCount":FieldValue.increment(-1)});

  }

  Response _responseFromFirebaseResponse(DocumentSnapshot documentSnapshot) {
    return Response(
        time: documentSnapshot["time"],
        imageUrl: documentSnapshot["imageUrl"],
        postId: documentSnapshot["postId"],
        response: documentSnapshot["response"],
        responseByUserName: documentSnapshot["responseByUserName"],
        responseByUid: documentSnapshot["responseByUid"],
        votes: documentSnapshot["votes"],
        document: documentSnapshot);
  }

  Future<List<Response>> getResponsesByPostId(String postId) async {
    QuerySnapshot snapshot = await _database
        .collection("responses")
        .where("postId", isEqualTo: postId)
        .getDocuments();
    List<DocumentSnapshot> documents = snapshot.documents;
    return documents
        .map((document) => _responseFromFirebaseResponse(document))
        .toList();
  }

  Future<int> getResponsesCountByPostId(String postId) async {
    QuerySnapshot snapshot = await _database
        .collection("responses")
        .where("postId", isEqualTo: postId)
        .getDocuments();
    List<DocumentSnapshot> documents = snapshot.documents;
    return documents.length;
  }

  Future<void> toggleSolutionForPost(
      {DocumentSnapshot responseDocument, bool markAsSolution}) async {
    try {
      String postId = responseDocument["postId"];
      if (markAsSolution) {
        String solutionId = await getSolutionId(postId);

        if (solutionId != ""  && solutionId != null ) {
          print(solutionId+"solutionIdasdasd");
          DocumentSnapshot responseDocument =
              await _database.collection("responses").document(solutionId).get();
          print("solutionid not Null1");
          Response response = _responseFromFirebaseResponse(responseDocument);
          print("solutionid not Null2");
          DocumentSnapshot userSnapshot = await _database
              .collection("users")
              .document(response.responseByUid)
              .get();
          print("solutionid not Null3");
          await userSnapshot.reference
              .collection("solvedDoubts")
              .document(postId)
              .delete();
          print("solutionid not Null5");
          await userSnapshot.reference
              .updateData({"solvedCount": FieldValue.increment(-1)});
          print("solutionid not Null6");
        }
        await _database
            .collection("posts")
            .document(postId)
            .updateData({"solutionId": responseDocument.documentID});
        DocumentSnapshot snapshot = await _database
            .collection("users")
            .document(responseDocument["responseByUid"])
            .get();
        await snapshot.reference
            .collection("solvedDoubts")
            .document(postId)
            .setData({"postId": postId});
        await snapshot.reference.updateData({"solvedCount":FieldValue.increment(1)});
        await snapshot.reference.collection("updates").add({
          "updateType": 1,
          "uidInvolved": Constants.uid,
          "responseId": responseDocument.documentID,
          "postInvolved": postId,
          "time": DateTime.now().millisecondsSinceEpoch,
        });
        print("done dona done");
      } else {
        await _database
            .collection("users")
            .document(responseDocument["responseByUid"])
            .collection("solvedDoubts")
            .document(postId)
            .delete();
         await _database
            .collection("users")
            .document(responseDocument["responseByUid"])
            .updateData({"solvedCount":FieldValue.increment(-1)});
        await _database
            .collection("posts")
            .document(postId)
            .updateData({"solutionId": ""});
      }
    }  catch (e) {
      // TODO
      print(e.toString());
    }
//    if (isSolution) {
//      QuerySnapshot snapshot = await _database
//          .collection("responses")
//          .where("postId", isEqualTo: responseDocument["postId"])
//          .where("isSolution", isEqualTo: true)
//          .getDocuments(); //snapshot of responses of a post which are solution for that post(list will contain only one document,since only a single response can be a solution)
//      List<DocumentSnapshot> documents = snapshot.documents;
//      for (int i = 0; i < documents.length; i++) {
//        await documents[i].reference.updateData({"isSolution": false});
//      } //change isSolution field of previous solution to false because user selected a new solution
//    }
//    await responseDocument.reference.updateData({"isSolution": isSolution});
  }

  Future<String> getSolutionId(String postId) async {
    DocumentSnapshot postDocument =
        await _database.collection("posts").document(postId).get();
    return postDocument["solutionId"];
  }

  Future<void> voteAResponse(
      {DocumentSnapshot responseDocument, VoteType voteType}) async {
    int votes = responseDocument["votes"];
    if (voteType == VoteType.upVote) {
      await responseDocument.reference.updateData({"votes": votes + 1});
      await responseDocument.reference
          .collection("votes")
          .document(Constants.uid)
          .setData({"voteBy": Constants.userName});
    } else if (voteType == VoteType.undoUpVote) {
      await responseDocument.reference.updateData({"votes": votes - 1});
      await responseDocument.reference
          .collection("votes")
          .document(Constants.uid)
          .delete();
    }
  }

  Future<List<Update>> getUpdates() async {
    QuerySnapshot snapshot = await _database
        .collection("users")
        .document(Constants.uid)
        .collection("updates")
        .orderBy("time", descending: true)
        .getDocuments();
    List<DocumentSnapshot> documents = snapshot.documents;
    List<Update> updates = [];
    for (int i = 0; i < documents.length; i++) {
      Update update = _updateFromFirebaseUpdate(documentSnapshot: documents[i]);
      updates.add(update);
    }
    return updates;
  }

  Future<VoteStatus> checkVoteStatus(
      {DocumentSnapshot responseDocument}) async {
    DocumentSnapshot snapshot = await responseDocument.reference
        .collection("votes")
        .document(Constants.uid)
        .get();
    if (snapshot.exists) {
      return VoteStatus.alreadyVoted;
    } else {
      return VoteStatus.notVoted;
    }
  }
  Future deleteAPost({String postId})async{
    await _database.collection("posts").document(postId).delete();
    await _database.collection("users").document(Constants.uid).updateData({"askedCount":FieldValue.increment(-1)});
    await _database.collection("users").document(Constants.uid).collection("posts").document(postId).delete();


  }
  Future reportAPost({String targetUid, String postId}) async {
    await _database.collection("reports").add(
        {"uid": targetUid, "postId": postId, "reportByUid": Constants.uid});
  }

  Future reportAResponse({String targetUid, String responseId}) async {
    await _database.collection("reports").add({
      "uid": targetUid,
      "responseId": responseId,
      "reportByUid": Constants.uid
    });
  }

  User _userFromFirebaseUser({DocumentSnapshot userDocument}) {
    return User(
        description: userDocument["description"],
        userName: userDocument["userName"],
        lastName: userDocument["lastName"],
        profilePictureUrl: userDocument["profilePictureUrl"],
        userEmail: userDocument["userEmail"],
        firstName: userDocument["firstName"],
        uid: userDocument["uid"],
        phoneNo: userDocument["phoneNo"],
        achievements: userDocument["achievements"],
        skills: userDocument["skills"],
        askedCount: userDocument["askedCount"],
        droogsCount: userDocument["droogsCount"],
        solvedCount: userDocument["solvedCount"]);
  }

  Message _messageFromFirebaseMessage({DocumentSnapshot documentSnapshot}) {
    if (documentSnapshot["messageType"] == MessageType.onlyText.index) {
      return Message(
          isSeen: documentSnapshot["isSeen"] != null
              ? documentSnapshot["isSeen"]
              : false,
          documentSnapshot: documentSnapshot,
          time: documentSnapshot["time"],
          byUid: documentSnapshot["byUid"],
          byUserName: documentSnapshot["byUserName"],
          messageType: MessageType.onlyText,
          text: documentSnapshot["text"]);
    } else if (documentSnapshot["messageType"] == MessageType.image.index) {
      return Message(
          isSeen: documentSnapshot["isSeen"] != null
              ? documentSnapshot["isSeen"]
              : false,
          documentSnapshot: documentSnapshot,
          time: documentSnapshot["time"],
          byUid: documentSnapshot["byUid"],
          byUserName: documentSnapshot["byUserName"],
          messageType: MessageType.image,
          text: documentSnapshot["text"],
          imageUrl: documentSnapshot["imageUrl"]);
    } else if (documentSnapshot["messageType"] ==
        MessageType.sharedPost.index) {
      return Message(
          isSeen: documentSnapshot["isSeen"] != null
              ? documentSnapshot["isSeen"]
              : false,
          documentSnapshot: documentSnapshot,
          time: documentSnapshot["time"],
          byUid: documentSnapshot["byUid"],
          byUserName: documentSnapshot["byUserName"],
          messageType: MessageType.sharedPost,
          postId: documentSnapshot["postId"]);
    }
  }

  Update _updateFromFirebaseUpdate({DocumentSnapshot documentSnapshot}) {
    if (documentSnapshot["updateType"] == UpdateType.acceptedRequest.index) {
      return Update(
        updateType: UpdateType.acceptedRequest,
        uidInvolved: documentSnapshot["uidInvolved"],
        time: documentSnapshot["time"],
      );
    } else if (documentSnapshot["updateType"] ==
        UpdateType.markedAsSolution.index) {
      print("returned update");
      return Update(
        updateType: UpdateType.markedAsSolution,
        responseId: documentSnapshot["responseId"],
        uidInvolved: documentSnapshot["uidInvolved"],
        postInvolved: documentSnapshot["postInvolved"],
        time: documentSnapshot["time"],
      );
    } else if (documentSnapshot["updateType"] == UpdateType.responded.index) {
      print("returned update");
      return Update(
        updateType: UpdateType.responded,
        postInvolved: documentSnapshot["postInvolved"],
        uidInvolved: documentSnapshot["uidInvolved"],
        time: documentSnapshot["time"],
      );
    }
    print("undefinedUpdateType");
    return Update();
  }

  Post postFromFirebasePost({DocumentSnapshot documentSnapshot}) {
    return documentSnapshot != null
        ? Post(
            postId: documentSnapshot.documentID,
            solutionId: documentSnapshot["solutionId"],
            description: documentSnapshot["description"],
            imageUrl: documentSnapshot["imageUrl"],
            postByUserName: documentSnapshot["postByUserName"],
            time: documentSnapshot["time"],
            postByUid: documentSnapshot["postByUid"])
        : null;
  }
}

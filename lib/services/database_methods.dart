import 'dart:io';

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

    return _userFromFirebaseUser(userDocument: data);
  }

  Future getUserDetailsByUid({String targetUid}) async {
    DocumentSnapshot snapshot =
        await _database.collection("users").document(targetUid).get();

//    print(data["userName"].toString() + "dddddddd");

    return _userFromFirebaseUser(userDocument: snapshot);
  }

  Future<Post> getPostByPostId({String postId}) async {
    DocumentSnapshot snapshot =
        await _database.collection("posts").document(postId).get();
    return _postFromFirebasePost(documentSnapshot: snapshot);
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

  Stream<List<Message>> getAConversation({String targetUserName}) {
    String chatRoomId = _chatRoomIdGenerator(targetUserName: targetUserName);
    Stream<QuerySnapshot> stream = _database
        .collection("chatRooms")
        .document(chatRoomId)
        .collection("chats")
        .orderBy("time", descending: true)
        .snapshots();
    return stream.map((querySnapshot) => querySnapshot.documents
        .map((e) => _messageFromFirebaseMessage(documentSnapshot: e))
        .toList());
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
    data = {
      "description": description,
      "imageUrl": imageUrl,
      "postBy": Constants.userName,
      "time": DateTime.now().millisecondsSinceEpoch
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
      "time": DateTime.now().millisecondsSinceEpoch,
      "isSolution": false,
      "votes": 0,
      "uid": Constants.uid,
    };
    DocumentReference reference =
        await _database.collection("responses").add(data);

    DocumentSnapshot documentSnapshot =
        await _database.collection("posts").document(postId).get();
    String postBy = documentSnapshot["postBy"];
    QuerySnapshot snapshot = await _database
        .collection("users")
        .where('userName', isEqualTo: postBy)
        .getDocuments();
    await snapshot.documents[0].reference.collection("updates").add({
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

  Future<void> sendFollowRequest({String targetUid}) async {
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
      QuerySnapshot snapshot = await _database
          .collection("users")
          .document(Constants.uid)
          .collection("requests")
          .getDocuments();
      List<DocumentSnapshot> documents = snapshot.documents;
      List<User> users;
      for (int i = 0; i < documents.length; i++) {
        User user = await getUserDetailsByUid(targetUid: documents[i]["uid"]);
        users.add(user);
      }
      return users;
    }
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
        .where("uid", isEqualTo: Constants.uid)
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
        uid: documentSnapshot["uid"],
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

  Future<void> toggleSolutionForPost(
      {DocumentSnapshot responseDocument, bool markAsSolution}) async {
    String postId = responseDocument["postId"];
    if (markAsSolution) {
      await _database
          .collection("posts")
          .document(postId)
          .updateData({"solutionId": responseDocument.documentID});
      DocumentSnapshot snapshot = await _database
          .collection("users")
          .document(responseDocument["uid"])
          .get();
      snapshot.reference.collection("updates").add({
        "updateType": 1,
        "uidInvolved": Constants.uid,
        "responseId": responseDocument.documentID,
        "postInvolved": postId,
        "time": DateTime.now().millisecondsSinceEpoch,
      });
    } else {
      await _database
          .collection("posts")
          .document(postId)
          .updateData({"solutionId": ""});
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

  User _userFromFirebaseUser({DocumentSnapshot userDocument}) {
    return User(
        description: userDocument["description"],
        userName: userDocument["userName"],
        lastName: userDocument["lastName"],
        profilePictureUrl: userDocument["profilePictureUrl"],
        userEmail: userDocument["userEmail"],
        firstName: userDocument["firstName"],
        uid: userDocument["uid"],
        phoneNo: userDocument["phoneNo"]);
  }

  Message _messageFromFirebaseMessage({DocumentSnapshot documentSnapshot}) {
    if (documentSnapshot["messageType"] == MessageType.onlyText.index) {
      return Message(
          time: documentSnapshot["time"],
          byUid: documentSnapshot["byUid"],
          byUserName: documentSnapshot["byUserName"],
          messageType: MessageType.onlyText,
          text: documentSnapshot["text"]);
    } else if (documentSnapshot["messageType"] == MessageType.image.index) {
      return Message(
          time: documentSnapshot["time"],
          byUid: documentSnapshot["byUid"],
          byUserName: documentSnapshot["byUserName"],
          messageType: MessageType.image,
          text: documentSnapshot["text"],
          imageUrl: documentSnapshot["imageUrl"]);
    } else if (documentSnapshot["messageType"] ==
        MessageType.sharedPost.index) {
      return Message(
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

  Post _postFromFirebasePost({DocumentSnapshot documentSnapshot}) {
    return documentSnapshot != null
        ? Post(
            postId: documentSnapshot.documentID,
            solutionId: documentSnapshot["solutionId"],
            description: documentSnapshot["description"],
            imageUrl: documentSnapshot["imageUrl"],
            postBy: documentSnapshot["postBy"],
            time: documentSnapshot["time"])
        : null;
  }
}

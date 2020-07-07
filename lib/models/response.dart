import 'package:cloud_firestore/cloud_firestore.dart';

class Response{
  String responseByUserName;//userName of a user
  String responseByUid;//uid of user
  String imageUrl; //url of image if present in response
  String response; //response text
  String postId; //auto id firebase of response's post
  int votes;
//  bool isSolution;//is the response a solution for the post
  int time;
  //time at which response was posted(millisecondsfromepoch)
  DocumentSnapshot document;

  Response({this.postId,this.imageUrl,this.time,this.response,this.responseByUserName,this.votes,this.document,this.responseByUid});
}
class Reply{
  String replyBy;
  String reply;
  int time;
  Reply({this.time,this.reply,this.replyBy});
}
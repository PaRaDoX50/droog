import 'package:droog/models/enums.dart';
import 'package:flutter/material.dart';

class Message {
  MessageType messageType;
  String text;
  String imageUrl;
  int time;
  String byUid;
  String byUserName;
  String postId;

  Message({@required this.messageType,@required this.time,@required this.byUid,@required this.byUserName,this.postId,this.text,this.imageUrl});


}
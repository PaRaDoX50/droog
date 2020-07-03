import 'package:cloud_firestore/cloud_firestore.dart';
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
  DocumentSnapshot documentSnapshot;
  bool isSeen;

  Message(
      {@required this.messageType,
      @required this.time,
      @required this.byUid,
      @required this.byUserName,
      this.postId,
      this.text,
      this.imageUrl,
      this.documentSnapshot,
      this.isSeen});
}

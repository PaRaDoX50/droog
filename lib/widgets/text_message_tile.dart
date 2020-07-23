import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:url_launcher/url_launcher.dart';

class TextMessageTile extends StatefulWidget {
  final String message;
  final Alignment alignment;
  final bool isLastMessage;
  final DocumentSnapshot documentSnapshot;

  TextMessageTile({this.message, this.alignment,this.isLastMessage,this.documentSnapshot});

  @override
  _TextMessageTileState createState() => _TextMessageTileState();
}

class _TextMessageTileState extends State<TextMessageTile> with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Animation<Offset> _offsetAnimation;


  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this,duration: Duration(milliseconds: 300));
    _offsetAnimation = Tween<Offset>( begin:const Offset(2, 0.0) ,
      end: Offset.zero,).animate(CurvedAnimation(curve: Curves.linear,parent: _controller));


  }
  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  getWidgets(double width) {
    if (widget.alignment == Alignment.centerRight) {
      return [
        Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Color(0xff4481bc),
            borderRadius: BorderRadius.circular(10),
          ),
          child: SelectableLinkify(
            text: widget.message,
            onOpen: (link) async {
              print("opening");
              if (await canLaunch(link.url)) {
                print("opening");
                await launch(link.url);
              } else {
                print(":cant launch url");
              }
            },
            style: TextStyle(color: Colors.white),
            linkStyle: TextStyle(color:Color(0xffe8f5fd)),
          ),
          constraints: BoxConstraints(maxWidth: width / 1.5),
        ),
        SizedBox(
          width: width / 30,
        ),
      ];
    } else {
      return [
        Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Color(0xffe8f5fd),
            borderRadius: BorderRadius.circular(10),
          ),
          child: SelectableLinkify(
            text: widget.message,
            onOpen: (link) async {
              print("opening");
              if (await canLaunch(link.url)) {
                print("opening");
                await launch(link.url);
              } else {
                print(":cant launch url");
              }
            },
            linkStyle: TextStyle(color: Colors.blue),
          ),
          constraints: BoxConstraints(maxWidth: width / 1.5),
        ),
        SizedBox(
          width: width / 30,
        ),
      ].reversed.toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Padding(
      padding: EdgeInsets.all(width / 60),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Row(
            mainAxisAlignment: widget.alignment == Alignment.centerRight
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: getWidgets(width),
          ),
          widget.alignment == Alignment.centerRight ?
          (widget.isLastMessage ? StreamBuilder<DocumentSnapshot>(stream: widget.documentSnapshot.reference.snapshots(),builder: (_,snapshot){
            if(snapshot.hasData){
              if(snapshot.data.data["isSeen"] ?? false){
                _controller.forward();
                return Padding(
                  padding: EdgeInsets.only(right: width/20),
                  child: SlideTransition(child:Text("Seen",style: TextStyle(color: Colors.blueGrey,fontSize: 10),),position: _offsetAnimation,),
                );
              }

              return Container();
            }
            return Container();
          },):Container())
              :
              Container()
        ],
      ),
    );
  }


}
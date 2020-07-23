import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:droog/screens/full_screen_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:url_launcher/url_launcher.dart';

class ImageMessageTile extends StatefulWidget {
  final String imageUrl;
  String text = "";
  final Alignment alignment;
//  final String message;
//  final Alignment alignment;
  final bool isLastMessage;
  final DocumentSnapshot documentSnapshot;


  ImageMessageTile({this.text, this.imageUrl, this.alignment,this.isLastMessage,this.documentSnapshot});

  @override
  _ImageMessageTileState createState() => _ImageMessageTileState();
}

class _ImageMessageTileState extends State<ImageMessageTile> with SingleTickerProviderStateMixin{
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

  getWidgets(double width, BuildContext ctx) {
    if (widget.alignment == Alignment.centerRight) {
      return [
        Container(
          padding: EdgeInsets.all(8 / 2),
          decoration: BoxDecoration(
            color: Color(0xff4481bc),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: <Widget>[
              GestureDetector(
                onTap: () => Navigator.pushNamed(ctx, FullScreenImage.route,
                    arguments: widget.imageUrl),
                child: Hero(
                  tag: widget.imageUrl,
                  child: CachedNetworkImage(
                    placeholder: (x, y) {
                      return Container(
                          child: Center(
                              child: CircularProgressIndicator(
                                backgroundColor: Colors.white,
                              )));
                    },
                    imageUrl: widget.imageUrl,
                  ),
                ),
              ),
              widget.text != ""
                  ? SizedBox(
                height: 2,
              )
                  : Container(),
              widget.text != ""
                  ? SelectableLinkify(
                text: widget.text,
                style: TextStyle(color: Colors.white),
                onOpen: (link) async {
                  print("opening");
                  if (await canLaunch(link.url)) {
                    print("opening");
                    await launch(link.url);
                  } else {
                    print(":cant launch url");
                  }
                },
                linkStyle: TextStyle(color:Color(0xffe8f5fd)),
              )
                  : Container()
            ],
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
          padding: EdgeInsets.all(8 / 2),
          decoration: BoxDecoration(
            color: Color(0xffe8f5fd),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: <Widget>[
              GestureDetector(
                onTap: () => Navigator.pushNamed(ctx, FullScreenImage.route,
                    arguments: widget.imageUrl),
                child: Hero(
                  tag: widget.imageUrl,
                  child: CachedNetworkImage(
                    imageUrl: widget.imageUrl,
                    placeholder: (x, y) {
                      return Container(
                          child: Center(
                              child: CircularProgressIndicator(
                                backgroundColor: Colors.white,
                              )));
                    },
                  ),
                ),
              ),
              widget.text != ""
                  ? SizedBox(
                height: 2,
              )
                  : Container(),
              widget.text != ""
                  ? SelectableLinkify(
                text: widget.text,

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
              )
                  : Container()
            ],
          ),
          constraints: BoxConstraints(maxWidth: width / 1.5),
        ),
        SizedBox(
          width: width / 30,
        ),
      ];
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
            children: getWidgets(width,context),
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
//              _controller.forward();
//              return Padding(
//                padding: EdgeInsets.only(right: width/20),
//                child: SlideTransition(child:Text("NOTSeen",style: TextStyle(color: Colors.blueGrey,fontSize: 10),),position: _offsetAnimation,),
//              );
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
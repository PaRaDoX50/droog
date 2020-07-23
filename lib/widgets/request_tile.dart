import 'package:cached_network_image/cached_network_image.dart';
import 'package:droog/models/user.dart';
import 'package:droog/services/database_methods.dart';
import 'package:droog/utils/theme_data.dart';
import 'package:droog/widgets/profile_picture_loading.dart';
import 'package:flutter/material.dart';

class RequestTile extends StatefulWidget {
  final User user;
  final Function snackBarAndSetState;

  RequestTile({this.user, this.snackBarAndSetState});

  @override
  _RequestTileState createState() => _RequestTileState();
}

class _RequestTileState extends State<RequestTile> {
  bool _acceptingRequest = false;
  bool _deletingRequest = false;
  final DatabaseMethods _databaseMethods = DatabaseMethods();

  acceptFollowRequest() async {
    if (!_acceptingRequest && !_deletingRequest) {
      setState(() {
        _acceptingRequest = true;
      });
      await _databaseMethods.acceptConnectionRequest(targetUid: widget.user.uid);

      widget.snackBarAndSetState("Joined");
    }

//    Future.delayed(Duration(milliseconds: 300),(){setState(() {
//      _acceptingRequest = false;
//    });});

  }

  deleteFollowRequest() async {
    if (!_acceptingRequest && !_deletingRequest) {
      setState(() {
        _deletingRequest = true;
      });
      try {
        await _databaseMethods.rejectConnectionRequest(targetUid: widget.user.uid);
      }  catch (e) {
        // TODO
        print(e.toString());
      }
      //    setState(() {
      //      _deletingRequest = false;
      //    });
      widget.snackBarAndSetState("Deleted");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Expanded(
          child: Row(mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircleAvatar(
                  radius: 30,
                  child: ClipOval(
                    child: CachedNetworkImage(
                      imageUrl: widget.user.profilePictureUrl,
                      placeholder: (x, y) {
                        return  ProfilePictureLoading();
                      },
                    ),
                  ),
                ),
              ),
              Flexible(
                fit: FlexFit.loose,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    FittedBox(child: Text(widget.user.userName,maxLines: 1,overflow: TextOverflow.ellipsis,)),
                    SizedBox(
                      height: 2,
                    ),
                    FittedBox(child: Text(widget.user.fullName,maxLines: 1,overflow: TextOverflow.ellipsis,)),
                  ],
                ),
              ),
            ],
          ),
        ),
        Row(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(right:8.0),
              child: SizedBox(
                height: 30,
                child: RaisedButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(5))),
                  child: _acceptingRequest ?  SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(backgroundColor: Colors.white,strokeWidth: 1.5,
                    ),
                  ) : FittedBox(
                      child: Text(
                        "Connect",
                      )),
                  color: MyThemeData.buttonColorBlue,
                  textColor: Colors.white,
                  onPressed: acceptFollowRequest,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right:8.0),
              child: SizedBox(
                height: 30,
                child: RaisedButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(5))),
                  child: _deletingRequest ? SizedBox(width:20,height:20,child: CircularProgressIndicator(backgroundColor: Colors.blue,strokeWidth: 1.5,)) : FittedBox(child: Text("Delete")),
                  color: MyThemeData.buttonColorWhite,
                  textColor: Colors.black,
                  onPressed: deleteFollowRequest,
                ),
              ),
            ),
          ],
        )
      ],
    );
  }
}
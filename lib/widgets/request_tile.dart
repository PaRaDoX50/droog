import 'package:cached_network_image/cached_network_image.dart';
import 'package:droog/models/user.dart';
import 'package:droog/services/database_methods.dart';
import 'package:droog/utils/theme_data.dart';
import 'package:flutter/material.dart';

class RequestTile extends StatelessWidget {
  final User user;
  final Function snackBarAndSetState;

  RequestTile({this.user, this.snackBarAndSetState});

  final DatabaseMethods _databaseMethods = DatabaseMethods();

  acceptFollowRequest() async {
    await _databaseMethods.acceptConnectionRequest(targetUid: user.uid);
    snackBarAndSetState("Joined");
  }

  deleteFollowRequest() async {
    await _databaseMethods.cancelConnectionRequest(targetUid: user.uid);
    snackBarAndSetState("Deleted");
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
                  child: ClipOval(
                    child: CachedNetworkImage(
                      imageUrl: user.profilePictureUrl,
                    ),
                  ),
                ),
              ),
              Flexible(
                fit: FlexFit.loose,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    FittedBox(child: Text(user.userName,maxLines: 1,overflow: TextOverflow.ellipsis,)),
                    SizedBox(
                      height: 2,
                    ),
                    FittedBox(child: Text(user.fullName,maxLines: 1,overflow: TextOverflow.ellipsis,)),
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
                  child: FittedBox(
                      child: Text(
                        "Join",
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
                  child: FittedBox(child: Text("Delete")),
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
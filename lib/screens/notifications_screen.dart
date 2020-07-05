import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:droog/models/enums.dart';
import 'package:droog/models/post.dart';
import 'package:droog/models/update.dart';
import 'package:droog/models/user.dart';
import 'package:droog/screens/responses_screen.dart';
import 'package:droog/screens/user_profile.dart';
import 'package:droog/services/database_methods.dart';
import 'package:droog/utils/theme_data.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';

class NotificationsScreen extends StatefulWidget {
  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  Future userRequests;
  Future userUpdates;
  final DatabaseMethods _databaseMethods = DatabaseMethods();
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    userRequests = _databaseMethods.getRequests(limitTo3: true);
    userUpdates = _databaseMethods.getUpdates();
  }

  showSnackBarAndSetState(String text) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      backgroundColor: Theme.of(context).primaryColor,
      content: Text(text),
    ));
    setState(() {
      userRequests = _databaseMethods.getRequests(limitTo3: true);
    });
  }

  Widget _futureBuilderRequests(AsyncSnapshot snapshot) {
    if ((snapshot.data[1] as List).length > 0) {
      List<RequestTile> _requestTiles = (snapshot.data[1] as List<User>)
          .map(
            (e) => RequestTile(
              user: e,
              snackBarAndSetState: showSnackBarAndSetState,
            ),
          )
          .toList();
      Widget showAll = Container(padding:EdgeInsets.all(8),width: double.infinity,child: Text("Show all",style: MyThemeData.primary14,),alignment: Alignment.centerRight,);

      return Column(
        children: [..._requestTiles,showAll],
      );
    } else {
      return Container(
        child: Center(
          child:Text("No Requests"),
        ),
      );
    }
  }

  Widget _futureBuilderUpdates(AsyncSnapshot snapshot) {
    print("update.postInvolved+update.uidInvolved+update.responseId");

    List<UpdateTile> _updateTiles = (snapshot.data[0] as List<Update>)
        .map(
          (e) => UpdateTile(
            update: e,
          ),
        )
        .toList();

    return SliverList(delegate: SliverChildBuilderDelegate((_,index){return _updateTiles[index];},childCount: _updateTiles.length),);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: FutureBuilder(
          future: Future.wait([userUpdates, userRequests]),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return LiquidPullToRefresh(color: Theme.of(context).primaryColor,
                onRefresh: () async {

                  setState(() {
                    userRequests = _databaseMethods.getRequests(limitTo3: true);
                    userUpdates = _databaseMethods.getUpdates();
                });},
                child: CustomScrollView(
                  slivers: [
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              "Requests",
                              style: MyThemeData.blackBold12.copyWith(fontSize: 16),
                            ),
                          ),
                        ),
                        SliverToBoxAdapter(child: _futureBuilderRequests(snapshot)),
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              "Updates",
                              style: MyThemeData.blackBold12.copyWith(fontSize: 16),
                            ),
                          ),
                        ),
                        _futureBuilderUpdates(snapshot),

                  ]
                ),
              );
            } else {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
          }),
    );
  }
}

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
                    Text(user.userName,maxLines: 1,overflow: TextOverflow.ellipsis,),
                    SizedBox(
                      height: 2,
                    ),
                    Text(user.fullName,maxLines: 1,overflow: TextOverflow.ellipsis,),
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

class UpdateTile extends StatelessWidget {
  final Update update;

  UpdateTile({this.update});

  final DatabaseMethods _databaseMethods = DatabaseMethods();
  BuildContext context;

  Future<Widget> _buildRequestAcceptedUpdate() async {
    User user = await _databaseMethods.getUserDetailsByUid(
        targetUid: update.uidInvolved);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, UserProfile.route,
                      arguments: user);
                },
                child: CircleAvatar(
                  child: ClipOval(
                    child: CachedNetworkImage(
                      imageUrl: user.profilePictureUrl,
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 8,
              ),
              Expanded(
                child: RichText(
                    text: TextSpan(children: [
                  TextSpan(
                      text: user.userName,
                      style: MyThemeData.primary14,
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          Navigator.pushNamed(context, UserProfile.route,
                              arguments: user);
                        }),
                  TextSpan(
                      text: " has accepted your request",
                      style: GoogleFonts.montserrat(color: Colors.black)),
                ])),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<Widget> _buildMarkedAsSolutionUpdate() async {
    User user = await _databaseMethods.getUserDetailsByUid(
        targetUid: update.uidInvolved);
    return GestureDetector(
      onTap: () async {
        Post post =
            await _databaseMethods.getPostByPostId(postId: update.postInvolved);
        Navigator.pushNamed(context, ResponseScreen.route, arguments: post);
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, UserProfile.route,
                        arguments: user);
                  },
                  child: CircleAvatar(
                    child: ClipOval(
                      child: CachedNetworkImage(
                        imageUrl: user.profilePictureUrl,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 8,
                ),
                RichText(
                    text: TextSpan(children: [
                  TextSpan(
                      text: user.userName,
                      style: MyThemeData.primary14,
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          Navigator.pushNamed(context, UserProfile.route,
                              arguments: user);
                        }),
                  TextSpan(
                      text: " marked your response as solution",
                      style: GoogleFonts.montserrat(color: Colors.black)),
                ])),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<Widget> _buildRespondedUpdate() async {
    print("responded tile");

    User user = await _databaseMethods.getUserDetailsByUid(
        targetUid: update.uidInvolved);
    return GestureDetector(
      onTap: () async {
        Post post =
            await _databaseMethods.getPostByPostId(postId: update.postInvolved);
        Navigator.pushNamed(context, ResponseScreen.route, arguments: post);
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: <Widget>[
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, UserProfile.route, arguments: user);
              },
              child: CircleAvatar(
                child: ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: user.profilePictureUrl,
                  ),
                ),
              ),
            ),
            SizedBox(
              width: 8,
            ),
            RichText(
                text: TextSpan(children: [
              TextSpan(
                  text: user.userName,
                  style: MyThemeData.primary14,
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      Navigator.pushNamed(context, UserProfile.route,
                          arguments: user);
                    }),
              TextSpan(
                  text: " responded to your post",
                  style: GoogleFonts.montserrat(color: Colors.black)),
            ]))
          ],
        ),
      ),
    );
  }

  Future<Widget> _returnAppropriateTile() async {

    if (update.updateType == UpdateType.acceptedRequest) {
      return _buildRequestAcceptedUpdate();
    } else if (update.updateType == UpdateType.markedAsSolution) {
      return _buildMarkedAsSolutionUpdate();
    } else if (update.updateType == UpdateType.responded) {
      print("Reached tile");
      return _buildRespondedUpdate();
    }
    return Container();
  }

  @override
  Widget build(BuildContext context) {
    this.context = context;
    print("update.postInvolved+update.uidInvolved+update.responseId");

    return FutureBuilder<Widget>(
        future: _returnAppropriateTile(),
        builder: (context, snapshot) {
          print("update.postInvolved+update.uidInvolved+update.responseId");

          if (snapshot.hasData) {
            return snapshot.data;
          }
          print("update.postInvolved+update.uidInvolved+update.responseId");

          return Container();
        });
  }
}


import 'package:cached_network_image/cached_network_image.dart';
import 'package:droog/models/enums.dart';
import 'package:droog/models/post.dart';
import 'package:droog/models/update.dart';
import 'package:droog/models/user.dart';
import 'package:droog/screens/all_requests.dart';
import 'package:droog/screens/responses_screen.dart';
import 'package:droog/screens/user_profile.dart';
import 'package:droog/services/database_methods.dart';
import 'package:droog/utils/theme_data.dart';
import 'package:droog/widgets/profile_picture_loading.dart';
import 'package:droog/widgets/request_tile.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:transparent_image/transparent_image.dart';

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

  showSnackBarAndSetState(String text)  {
    setState(() {
      userRequests = _databaseMethods.getRequests(limitTo3: true);
    });

    _scaffoldKey.currentState.showSnackBar(MyThemeData.getSnackBar(text: text));

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
        children: [..._requestTiles,GestureDetector(onTap:()=>Navigator.pushNamed(context,AllRequests.route),child:showAll)],
      );
    } else {
      return Container(
        child: Center(
          child:Text("No Requests",style: TextStyle() ,),
        ),
      );
    }
  }

  Widget _futureBuilderUpdates(AsyncSnapshot snapshot) {
//    print("update.postInvolved+update.uidInvolved+update.responseId");

    if ((snapshot.data[0] as List<Update>).length > 0) {
      List<UpdateTile> _updateTiles = (snapshot.data[0] as List<Update>)
          .map(
            (e) => UpdateTile(
              update: e,
            ),
          )
          .toList();

      return SliverList(delegate: SliverChildBuilderDelegate((_,index){return _updateTiles[index];},childCount: _updateTiles.length),);
    }
    else{
      return SliverFillRemaining(child: Center(
        child: Column(mainAxisSize: MainAxisSize.min,

          children: <Widget>[
            FadeInImage(
              image: AssetImage("assets/images/no_updates.png",),
              placeholder: MemoryImage(kTransparentImage),width: MediaQuery.of(context).size.width*.6,),
//            Image.asset("assets/images/no_updates.png",width: MediaQuery.of(context).size.width*.6,),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text("No Updates! Try refreshing the page.",style: TextStyle(fontSize: 16),),
            ),
          ],
        ),
      ),);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
                    (snapshot.data[1] as List).length > 0 ?
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              "Requests",
                              style: MyThemeData.blackBold12.copyWith(fontSize: 16),
                            ),
                          ),
                        ) : SliverToBoxAdapter(child: Container(),),
                    (snapshot.data[1] as List).length > 0 ? SliverToBoxAdapter(child: _futureBuilderRequests(snapshot)): SliverToBoxAdapter(child: Container(),),
                    (snapshot.data[1] as List).length > 0 ?  SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              "Updates",
                              style: MyThemeData.blackBold12.copyWith(fontSize: 16),
                            ),
                          ),
                        ): SliverToBoxAdapter(child: Container(),),
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
                  radius: 25,
                  child: ClipOval(
                    child: CachedNetworkImage(
                      imageUrl: user.profilePictureUrl,
                      placeholder: (x, y) {
                        return  ProfilePictureLoading();
                      },
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
                      style: TextStyle(color: Colors.black)),
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
                    radius: 25,
                    child: ClipOval(
                      child: CachedNetworkImage(
                        imageUrl: user.profilePictureUrl,
                        placeholder: (x, y) {
                          return  ProfilePictureLoading();
                        },
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 8,
                ),
                Flexible(
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
                        text: " marked your response as solution",
                        style: TextStyle(color: Colors.black)),
                  ])),
                ),
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
                    placeholder: (x, y) {
                      return  ProfilePictureLoading();
                    },
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
                  style: TextStyle(color: Colors.black)),
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

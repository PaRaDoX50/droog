import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:droog/data/constants.dart';
import 'package:droog/models/enums.dart';
import 'package:droog/models/user.dart';
import 'package:droog/screens/droogs_list.dart';
import 'package:droog/screens/profile_setup.dart';
import 'package:droog/services/database_methods.dart';
import 'package:droog/utils/theme_data.dart';
import 'package:droog/widgets/profile_picture_loading.dart';
import 'package:droog/widgets/skills_container.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ProfileContainer extends StatefulWidget {
  final User user;
  final GlobalKey<ScaffoldState> scaffoldKey ;
  ProfileContainer({@required this.user,@required this.scaffoldKey});

  @override
  _ProfileContainerState createState() => _ProfileContainerState();
}

class _ProfileContainerState extends State<ProfileContainer> {
  ConnectionStatus _connectionStatus;

  final _databaseMethods = DatabaseMethods();
  bool _isLoading = false;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    String userName = widget.user.userName;
    String fullName = widget.user.fullName;
    String profilePictureUrl = widget.user.profilePictureUrl;
    String description = widget.user.description;
    int askedCount =
        widget.user.askedCount != null ? widget.user.askedCount : 0;
    int droogsCount =
        widget.user.droogsCount != null ? widget.user.droogsCount : 0;
    int solvedCount =
        widget.user.solvedCount != null ? widget.user.solvedCount : 0;

    return ColumnSuper(
      innerDistance: -30,
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [Color(0xff1948a0), Color(0xff3089e0)],
                  end: Alignment.bottomCenter,
                  begin: Alignment.topCenter)),
          child: Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 16, bottom: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ListTile(
                  leading: ClipOval(
                    child: CachedNetworkImage(
                      imageUrl: profilePictureUrl,
                      placeholder: (x, y) {
                        return  ProfilePictureLoading();
                      },
                    ),
                  ),
                  title: Text(
                    userName,
                    style: TextStyle(color: Colors.white, fontSize: 15),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    fullName,
                    style: TextStyle(color: Colors.white),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: RaisedButton(
                    onPressed: () {
                      if (userName != Constants.userName && !_isLoading) {
                        switch (_connectionStatus) {
                          case ConnectionStatus.requestNotSent:
                            _sendRequest();
                            break;
                          case ConnectionStatus.requestSent:
                            _cancelRequest();
                            break;
                          case ConnectionStatus.droogs:
                            _unFollow();
                            break;
                          case ConnectionStatus.requestAlreadyPresent:
                            showOptions();
                            break;
                        }
                      } else {
                        Navigator.pushNamed(context, ProfileSetup.route,
                            arguments: RoutedProfileSetupFor.edit);
                      }
                    },
                    child: _isLoading
                        ? SizedBox(
                            height: 15,
                            width: 15,
                            child: CircularProgressIndicator(
                              backgroundColor: Colors.white,strokeWidth: 2,
                            ),
                          )
                        : (userName != Constants.userName
                            ? FutureBuilder<String>(
                                future: _followButtonText,
                                builder: (context, snapshot) {
                                  return snapshot.hasData
                                      ? FittedBox(
                                          child: Text(
                                            snapshot.data,
                                            style: Theme.of(context)
                                                .textTheme
                                                .button,
                                          ),
                                        )
                                      : SizedBox(
                                          height: 15,
                                          width: 15,
                                          child: CircularProgressIndicator(
                                            backgroundColor: Colors.white,strokeWidth: 2,
                                          ),
                                        );
                                })
                            : FittedBox(
                                child: Text(
                                  "Edit",
                                  style: Theme.of(context).textTheme.button,
                                ),
                              )),
                  ),
                ),
                SizedBox(
                  height: 16,
                ),
                Text(
                  description,
                  style: TextStyle(color: Colors.white),
                ),
                SizedBox(
                  height: 16,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    GestureDetector(
                      onTap: ()=>widget.user.uid == Constants.uid ? Navigator.pushNamed(context, DroogsList.route) : null,
                      child: Column(
                        children: <Widget>[
                          Text(
                            "Droogs",
                            style: TextStyle(color: Colors.white),
                          ),
                          Text(
                            droogsCount.toString(),
                            style: TextStyle(color: Colors.white),
                          )
                        ],
                      ),
                    ),
                    Column(
                      children: <Widget>[
                        Text(
                          "Asked",
                          style: TextStyle(color: Colors.white),
                        ),
                        Text(
                          askedCount.toString(),
                          style: TextStyle(color: Colors.white),
                        )
                      ],
                    ),
                    Column(
                      children: <Widget>[
                        Text(
                          "Solved",
                          style: TextStyle(color: Colors.white),
                        ),
                        Text(
                          solvedCount.toString(),
                          style: TextStyle(color: Colors.white),
                        )
                      ],
                    ),
                  ],
                ),
                SizedBox(
                  height: 30,
                ),
              ],
            ),
          ),
        ),
        SizedBox(
          width: double.infinity,
          child: SkillsContainer(
            userName: userName,
            skills: widget.user.skills != null ? widget.user.skills : [],
            achievements: widget.user.achievements != null
                ? widget.user.achievements
                : [],
          ),
        ),
      ],
    );
  }

  Future<String> get _followButtonText async {
    _connectionStatus =
        await _databaseMethods.getConnectionStatus(targetUid: widget.user.uid);
    switch (_connectionStatus) {
      case ConnectionStatus.requestSent:
        return "Cancel Request";
      case ConnectionStatus.droogs:
        return "Disconnect";
      case ConnectionStatus.requestNotSent:
        return "Connect";
      case ConnectionStatus.requestAlreadyPresent:
        return "Respond";
    }
  }

  showOptions() {
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              contentPadding: EdgeInsets.zero,
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  InkWell(
                      onTap: () async {
                        try {

                          Navigator.pop(context);
                          acceptFollowRequest();
                        } catch (e) {
                          // TODO

                          Navigator.pop(context);
                          widget.scaffoldKey.currentState.showSnackBar(
                              MyThemeData.getSnackBar(
                                  text: "Something went wrong"));
                        }
                      },
                      child: ListTile(
                        leading: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Icon(
                              Icons.report,
                              color: Color(0xff4481bc),
                            ),
                          ],
                        ),
                        title: Text("Connect"),
                        subtitle: Text("Accept Connection Request"),
                      )),
                  Divider(
                    height: 1,
                    thickness: 1,
                  ),
                  InkWell(
                    onTap: () async {
                      try {

                        Navigator.pop(context);
                        deleteFollowRequest();
                      } catch (e) {
                        Navigator.pop(context);
                        widget.scaffoldKey.currentState.showSnackBar(
                            MyThemeData.getSnackBar(
                                text: "Something went wrong"));
                        // TODO
                      }
                    },
                    child: ListTile(
                        leading: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Icon(
                              Icons.clear,
                              color: Color(0xff4481bc),
                            ),
                          ],
                        ),
                        title: Text("Delete"),
                        subtitle: Text("Delete Connection Request")),
                  )
                ],
              ),
            ));
  }

  Future _sendRequest() async {
    if (!_isLoading) {
      setState(() {
        _isLoading = !_isLoading;
      });
      print(widget.user.firstName);
      print(widget.user.uid.toString());
      await _databaseMethods.sendConnectionRequest(targetUid: widget.user.uid);
      setState(() {
        _isLoading = !_isLoading;
      });
    }
  }

  Future _cancelRequest() async {
    if (!_isLoading) {
      setState(() {
        _isLoading = !_isLoading;
      });
      await _databaseMethods.cancelConnectionRequest(
          targetUid: widget.user.uid);
      print("Sed");
      setState(() {
        _isLoading = !_isLoading;
      });
    }
  }

  Future _unFollow() async {
    if (!_isLoading) {
      setState(() {
        _isLoading = !_isLoading;
      });
      await _databaseMethods.disconnectFromUser(targetUid: widget.user.uid);
      print("Snd");
      setState(() {
        _isLoading = !_isLoading;
      });
    }
  }
  acceptFollowRequest() async {
    if (!_isLoading) {
      setState(() {
        _isLoading = !_isLoading;
      });
      await _databaseMethods.acceptConnectionRequest(targetUid: widget.user.uid);
      setState(() {
        _isLoading = !_isLoading;
      });

    }

//    Future.delayed(Duration(milliseconds: 300),(){setState(() {
//      _acceptingRequest = false;
//    });});

  }

  deleteFollowRequest() async {
    if (!_isLoading) {
      setState(() {
        _isLoading = !_isLoading;
      });

        await _databaseMethods.rejectConnectionRequest(targetUid: widget.user.uid);
      setState(() {
        _isLoading = !_isLoading;
      });

      //    setState(() {
      //      _deletingRequest = false;
      //    });
    }
  }
}

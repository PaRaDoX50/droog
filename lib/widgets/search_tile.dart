import 'package:cached_network_image/cached_network_image.dart';
import 'package:droog/models/enums.dart';
import 'package:droog/models/user.dart';
import 'package:droog/screens/user_profile.dart';
import 'package:droog/services/database_methods.dart';
import 'package:droog/utils/theme_data.dart';
import 'package:droog/widgets/profile_picture_loading.dart';
import 'package:flutter/material.dart';

class SearchTile extends StatefulWidget {
  final User user;
  final GlobalKey<ScaffoldState> scaffoldKey;

  SearchTile({@required this.user, @required this.scaffoldKey});

  @override
  _SearchTileState createState() => _SearchTileState();
}

class _SearchTileState extends State<SearchTile> {
  ConnectionStatus _connectionStatus;
  bool _showLoading = false;
  final _databaseMethods = DatabaseMethods();

  getAppropriateChild(String data) {
    return _showLoading
        ? SizedBox(
      height: 20,
      width: 20,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        backgroundColor: Colors.white,
      ),
    )
        : FittedBox(
        child: Text(
          data,
          style: Theme.of(context).textTheme.button,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      child: Column(
        children: <Widget>[
          ListTile(
            onTap: () {
              Navigator.pushNamed(context, UserProfile.route,
                  arguments: widget.user);
            },
            leading: CircleAvatar(
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
            title: Text("${widget.user.firstName} ${widget.user.lastName}",
                overflow: TextOverflow.ellipsis),
            subtitle: Text(
              widget.user.userName,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: RaisedButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(5))),
              child: _showLoading
                  ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  backgroundColor: Colors.white,
                  strokeWidth: 2,
                ),
              )
                  : FutureBuilder<String>(
                  future: _followButtonText,
                  builder: (context, snapshot) {
                    return snapshot.hasData
                        ? getAppropriateChild(snapshot.data)
                        : SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          backgroundColor: Colors.white,
                          strokeWidth: 2,
                        ));
                  }),
              color: MyThemeData.buttonColorBlue,
              textColor: Colors.white,
              onPressed: () {
                if (!_showLoading) {
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
                }
              },
            ),
          ),
          Divider(
            height: 1,
            color: Colors.grey,
          )
        ],
      ),
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
    if (!_showLoading) {
      print(widget.user.firstName);
      print(widget.user.uid.toString());
      setState(() {
        _showLoading = true;
      });
      await _databaseMethods.sendConnectionRequest(targetUid: widget.user.uid);

      setState(() {
        _showLoading = false;
      });
    }
  }

  Future _cancelRequest() async {
    if (!_showLoading) {
      setState(() {
        _showLoading = true;
      });
      await _databaseMethods.cancelConnectionRequest(
          targetUid: widget.user.uid);
      print("Sed");
      setState(() {
        _showLoading = false;
      });
    }
  }

  Future _unFollow() async {
    if (!_showLoading) {
      setState(() {
        _showLoading = true;
      });
      await _databaseMethods.disconnectFromUser(targetUid: widget.user.uid);
      print("Snd");
      setState(() {
        _showLoading = false;
      });
    }
  }

  acceptFollowRequest() async {
    if (!_showLoading) {
      setState(() {
        _showLoading = !_showLoading;
      });
      await _databaseMethods.acceptConnectionRequest(
          targetUid: widget.user.uid);
      setState(() {
        _showLoading = !_showLoading;
      });
    }

//    Future.delayed(Duration(milliseconds: 300),(){setState(() {
//      _acceptingRequest = false;
//    });});
  }

  deleteFollowRequest() async {
    if (!_showLoading) {
      setState(() {
        _showLoading = !_showLoading;
      });

      await _databaseMethods.rejectConnectionRequest(
          targetUid: widget.user.uid);
      setState(() {
        _showLoading = !_showLoading;
      });

      //    setState(() {
      //      _deletingRequest = false;
      //    });
    }
  }
}
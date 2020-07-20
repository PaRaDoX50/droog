import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:droog/data/constants.dart';
import 'package:droog/models/enums.dart';
import 'package:droog/models/user.dart';
import 'package:droog/screens/profile_setup.dart';
import 'package:droog/services/database_methods.dart';
import 'package:droog/widgets/skills_container.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ProfileContainer extends StatefulWidget {
  final User user;

  ProfileContainer({@required this.user});

  @override
  _ProfileContainerState createState() => _ProfileContainerState();
}

class _ProfileContainerState extends State<ProfileContainer> {
  ConnectionStatus _connectionStatus;

  final _databaseMethods = DatabaseMethods();

  @override
  Widget build(BuildContext context) {
    String userName = widget.user.userName;
    String fullName = widget.user.fullName;
    String profilePictureUrl = widget.user.profilePictureUrl;
    String description = widget.user.description;
    int askedCount = widget.user.askedCount != null ? widget.user.askedCount : 0;
    int droogsCount = widget.user.droogsCount != null ? widget.user.droogsCount : 0;
    int solvedCount = widget.user.solvedCount != null ? widget.user.solvedCount : 0;

    return ColumnSuper(
      innerDistance: -30,
      children: <Widget>[
        Container(
          decoration: BoxDecoration(gradient: LinearGradient(colors: [Color(0xff1948a0),Color(0xff3089e0)],end: Alignment.bottomCenter,begin: Alignment.topCenter)),
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
                    ),
                  ),
                  title: Text(
                      userName,
                      style: TextStyle(color: Colors.white,fontSize: 15),
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
                      if (userName != Constants.userName) {
                        switch(_connectionStatus){
                          case ConnectionStatus.requestNotSent:
                            _sendRequest();
                            break;
                          case ConnectionStatus.requestSent:
                            _cancelRequest();
                            break;
                          case ConnectionStatus.droogs:
                            _unFollow();
                            break;
                        }

                      }
                      else{
                        Navigator.pushNamed(context, ProfileSetup.route,arguments: RoutedProfileSetupFor.edit);
                      }
                    },
                    child: userName != Constants.userName ? FutureBuilder<String>(
                        future: _followButtonText,
                        builder: (context, snapshot) {
                          return snapshot.hasData
                              ? FittedBox(
                                child: Text(
                                    snapshot.data,
                                    style: Theme.of(context).textTheme.button,
                                  ),
                              )
                              : SizedBox(height:15,width:15,child: CircularProgressIndicator());
                        }) : FittedBox(child: Text("Edit", style: Theme.of(context).textTheme.button,)),
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
                    Column(
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
          child: SkillsContainer(userName: userName,
            skills:widget.user.skills != null? widget.user.skills : [],
            achievements: widget.user.achievements !=null ? widget.user.achievements : [],
          ),
        ),
      ],
    );
  }



  Future<String> get _followButtonText async {
    _connectionStatus = await _databaseMethods.getConnectionStatus(targetUid: widget.user.uid);
    switch (_connectionStatus) {
      case ConnectionStatus.requestSent:
        return "Cancel Request";
      case ConnectionStatus.droogs:
        return "Disconnect";
      default:
        return "Connect";
    }
  }

  Future _sendRequest() async {
    print(widget.user.firstName);
    print(widget.user.uid.toString());
    await _databaseMethods.sendConnectionRequest(targetUid:widget.user.uid);


    setState(() {

    });
  }

  Future _cancelRequest() async {
    await _databaseMethods.cancelConnectionRequest(targetUid:widget.user.uid);
    print("Sed");
    setState(() {

    });
  }

  Future _unFollow() async {
    await _databaseMethods.disconnectFromUser(targetUid:widget.user.uid);
    print("Snd");
    setState(() {

    });
  }
}

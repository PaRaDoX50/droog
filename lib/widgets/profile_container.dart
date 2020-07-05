import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:droog/models/enums.dart';
import 'package:droog/models/user.dart';
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
  FollowStatus _followStatus;

  final _databaseMethods = DatabaseMethods();

  @override
  Widget build(BuildContext context) {
    String userName = widget.user.userName;
    String fullName = widget.user.fullName;
    String profilePictureUrl = widget.user.profilePictureUrl;
    String description = widget.user.description;
    String askedCount = "10";
    String droogsCount = "250";
    String solvedCount = "120";

    return ColumnSuper(
      innerDistance: -30,
      children: <Widget>[
        Container(
          color: Theme.of(context).primaryColor,
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
                    style: TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    fullName,
                    style: TextStyle(color: Colors.white),
                  ),
                  trailing: RaisedButton(
                    onPressed: () {
                      switch(_followStatus){
                        case FollowStatus.requestNotSent:
                          _sendRequest();
                          break;
                        case FollowStatus.requestSent:
                          _cancelRequest();
                          break;
                        case FollowStatus.following:
                          _unFollow();
                          break;
                      }
                    },
                    child: FutureBuilder<String>(
                        future: _followButtonText,
                        builder: (context, snapshot) {
                          return snapshot.hasData
                              ? FittedBox(
                                child: Text(
                                    snapshot.data,
                                    style: Theme.of(context).textTheme.button,
                                  ),
                              )
                              : CircularProgressIndicator();
                        }),
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
                          droogsCount,
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
                          askedCount,
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
                          solvedCount,
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
            skills:widget.user.skills != null? widget.user.skills : [],
            achievements: widget.user.achievements !=null ? widget.user.achievements : [],
          ),
        ),
      ],
    );
  }



  Future<String> get _followButtonText async {
    _followStatus = await _databaseMethods.getFollowStatus(targetUid: widget.user.uid);
    switch (_followStatus) {
      case FollowStatus.requestSent:
        return "Cancel Request";
      case FollowStatus.following:
        return "Un-follow";
      default:
        return "Follow";
    }
  }

  Future _sendRequest() async {
    print(widget.user.firstName);
    print(widget.user.uid.toString());
    await _databaseMethods.sendFollowRequest(targetUid:widget.user.uid);


    setState(() {

    });
  }

  Future _cancelRequest() async {
    await _databaseMethods.cancelFollowRequest(targetUid:widget.user.uid);
    print("Sed");
    setState(() {

    });
  }

  Future _unFollow() async {
    await _databaseMethods.unFollowUser(targetUid:widget.user.uid);
    print("Snd");
    setState(() {

    });
  }
}

import 'package:cached_network_image/cached_network_image.dart';
import 'package:droog/data/constants.dart';
import 'package:droog/models/enums.dart';
import 'package:droog/models/response.dart';
import 'package:droog/models/user.dart';
import 'package:droog/screens/responses_screen.dart';
import 'package:droog/services/database_methods.dart';
import 'package:droog/widgets/expandable_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ResponseTile extends StatefulWidget {
  final Response response;
  final String postByUserName;
  final GlobalKey<ScaffoldState> scaffoldKey;
  Function solutionChanged;
  Function toggleLoading;
  bool isSolution;

  ResponseTile(
      {this.response,
      this.postByUserName,
      this.solutionChanged,
      this.toggleLoading,
      this.isSolution,
      this.scaffoldKey});

  @override
  _ResponseTileState createState() => _ResponseTileState();
}

class _ResponseTileState extends State<ResponseTile> {
  String responses = "6";
  bool _isFirstPress = true;

  DatabaseMethods _databaseMethods = DatabaseMethods();

  Future<User> _getUserDetails() async {
    return await _databaseMethods.getUserDetailsByUid(
        targetUid: widget.response.responseByUid);
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
                          await _databaseMethods.reportAResponse(
                              targetUid: widget.response.responseByUid,
                              responseId: widget.response.document.documentID);
                          Navigator.pop(context);
                        } catch (e) {
                          // TODO
                          widget.scaffoldKey.currentState.showSnackBar(SnackBar(
                            content: Text("Something went wrong"),
                          ));
                          Navigator.pop(context);
                        }
                      },
                      child: ListTile(
                        leading: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Icon(Icons.report, color: Color(0xff4481bc)),
                          ],
                        ),
                        title: Text("Report"),
                        subtitle: Text("This response is inappropriate"),
                      )),
                ],
              ),
            ));
  }

  Widget _buildSolutionButton() {
    return RaisedButton(
      child: FittedBox(
          child: Text(
        "Mark as Solution",
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      )),
      color: Colors.green,
      textColor: Colors.white,
      onPressed: () async {

        try {
          widget.toggleLoading();
          await widget.solutionChanged(
              documentSnapshot: widget.response.document, markAsSolution: true);
          widget.toggleLoading();
        } catch (e) {
          widget.toggleLoading();
          print(e.toString());
        }
      },
    );
  }

  Widget _buildMarkedSolutionButton() {
    return RaisedButton(
      child: FittedBox(child: Icon(Icons.check)),
      color: Theme.of(context).buttonColor,
      textColor: Colors.white,
      onPressed: () async {
        try {
          widget.toggleLoading();
          await widget.solutionChanged(
              documentSnapshot: widget.response.document,
              markAsSolution: false);

          widget.toggleLoading();
        } catch (e) {
          widget.toggleLoading();
          print(e);
        }
      },
    );
  }

  Widget _buildVoteButton() {
    return FutureBuilder<VoteStatus>(
        future: _databaseMethods.checkVoteStatus(
            responseDocument: widget.response.document),
        builder: (context, snapshot) {
          bool voted;
          if (snapshot.data == VoteStatus.alreadyVoted) {
            voted = true;
          } else {
            voted = false;
          }
          String buttonText = voted ? "Un-Vote" : "Vote";
          Color buttonColor = voted ? Colors.lightGreen : Colors.green;

          return RaisedButton(
            child: snapshot.hasData
                ? Text(
                    buttonText,
                    overflow: TextOverflow.ellipsis,
                  )
                : CircularProgressIndicator(),
            color: buttonColor,
            textColor: Colors.white,
            onPressed: () async {
              if (_isFirstPress) {
                widget.toggleLoading();
                _isFirstPress = false;
                if (snapshot.hasData) {
                  try {
                    voted
                        ? await _databaseMethods.voteAResponse(
                            responseDocument: widget.response.document,
                            voteType: VoteType.undoUpVote,
                          )
                        : await _databaseMethods.voteAResponse(
                            responseDocument: widget.response.document,
                            voteType: VoteType.upVote,
                          );
                    setState(() {
                      voted ? widget.response.votes-- : widget.response.votes++;
                    });
                    widget.toggleLoading();
                  } catch (e) {
                    widget.toggleLoading();
                    print(e.toString());
                  }
                }
                _isFirstPress = true;
              }
            },
          );
        });
  }

  Widget _getCenterButton() {
    return (widget.postByUserName == Constants.userName && widget.isSolution)
        ? _buildMarkedSolutionButton()
        : ((widget.postByUserName == Constants.userName && !widget.isSolution)
            ? _buildSolutionButton()
            : _buildVoteButton());
  }
  String getDate(){
    print((DateTime.fromMillisecondsSinceEpoch(
      widget.response.time,
    ).difference(DateTime.now()).inDays*(-1)).toString()+"helyah");
   return DateTime.fromMillisecondsSinceEpoch(
      widget.response.time,
    ).difference(DateTime.now()).inDays*-1 >
        0
        ? DateFormat.MMMd().format(
      DateTime.fromMillisecondsSinceEpoch(
        widget.response.time,
      ),
    )
        : DateFormat("hh:mm a")
        .format(DateTime.fromMillisecondsSinceEpoch(
      widget.response.time,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8 / 2, horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          FutureBuilder<User>(
              future: _getUserDetails(),
              builder: (context, snapshot) {
                return ListTile(
                  leading: snapshot.hasData
                      ? ClipOval(
                          child: CachedNetworkImage(
                            imageUrl: snapshot.data.profilePictureUrl,
//                            loadingBuilder: (BuildContext context, Widget child,
//                                ImageChunkEvent loadingProgress) {
//                              if (loadingProgress == null) return child;
//                              return CircularProgressIndicator(
//                                value: loadingProgress.expectedTotalBytes !=
//                                        null
//                                    ? loadingProgress.cumulativeBytesLoaded /
//                                        loadingProgress.expectedTotalBytes
//                                    : null,
//                              );
//                            },
                          ),
                        )
                      : CircleAvatar(child: Icon(Icons.attachment)),
                  title: snapshot.hasData
                      ? Text(snapshot.data.userName)
                      : Text(""),
                  subtitle: Text(
                   getDate()
                  ),
                  trailing:widget.response.responseByUserName !=  Constants.userName ? IconButton(
                    icon: Icon(Icons.more_vert),
                    onPressed: showOptions,
                  ) : null,
                );
              }),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ExpandableText(
              text: widget.response.response,
            ),
          ),
          widget.response.imageUrl != null
              ? AspectRatio(
                  aspectRatio: 4 / 3,
                  child: CachedNetworkImage(
                    imageUrl: widget.response.imageUrl,
                    progressIndicatorBuilder:
                        (context, child, loadingProgress) {
//                if (loadingProgress == null) return ;
                      return CircularProgressIndicator(
                        value: loadingProgress.totalSize != null
                            ? loadingProgress.progress
                            : null,
                      );
                    },
                    width: double.infinity,
                    fit: BoxFit.fill,
                  ),
                )
              : Container(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Stack(alignment: Alignment.centerLeft,
              children: <Widget>[

                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        FittedBox(child: Icon(Icons.check_circle)),
                        SizedBox(width: 8 / 2),
                        FittedBox(child: Text("${widget.response.votes} Votes")),
                      ],
                    ),



                Row(mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    _getCenterButton(),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

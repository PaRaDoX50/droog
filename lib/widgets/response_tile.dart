import 'package:cached_network_image/cached_network_image.dart';
import 'package:droog/data/constants.dart';
import 'package:droog/models/response.dart';
import 'package:droog/models/user.dart';
import 'package:droog/services/database_methods.dart';
import 'package:droog/widgets/expandable_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ResponseTile extends StatefulWidget {
  final Response response;
  final String postBy;

  ResponseTile({this.response, this.postBy});

  @override
  _ResponseTileState createState() => _ResponseTileState();
}

class _ResponseTileState extends State<ResponseTile> {
  String responses = "6";

  DatabaseMethods _databaseMethods = DatabaseMethods();

  Future<User> _getUserDetails() async {
    return await _databaseMethods.getUserDetailsByUsername(
        targetUserName: widget.response.responseBy);
  }

  Widget _buildSolutionButton() {
    return RaisedButton(
      child: Text("Mark as Solution"),
      color: Theme.of(context).buttonColor,
      textColor: Colors.white,
      onPressed: () async {
        try {
          await _databaseMethods.toggleSolutionForPost(isSolution: true,responseDocument: widget.response.document);
        }  catch (e) {
          print(e.message);
        }
      },
    );
  }

  Widget _buildMarkedSolutionButton() {
    return RaisedButton(
      child: Icon(Icons.check),
      color: Theme.of(context).buttonColor,
      textColor: Colors.white,
      onPressed: () async {
        try {
          await _databaseMethods.toggleSolutionForPost(isSolution: false,responseDocument: widget.response.document);
        }  catch (e) {
          print(e.message);
        }
      },
    );
  }

  Widget _buildVoteButton() {
    return RaisedButton(
      child: Text("Vote"),
      color: Theme.of(context).buttonColor,
      textColor: Colors.white,
      onPressed: () async {
        try {

          await _databaseMethods.voteAResponse(responseDocument: widget.response.document);
          setState(() {
            widget.response.votes++;
          });
        }  catch (e) {
          print(e.message);
        }
      },
    );
  }

  Widget _getCenterButton() {
    return (widget.postBy == Constants.userName && widget.response.isSolution)
        ? _buildMarkedSolutionButton()
        : ((widget.postBy == Constants.userName && !widget.response.isSolution)
            ? _buildSolutionButton()
            : _buildVoteButton());
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
                          child: Image.network(
                            snapshot.data.profilePictureUrl,
                            loadingBuilder: (BuildContext context, Widget child,
                                ImageChunkEvent loadingProgress) {
                              if (loadingProgress == null) return child;
                              return CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes !=
                                        null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes
                                    : null,
                              );
                            },
                          ),
                        )
                      : CircleAvatar(child: Icon(Icons.attachment)),
                  title: snapshot.hasData
                      ? Text(snapshot.data.userName)
                      : Text(""),
                  subtitle: Text(
                    DateFormat.MMMd().format(
                      DateTime.fromMicrosecondsSinceEpoch(
                        widget.response.time,
                      ),
                    ),
                  ),
                  trailing: Icon(Icons.more_vert),
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Icon(Icons.check_circle),
                    Text("${widget.response.votes} votes"),
                  ],
                ),
                _getCenterButton(),
                Icon(Icons.message)
              ],
            ),
          )
        ],
      ),
    );
  }
}

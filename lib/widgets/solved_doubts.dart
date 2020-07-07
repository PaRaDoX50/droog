import 'package:droog/models/post.dart';
import 'package:droog/services/database_methods.dart';
import 'package:droog/widgets/feed_tile.dart';
import 'package:flutter/material.dart';

class SolvedDoubts extends StatelessWidget {

  final targetUid;
  final scaffoldKey;
  SolvedDoubts({this.targetUid,this.scaffoldKey});
  DatabaseMethods _databaseMethods = DatabaseMethods();
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Post>>(
        future: _databaseMethods.getAUsersSolvedDoubts(targetUid: targetUid),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data.isNotEmpty) {
              return SliverList(delegate:SliverChildBuilderDelegate(
                      (_,index){
                    return FeedTile(showBottomOptions: true,feedKey: scaffoldKey,post: snapshot.data[index],);
                  },childCount:snapshot.data.length ));
            }
            else{
              return SliverFillRemaining(child: Center(child: Text("No Posts To Display")),);
            }
          }
          else{
            if(snapshot.connectionState == ConnectionState.done){
              return SliverFillRemaining(child: Center(child: Text("No Posts To Display"),));
            }
            return SliverFillRemaining(child: Center(child: CircularProgressIndicator(),));
          }
        }
    );
  }
}

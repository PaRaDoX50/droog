import 'package:droog/models/user.dart';
import 'package:droog/screens/feed.dart';
import 'package:droog/widgets/profile_container.dart';
import 'package:flutter/material.dart';

class UserProfile extends StatefulWidget {
  @override
  _UserProfileState createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile>
    with TickerProviderStateMixin {



  TabController tabController;

  int selectedTab = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    tabController = TabController(length: 2, vsync: this);
  }

  Widget _buildSelectedTab({BuildContext context, String buttonText}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        height: double.infinity,
        width: double.infinity,
        alignment: Alignment.center,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(50), color: Theme
            .of(context)
            .primaryColor,border: Border.all(width: .1)),
        child: Text(buttonText,style: TextStyle(color: Colors.white),),
        ),
    );
  }

  Widget _buildUnSelectedTab({BuildContext context, String buttonText}) {
    return  Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        height: double.infinity,
        width: double.infinity,
        alignment: Alignment.center,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(50), color:Colors.white,border: Border.all(width: .1)),
        child: Text(buttonText,style: TextStyle(color: Theme.of(context).primaryColor),),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            actions: <Widget>[Icon(Icons.search), Icon(Icons.more_vert)],
          ),
          SliverToBoxAdapter(
            child: ProfileContainer(),
          ),
          SliverToBoxAdapter(
            child: TabBar(

//              indicatorSize: TabBarIndicatorSize.label,
//              indicator: BoxDecoration(
//                  borderRadius: BorderRadius.circular(20),
//                  color: Colors.redAccent),
              indicatorColor: Colors.transparent,
              controller: tabController,
              onTap: (index) {
                setState(() {
                  selectedTab = index;
                });
              },
              unselectedLabelColor: Colors.black,
              tabs: <Widget>[
                Tab(
                    child: selectedTab == 0
                        ? _buildSelectedTab(
                        context: context, buttonText: "Asked")
                        : _buildUnSelectedTab(
                        context: context, buttonText: "Asked")
                ),
                Tab(
                  child: selectedTab == 1
                      ? _buildSelectedTab(
                      context: context, buttonText: "Solved")
                      : _buildUnSelectedTab(
                      context: context, buttonText: "Solved"),
                )
              ],

            ),

          ),
          SliverFillRemaining(child: TabBarView(children: <Widget>[Feed(),Feed()],controller: tabController,),)
        ],
      ),
    );
  }
}

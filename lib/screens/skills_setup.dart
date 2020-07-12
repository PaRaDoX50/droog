import 'package:droog/data/constants.dart';
import 'package:droog/models/enums.dart';
import 'package:droog/models/user.dart';
import 'package:droog/screens/home.dart';
import 'package:droog/services/database_methods.dart';
import 'package:droog/utils/theme_data.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class SkillsSetup extends StatefulWidget {
  static final String route = "/skills_setup";

  @override
  _SkillsSetupState createState() => _SkillsSetupState();
}

class _SkillsSetupState extends State<SkillsSetup> {
  bool _showLoading = false;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  List<dynamic> skills = [];
  List<dynamic> achievements = [];
  TextEditingController skillController = TextEditingController();
  TextEditingController achievementController = TextEditingController();
  DatabaseMethods _databaseMethods = DatabaseMethods();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadInitialData();
  }

  bool addQuality({QualityType qualityType}) {
    if (qualityType == QualityType.skill) {
      if (skills.contains(skillController.text)) {
        _scaffoldKey.currentState
            .showSnackBar(SnackBar(content: Text("Skill already added")));
        return false;
      }

      setState(() {
        skills.add(skillController.text);
        skillController.clear();
      });
      return true;
    }
    else {
      if (skills.contains(achievementController.text)) {
        _scaffoldKey.currentState
            .showSnackBar(SnackBar(content: Text("Achievement already added")));
        return false;
      }

      setState(() {
        achievements.add(achievementController.text);
        achievementController.clear();
      });
      return true;
    }
  }

  deleteQuality({QualityType qualityType, String targetText}) {
    print("hello");
    if (qualityType == QualityType.skill) {
      setState(() {
        skills.removeWhere((element) => element == targetText
        );
      });
    }
    else {
      setState(() {
        achievements.removeWhere((element) => element == targetText
        );
      });
    }
  }

  _buildTextField({QualityType qualityType}) {
    //type 0 == skills type 1 == achievements
    return Row(
      children: <Widget>[
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: 8.0, top: 8, bottom: 8,),
            child: TextField(
              maxLines: 1,
              controller: qualityType == QualityType.skill
                  ? skillController
                  : achievementController,
              decoration: InputDecoration(
                  contentPadding: EdgeInsets.only(left: 8),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  hintText: qualityType == QualityType.skill
                      ? "Skill"
                      : "Achievement"),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
              onTap: () => addQuality(qualityType: qualityType),
              child: Icon(Icons.add_circle_outline)),
        ),
      ],
    );
  }

  submitData() async {
    try {
      setState(() {
        _showLoading = true;
      });
      await _databaseMethods.editSkills(
          skills: skills, achievements: achievements);

      Navigator.pushNamedAndRemoveUntil(context, Home.route,(r) => false);
    } catch (e) {
      // TODO
      print(e.toString());
      setState(() {
        _showLoading = false;
      });
    }
  }

  Future<bool> loadInitialData() async {
    try {
      setState(() {
        _showLoading = true;
      });
      print(Constants.uid + "tryyy");
      User user = await _databaseMethods.getUserDetailsByUid(
          targetUid: Constants.uid);

        skills  = user.skills != null ? user.skills : [];
        achievements = user.achievements != null ? user.achievements : [];
     setState(() {
       _showLoading = false;
     });
      return true;
    } catch (e) {
      setState(() {
        _showLoading = false;
      });
      print(e.toString() + "adsaasd");
      _scaffoldKey.currentState.showSnackBar(
          SnackBar(content: Text(
            "Something went wrong", style: TextStyle(color: Colors.white),),));

      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(elevation: 0,),
        key: _scaffoldKey,

        body:
        Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(stops: [
                0,
                .5,
                1,
              ], colors: [
                Color(0xff1948a0),
                Color(0xff2d63ad),
                Color(0xff4481bc)
              ], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
          child: Stack(
            children: <Widget>[
              Center(
                child: SingleChildScrollView(
                  child: Card(
                    margin: EdgeInsets.all(20),

                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: <Widget>[
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,

                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Text("Skills",
                                style: MyThemeData.blackBold12.copyWith(
                                    fontSize: 20),),

                              Container(

                                  child: Column(
                                    children: [...skills
                                        .map((e) =>
                                        Tile(
                                          qualityType: QualityType.skill,
                                          text: e,
                                          deleteFunction: deleteQuality,))
                                        .toList()
                                    ],)),
                              SizedBox(height: 8,),
                              _buildTextField(
                                  qualityType: QualityType.skill),
                            ],
                          ),

                          SizedBox(height: 16,),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,

                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Text("Achievements",
                                style: MyThemeData.blackBold12.copyWith(
                                    fontSize: 20),),

                              Container(

                                  child: Column(
                                    children: [...achievements.map((e) =>
                                        Tile(
                                          deleteFunction: deleteQuality,
                                          qualityType: QualityType.achievement,
                                          text: e,)).toList()
                                    ],)),
                              SizedBox(height: 8,),
                              _buildTextField(
                                  qualityType: QualityType.achievement),
                            ],

                          ),
                          SizedBox(height: 16,),
                          RaisedButton(
                            child:
                            Text("Submit", style: Theme
                                .of(context)
                                .textTheme
                                .button),
                            color: Theme
                                .of(context)
                                .buttonColor,
                            onPressed: _showLoading == false ? submitData : null,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              _showLoading
                  ? Center(child: CircularProgressIndicator(),)
                  : Container(),
            ],
          ),
        ));


  }
}

class Tile extends StatelessWidget {
  final String text;
  final Function deleteFunction;
  final QualityType qualityType;

  Tile({this.text, this.deleteFunction, this.qualityType});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 30,
      child: ListTile(
        dense: true,
        contentPadding: EdgeInsets.symmetric(horizontal: 0),
        leading: CircleAvatar(child: Center(child: Text("\u2022 ")),
          backgroundColor: Colors.white,),
        title: Text(text, style: MyThemeData.primary14.copyWith(
            fontWeight: FontWeight.bold, fontSize: 16),
          overflow: TextOverflow.ellipsis,),
        trailing: GestureDetector(onTap: () =>
            deleteFunction(qualityType: qualityType, targetText: text),
            child: Icon(Icons.delete)),
      ),
    );
  }
}

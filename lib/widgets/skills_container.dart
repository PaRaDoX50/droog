import 'package:droog/data/constants.dart';
import 'package:droog/screens/skills_setup.dart';
import 'package:droog/utils/theme_data.dart';
import 'package:flutter/material.dart';

class SkillsContainer extends StatefulWidget {

  final List<dynamic> skills;
  final List<dynamic> achievements;
  final String userName;
  SkillsContainer({this.skills,this.achievements,@required this.userName});
  @override
  _SkillsContainerState createState() => _SkillsContainerState();
}

class _SkillsContainerState extends State<SkillsContainer> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal:8),
      child: Card(
        elevation: 5,
        color: Colors.white,

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
             Padding(
               padding: const EdgeInsets.only(left:8.0,top: 8),
               child: Row(
                 children: <Widget>[
                   Text("Skills",style: MyThemeData.blackBold12,),
                   Spacer(),
                   widget.userName ==Constants.userName ?
                   GestureDetector(onTap:(){Navigator.of(context).pushNamed(SkillsSetup.route);},child: Padding(
                     padding: const EdgeInsets.only(right:8.0),
                     child: Icon(Icons.edit,color: Colors.grey,size: 15,),
                   )):Container(),
                 ],
               ),
             ),
            
            ...widget.skills.map((e) => Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text("\u2022 "),
                    FittedBox(child: Text(e,style: TextStyle(color: Colors.blue),)),]

            ),
              )).toList(),
             widget.skills.isEmpty ?  Padding(
               padding: const EdgeInsets.all(8.0),
               child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text("\u2022 "),
                    FittedBox(child: Text("No skills added",style: TextStyle(color: Colors.blue),))
                  ],
                ),
             ):Container(),
            Padding(
              padding: const EdgeInsets.only(left:8.0,),
              child: Text("Achievements",style: MyThemeData.blackBold12,),
            ),
            ...widget.achievements.map((e) => Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text("\u2022 "),
                  FittedBox(child: Text(e,style: TextStyle(color: Colors.blue),)),
                ],
              ),
            ),).toList(),
             widget.achievements.isEmpty ?  Padding(
               padding: const EdgeInsets.all(8.0),
               child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text("\u2022 "),
                    FittedBox(child: Text("No achievements added",style: TextStyle(color: Colors.blue),))
                  ],
                ),
             ):Container(),
          ],
        ),
      ),
    );
  }
}

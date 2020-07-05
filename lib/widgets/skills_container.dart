import 'package:droog/utils/theme_data.dart';
import 'package:flutter/material.dart';

class SkillsContainer extends StatefulWidget {

  final List<dynamic> skills;
  final List<dynamic> achievements;
  SkillsContainer({this.skills,this.achievements});
  @override
  _SkillsContainerState createState() => _SkillsContainerState();
}

class _SkillsContainerState extends State<SkillsContainer> {
  @override
  Widget build(BuildContext context) {
    return Card(color: Colors.white,

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text("Skills",style: MyThemeData.blackBold12,),
          ...widget.skills.map((e) => Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text("\u2022 "),
                Text(e,style: TextStyle(color: Colors.blue),),]
               
          ))).toList(),
           widget.skills.isEmpty ?  Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text("\u2022 "),
                Text("No skills added",style: TextStyle(color: Colors.blue),)
              ],
            ):Container(),
          Text("Achievements",style: MyThemeData.blackBold12,),
          ...widget.skills.map((e) => Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text("\u2022 "),
                Text(e,style: TextStyle(color: Colors.blue),),
              ],
            ),
          ),).toList(),
           widget.achievements.isEmpty ?  Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text("\u2022 "),
                Text("No achievements added",style: TextStyle(color: Colors.blue),)
              ],
            ):Container(),
        ],
      ),
    );
  }
}

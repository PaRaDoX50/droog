import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:droog/widgets/skills_container.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ProfileContainer extends StatelessWidget {
  Image image = Image.asset("assets/images/droog_logo.png");
  String userName = "suryansht_";
  String firstName = "Suryansh";
  String lastName = "Tomar";
  String buttonText = "Join";
  String description = "Hello guyz, here comes bio.";
  String askedCount = "20";
  String droogsCount = "250";
  String solvedCount = "120";

  @override
  Widget build(BuildContext context) {
    return  ColumnSuper(
      innerDistance: -30,


            children: <Widget>[

              Container(
                color: Theme.of(context).primaryColor,
                child: Padding(
                  padding: const EdgeInsets.only(left:16.0,right:16,bottom: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[


                      ListTile(
                        leading: ClipOval(
                          child: image,
                        ),
                        title: Text(userName,style: TextStyle(color: Colors.white),),
                        subtitle: Text("$firstName $lastName",style: TextStyle(color: Colors.white),),
                        trailing: RaisedButton(
                          onPressed: () {},
                          child: Text(
                            buttonText,
                            style: Theme.of(context).textTheme.button,
                          ),
                        ),
                      ),
                      SizedBox(height: 16,),
                      Text(description,style: TextStyle(color: Colors.white),),
                      SizedBox(height: 16,),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Column(
                            children: <Widget>[Text("Droogs",style: TextStyle(color: Colors.white),), Text(droogsCount,style: TextStyle(color: Colors.white),)],
                          ),
                          Column(
                            children: <Widget>[Text("Asked",style: TextStyle(color: Colors.white),), Text(askedCount,style: TextStyle(color: Colors.white),)],
                          ),
                          Column(
                            children: <Widget>[Text("Solved",style: TextStyle(color: Colors.white),), Text(solvedCount,style: TextStyle(color: Colors.white),)],
                          ),
                        ],
                      ),
                      SizedBox(height: 30,),
                    ],
                  ),
                ),
              ),

                      SizedBox(
                        width: double.infinity,
                        child: SkillsContainer(
                            skills: ["Xyz",],
                            achievements: ["Xyz",],
                          ),
                      ),




            ],
          );
  }
}

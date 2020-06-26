import 'package:droog/models/enums.dart';

class Update{
  UpdateType updateType;
  String userInvolved;
  String uidInvolved;
  String responseId;
  String postInvolved;
  int time;

  Update({this.uidInvolved,this.updateType,this.userInvolved,this.responseId,this.postInvolved,this.time});
}
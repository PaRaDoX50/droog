class SliderData {
  String body;
  String imagePath;

  SliderData({this.imagePath, this.body});
}

List<SliderData> get getSliderData {
  List<SliderData> list = [
    SliderData(
        body:
            "Connect With Your Friends, Family And Professionals On The Single Platform",
        imagePath: "assets/images/intro_1.jpg"),
    SliderData(
        body:
            "Create Groups, Classes, or Teams for different purposes. Droog is Its Team is happy To serve.",
        imagePath: "assets/images/intro_2_temp.jpg"),
    SliderData(
        body:
            '''Call For Meetings, Classes, Lecture In A Single Click. Droog Is A One For All Tool.
You Can Also Take Online Classes and Meetings.''',
        imagePath: "assets/images/intro_3.jpg"),
    SliderData(
        body:
            "You Can Also Create TO-DO Task For Your Classes and Groups.Feature Is Gonna  be Live Soon.",
        imagePath: "assets/images/intro_4.jpg"),
    SliderData(
        body:
            "Here Comes Most Important Feature. You Can Even Chat With your Friends. Droog Is Fit For All.",
        imagePath: "assets/images/intro_5.jpg"),

  ];
  return list;
}

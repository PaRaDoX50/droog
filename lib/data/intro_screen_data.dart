class SliderData {
  String body;
  String imagePath;

  SliderData({this.imagePath, this.body});
}

List<SliderData> get getSliderData {
  List<SliderData> list = [
    SliderData(
        body:
            "Connect with batch mates and teachers",
        imagePath: "assets/images/intro1.png"),
    SliderData(
        body:
            "Build your profile",
        imagePath: "assets/images/intro2.jpg"),
    SliderData(
        body:"Clear doubts over chat",
        imagePath: "assets/images/intro3.png"),
    SliderData(
        body:
            "Post and answer queries",
        imagePath: "assets/images/intro4.png"),
    SliderData(
        body:"Get recognized as a Teacher and a Student",
        imagePath: "assets/images/intro5.png"),

  ];
  return list;
}

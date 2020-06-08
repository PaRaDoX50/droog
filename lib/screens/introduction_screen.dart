import 'package:droog/data/intro_screen_data.dart';
import 'package:droog/screens/signup.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class IntroductionScreen extends StatefulWidget {
  @override
  _IntroductionScreenState createState() => _IntroductionScreenState();
}

class _IntroductionScreenState extends State<IntroductionScreen> {
  List<SliderData> listData;
  int currentIndex = 0;
  PageController pageController = PageController();
  Image droogLogo;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    listData = getSliderData;
    droogLogo = Image.asset(
      "assets/images/droog_logo.png",
      height: 70,
      width: 70,
      cacheHeight: 512,
      cacheWidth: 512,
    );
  }

  @override
  Widget build(BuildContext context) {
    precacheImage(droogLogo.image, context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: PageView.builder(
        controller: pageController,
        onPageChanged: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        itemBuilder: (ctx, index) {
          return SliderTile(
            body: listData[index].body,
            imagePath: listData[index].imagePath,
            logo: droogLogo,
          );
        },
        itemCount: listData.length,
      ),
      bottomSheet: currentIndex != listData.length - 1
          ? Container(
              color: Color(0Xffdf1d38),
              child: Padding(
                padding: const EdgeInsets.only(
                    top: 8.0, left: 8, right: 8, bottom: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    GestureDetector(
                      onTap: () => pageController.animateToPage(
                          listData.length - 1,
                          duration: Duration(milliseconds: 400),
                          curve: Curves.linear),
                      child: Text(
                        "Skip",
                        style: TextStyle(fontSize: 25, color: Colors.white),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => pageController.animateToPage(
                          currentIndex + 1,
                          duration: Duration(milliseconds: 400),
                          curve: Curves.linear),
                      child: Text(
                        "Next",
                        style: TextStyle(fontSize: 25, color: Colors.white),
                      ),
                    )
                  ],
                ),
              ),
            )
          : Container(
              width: double.infinity,
              color: Color(0Xffdf1d38),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: GestureDetector(
                  onTap: () =>
                      Navigator.pushReplacementNamed(context, SignUp.route),
                  child: Text(
                    "Done",
                    style: TextStyle(fontSize: 25, color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
    );
  }
}

class SliderTile extends StatelessWidget {
  final String body;
  final String imagePath;
  final Image logo;

  SliderTile({this.body, this.imagePath, this.logo});

  TextStyle textStyle = TextStyle(
    fontSize: 19,
    color: Color(0xfffdf9f9),
    fontWeight: FontWeight.w400,
  );

  @override
  Widget build(BuildContext context) {
    final heightAvailable =
        MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top;
    return Padding(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Image.asset(
            imagePath,
            width: double.infinity,
            height: (heightAvailable) * .6,
          ),
          Stack(
            overflow: Overflow.visible,
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(8),
                height: (heightAvailable) * .3,
                width: double.infinity,
                child: Center(
                    child: Text(
                  body,
                  style: textStyle,
                  textAlign: TextAlign.center,
                )),
                decoration: BoxDecoration(
                  color: Color(0Xffdf1d38),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
              ),
              Positioned(
                left: MediaQuery.of(context).size.width / 2 - 35,
                top: -35,
                child: logo,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

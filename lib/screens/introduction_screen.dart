import 'package:dots_indicator/dots_indicator.dart';
import 'package:droog/data/intro_screen_data.dart';
import 'package:droog/screens/signup.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

int currentIndex = 0;
PageController pageController = PageController();
Image droogLogo;
List<SliderData> listData;

class IntroductionScreen extends StatefulWidget {
  @override
  _IntroductionScreenState createState() => _IntroductionScreenState();
}

class _IntroductionScreenState extends State<IntroductionScreen> {
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
      bottomSheet: currentIndex == listData.length - 1
          ? GestureDetector(
        onTap: ()=>Navigator.pushReplacementNamed(context, SignUp.route),
            child: Container(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text("Done",style: TextStyle(color: Colors.white),),
                  ),
                ),
                color: Theme.of(context).buttonColor,
                width: double.infinity,
                height: 50,
              ),
          )
          : Container(
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: DotsIndicator(
                      dotsCount: 5,
                      position: currentIndex.toDouble(),
                    ),
                  ),
                ],
              ),
            ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            PageView.builder(
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
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "droog",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                        fontSize: 80 / 2,),
                  ),
                ),
              ],
            )
          ],
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
    return Center(
      child: Padding(
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Image.asset(
              imagePath,
              width: double.infinity,
              height: (heightAvailable) * .6,
            ),
            FittedBox(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
              body,
              style: TextStyle(
                  fontSize: 16,
              ),
            ),
                )),
          ],
        ),
      ),
    );
  }
}

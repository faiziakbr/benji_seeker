import 'package:benji_seeker/My_Widgets/MyDarkButton.dart';
import 'package:benji_seeker/constants/MyColors.dart';
import 'package:benji_seeker/custom_texts/QuicksandText.dart';
import 'package:dots_indicator/dots_indicator.dart' as dotIndicator;
import 'package:flutter/material.dart';

class IntroPage extends StatefulWidget {
  @override
  _IntroPageState createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> {
  double _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    return Scaffold(
      body: SafeArea(
        child: Container(
          width: mediaQueryData.size.width,
          margin: EdgeInsets.only(
              top: 16.0,
              left: mediaQueryData.size.width * 0.05,
              right: mediaQueryData.size.width * 0.05,
              bottom: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              RichText(
                maxLines: 1,
                textScaleFactor: 1.0,
                text: TextSpan(
                    text: "Welcome to ",
                    style: TextStyle(
                        fontSize: 32,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontFamily: "Quicksand"),
                    children: <TextSpan>[
                      TextSpan(text: "ben", style: labelTextStyle()),
                      TextSpan(
                          text: "j",
                          style: TextStyle(
                              color: orangeColor,
                              fontFamily: "Quicksand",
                              fontSize: 32)),
                      TextSpan(text: "i", style: labelTextStyle())
                    ]),
              ),
              Expanded(
                child: Column(
                  children: <Widget>[
                    Container(
                      width: mediaQueryData.size.width,
                      height: mediaQueryData.size.height * 0.7,
                      child: PageView(
                        children: <Widget>[
                          _scrollableItem(
                              mediaQueryData,
                              "assets/info_1.png",
                              "The Sustainable Mowing App",
                              "is helping the world by bringing together home-owners and lawn technicians for ALL ELECTRIC mowing!",
                              showBenjiLogo: true),
                          _scrollableItem(
                              mediaQueryData,
                              "assets/info_2.png",
                              "Why Electric?",
                              "Battery technology has changed the world. Electric mowers are stronger, quieter, require less maintenance AND…zero emission!"),
                          _scrollableItem(
                              mediaQueryData,
                              "assets/intro_page.png",
                              "Plan All Your Tasks For The Year",
                              "benji™ makes it easy to manage your lawn mowing...and many other tasks.",
                              showBenjiLogo: true),
                        ],
                        onPageChanged: (index) {
                          setState(() {
                            _currentIndex = double.parse(index.toString());
                          });
                        },
                      ),
                    ),
                    dotIndicator.DotsIndicator(
                      decorator:
                      dotIndicator.DotsDecorator(activeColor: Colors.black),
                      dotsCount: 3,
                      position: _currentIndex,
                    ),
                  ],
                ),
              ),
              Container(
                  width: mediaQueryData.size.width,
                  height: 50,
                  child: MyDarkButton("GET STARTED", () {
//                    Navigator.push(context,
//                        MaterialPageRoute(builder: (context) => BriefPage()));
                  }))
            ],
          ),
        ),
      ),
    );
  }

  TextStyle labelTextStyle() {
    return TextStyle(
        color: accentColor,
        fontFamily: "Quicksand",
        fontWeight: FontWeight.bold,
        fontSize: 32);
  }

  Widget _scrollableItem(MediaQueryData mediaQueryData, String image,
      String title, String description,
      {bool showBenjiLogo = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Image.asset(
          "$image",
          width: mediaQueryData.size.width,
          height: mediaQueryData.size.height * 0.3,
        ),
        QuicksandText(
          "$title",
          28,
          Colors.black,
          FontWeight.bold,
          top: 16.0,
          bottom: 16.0,
        ),
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
              text: showBenjiLogo ? "benji\u2122 " : "",
              style: _customText(showAccentColor: true),
              children: <TextSpan>[
                TextSpan(
                  text: "$description",
                  style: _customText(),
                )
              ]),
        ),
//        MontserratText(
//          "$description",
//          14,
//          lightTextColor,
//          FontWeight.normal,
//          textAlign: TextAlign.center,
//          top: 16.0,
//        )
      ],
    );
  }

  TextStyle _customText({bool showAccentColor = false}) {
    return TextStyle(
      fontWeight: FontWeight.normal,
      color: showAccentColor ? accentColor : Colors.black,
      fontFamily: "Montserrat",
      fontSize: 14.0,
    );
  }
}

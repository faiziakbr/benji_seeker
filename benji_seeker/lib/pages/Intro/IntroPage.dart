import 'package:benji_seeker/My_Widgets/MyDarkButton.dart';
import 'package:benji_seeker/SharedPref/SavedData.dart';
import 'package:benji_seeker/constants/Constants.dart';
import 'package:benji_seeker/constants/MyColors.dart';
import 'package:benji_seeker/custom_texts/QuicksandText.dart';
import 'package:benji_seeker/pages/GettingStarted/PhoneNumberPage.dart';
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
          margin: EdgeInsets.only(top: 16.0, bottom: 16.0),
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
                      margin: EdgeInsets.only(
                          left: mediaQueryData.size.width * 0.05,
                          right: mediaQueryData.size.width * 0.05),
                      child: PageView(
                        children: <Widget>[
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Image.asset(
                                "assets/info_1.png",
                                width: mediaQueryData.size.width,
                                height: mediaQueryData.size.height * 0.3,
                                fit: BoxFit.cover,
                              ),
                              QuicksandText(
                                "The \"Get Things Done\" App",
                                28,
                                Colors.black,
                                FontWeight.bold,
                                top: 16.0,
                              ),
                              QuicksandText(
                                "(sustainably)",
                                16,
                                Colors.black,
                                FontWeight.bold,
                                bottom: 16.0,
                              ),
                              RichText(
                                textAlign: TextAlign.center,
                                text: TextSpan(
                                    text: "benji\u2122 ",
                                    style: _customText(showAccentColor: true),
                                    children: <TextSpan>[
                                      TextSpan(
                                        text:
                                            "makes it easy to get all your tasks done while taking care of the planet.",
                                        style: _customText(),
                                      )
                                    ]),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Image.asset(
                                "assets/info_2.png",
                                width: mediaQueryData.size.width,
                                height: mediaQueryData.size.height * 0.3,
                                fit: BoxFit.cover,
                              ),
                              QuicksandText(
                                "Schedule Your Entire Year Of Tasks",
                                28,
                                Colors.black,
                                FontWeight.bold,
                                top: 16.0,
                                bottom: 16.0,
                              ),
                              RichText(
                                textAlign: TextAlign.center,
                                text: TextSpan(children: <TextSpan>[
                                  TextSpan(
                                    text: "With ",
                                    style: _customText(),
                                  ),
                                  TextSpan(
                                    text: "benji™ ",
                                    style: _customText(showAccentColor: true),
                                  ),
                                  TextSpan(
                                    text:
                                        "you never have to chase down another handyman. benji™ lets you schedule all your tasks at once - with Certified Home Techs!",
                                    style: _customText(),
                                  ),
                                ]),
                              ),
                            ],
                          ),
                          _scrollableItem(
                              mediaQueryData,
                              "assets/intro_page.png",
                              "Sustainably?",
                              "Certified Home Technicians™ are trained to use products, equipment and techniques that reduce energy and help us all breathe easier.",
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
                  margin: EdgeInsets.only(
                      left: mediaQueryData.size.width * 0.05,
                      right: mediaQueryData.size.width * 0.05),
                  height: 50,
                  child: MyDarkButton("GET STARTED", () {
                    SavedData savedData = SavedData();
                    savedData.setBoolValue(SHOW_INTRO, false);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => PhoneNumberPage()));
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
          fit: BoxFit.cover,
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

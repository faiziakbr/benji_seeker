import 'package:benji_seeker/constants/MyColors.dart';
import 'package:benji_seeker/custom_texts/MontserratText.dart';
import 'package:flutter/material.dart';

class WorkMenuPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    return Stack(
      children: <Widget>[
        Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              basicText("Overview"),
              basicText("How it works"),
              basicText("How to sign up"),
              basicText("Work in your city"),
            ],
          ),
        ),
        Positioned(
          bottom: mediaQueryData.size.height * 0.01,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              bottomText("assets/feedback.png", "Help center"),
              bottomText("assets/feedback.png", "English"),
              bottomText("assets/feedback.png", "New York, USA"),
            ],
          ),
        )
      ],
    );
  }

  Widget basicText(String text) {
    return MontserratText(
      text,
      20,
      lightTextColor,
      FontWeight.w600,
      top: 16.0,
    );
  }

  Widget bottomText(String image, String text) {
    return Row(
      children: <Widget>[
        Image.asset(
          image,
          width: 40,
          height: 40,
        ),
        MontserratText(
          text,
          16,
          Colors.black,
          FontWeight.bold,
          left: 8.0,
        )
      ],
    );
  }
}
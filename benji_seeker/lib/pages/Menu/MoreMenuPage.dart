import 'package:benji_seeker/constants/MyColors.dart';
import 'package:benji_seeker/custom_texts/MontserratText.dart';
import 'package:flutter/material.dart';

class MoreMenuPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          basicText("About us"),
          basicText("How BNJI works"),
          basicText("BNJI services"),
          basicText("Community"),
        ],
      ),
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
}

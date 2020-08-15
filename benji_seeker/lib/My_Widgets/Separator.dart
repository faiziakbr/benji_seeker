import 'package:benji_seeker/constants/MyColors.dart';
import 'package:flutter/material.dart';

class Separator extends StatelessWidget {
  final double topMargin;
  final double rightMargin;
  final double leftMargin;
  final double bottomMargin;


  Separator({this.topMargin = 8.0, this.leftMargin = 8.0, this.rightMargin = 8.0, this.bottomMargin = 8.0});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: topMargin, right: rightMargin, left: leftMargin, bottom: bottomMargin),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.0),
          color: unfilledProgressColor),
      height: 2.0,
    );
  }
}

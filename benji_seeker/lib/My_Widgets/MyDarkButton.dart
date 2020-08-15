import 'package:benji_seeker/constants/MyColors.dart';
import 'package:flutter/material.dart';

class MyDarkButton extends StatelessWidget {
  final String text;
  final Color color;
  final double textSize;
  final FontWeight fontWeight;
  final Function onClick;

  MyDarkButton(this.text, this.onClick,
      {this.color = accentColor,
        this.fontWeight = FontWeight.w600,
        this.textSize = 14});

  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      color: color,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
      onPressed: onClick,
      child: Text(
        "$text",
        style: TextStyle(
            fontFamily: 'Montserrat',
            color: Colors.white,
            fontWeight: fontWeight,
            fontSize: textSize),
      ),
    );
  }
}

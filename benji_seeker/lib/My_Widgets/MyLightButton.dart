import 'package:benji_seeker/constants/MyColors.dart';
import 'package:flutter/material.dart';

class MyLightButton extends StatelessWidget {
  final String text;
  final Function onClick;
  final Color textColor;
  final FontWeight fontWeight;
  final Color borderColor;

  MyLightButton(this.text, this.onClick, {this.textColor = Colors.white, this.fontWeight = FontWeight.normal, this.borderColor = accentColor} );

  @override
  Widget build(BuildContext context) {
    return Container(
      child: RaisedButton(
        color: Colors.white,
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0), side: BorderSide(color: borderColor)),
        onPressed: onClick,
        child: Text(
          "$text",
          style: TextStyle(fontFamily: 'Montserrat', color: textColor, fontWeight: fontWeight),
        ),
      ),
    );
  }
}
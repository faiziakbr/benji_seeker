import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class MontserratText extends StatelessWidget {
  final String text;
  final double size;
  final Color textColor;
  final FontWeight fontWeight;
  final TextAlign textAlign;
  final int maxLines;
  final TextOverflow textOverflow;
  final double left;
  final double right;
  final double top;
  final double bottom;
  final bool underline;

  MontserratText(this.text, this.size, this.textColor, this.fontWeight,
      {this.textAlign = TextAlign.start,
        this.maxLines,
        this.textOverflow,
        this.left = 0,
        this.right = 0,
        this.top = 0,
        this.bottom = 0,
        this.underline = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin:
      EdgeInsets.only(left: left, right: right, top: top, bottom: bottom),
      child: AutoSizeText(
        text,
        style: TextStyle(
            color: textColor,
            fontSize: size,
            fontWeight: fontWeight,
            decoration:
            underline ? TextDecoration.underline : TextDecoration.none,
            fontFamily: "Montserrat"),
        textAlign: textAlign,
        overflow: textOverflow,
        maxLines: maxLines,
      ),
    );
  }
}

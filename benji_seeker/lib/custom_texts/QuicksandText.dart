import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class QuicksandText extends StatelessWidget {
  final String text;
  final double size;
  final Color textColor;
  final FontWeight fontWeight;
  final int maxLines;
  final TextOverflow textOverflow;
  final TextAlign textAlign;
  final double left;
  final double right;
  final double top;
  final double bottom;

  QuicksandText(this.text, this.size, this.textColor, this.fontWeight,
      {this.maxLines = 1,
        this.textOverflow = TextOverflow.ellipsis,
        this.textAlign = TextAlign.start,
        this.left = 0,
        this.right = 0,
        this.top = 0,
        this.bottom = 0});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: left, right: right, top: top, bottom: bottom),
      child: AutoSizeText(
        text,
        style: TextStyle(
            color: textColor,
            fontSize: size,
            fontWeight: fontWeight,
            fontFamily: "Quicksand"),
        maxLines: maxLines,
        overflow: textOverflow,
        textAlign: textAlign,
      ),
    );
  }
}

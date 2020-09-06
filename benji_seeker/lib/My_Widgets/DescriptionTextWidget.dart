import 'package:benji_seeker/constants/MyColors.dart';
import 'package:benji_seeker/custom_texts/MontserratText.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class DescriptionTextWidget extends StatefulWidget {
  final String text;

  DescriptionTextWidget({@required this.text});

  @override
  _DescriptionTextWidgetState createState() => _DescriptionTextWidgetState();
}

class _DescriptionTextWidgetState extends State<DescriptionTextWidget> {
  String firstHalf;
  String secondHalf;

  bool flag = true;

  @override
  void initState() {
    if (widget.text.length > 50) {
      firstHalf = widget.text.substring(0, 50);
      secondHalf = widget.text.substring(50, widget.text.length);
    } else {
      firstHalf = widget.text;
      secondHalf = "";
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
      child: secondHalf.isEmpty
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.menu,
                  color: accentColor,
                  size: 20,
                ),
                Flexible(
                  child: MontserratText(
                    firstHalf,
                    14,
                    lightTextColor,
                    FontWeight.normal,
                    left: 4.0,
                    bottom: 16.0,
                  ),
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.menu,
                      color: accentColor,
                      size: 20,
                    ),
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 4.0),
                        child: RichText(
                          text: TextSpan(
                              text: flag
                                  ? (firstHalf + "...")
                                  : (firstHalf + secondHalf),style: _labelStyle(lightTextColor),
                              children: [
                                TextSpan(
                                    text: flag ? " show more" : " show less",
                                    style: _labelStyle(Colors.blue), recognizer: TapGestureRecognizer()..onTap = (){
                                  setState(() {
                                    flag = !flag;
                                  });
                                })
                              ]),
                        ),
                      ),
                    )
//                    Flexible(
//                      child: MontserratText(
//                        flag ? (firstHalf + "...") : (firstHalf + secondHalf),
//                        14,
//                        lightTextColor,
//                        FontWeight.normal,
//                        left: 4.0,
//                      ),
//                    ),
//                    InkWell(
//                      child: new Row(
//                        mainAxisAlignment: MainAxisAlignment.end,
//                        children: <Widget>[
//                          MontserratText(
//                            flag ? "show more" : "show less",
//                            14, Colors.blue, FontWeight.normal, bottom: 16.0, top: 4.0,
//                          ),
//                        ],
//                      ),
//                      onTap: () {
//                        setState(() {
//                          flag = !flag;
//                        });
//                      },
//                    ),
                  ],
                ),
              ],
            ),
    );
  }

  TextStyle _labelStyle(Color textColor) {
    return TextStyle(
        color: textColor,
        fontSize: 16,
        fontWeight: FontWeight.normal,
        fontFamily: "Montserrat");
  }
}

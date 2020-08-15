import 'package:benji_seeker/constants/MyColors.dart';
import 'package:benji_seeker/custom_texts/MontserratText.dart';
import 'package:benji_seeker/custom_texts/QuicksandText.dart';
import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';

import 'DatePicker.dart';

class TimePicker extends StatefulWidget {
  @override
  _TimePickerState createState() => _TimePickerState();
}

class _TimePickerState extends State<TimePicker> {
  int _hourValue = 1;
  int _minuteValue = 30;

  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: Colors.black,
            ),
            onPressed: null),
        title:
            MontserratText("Set start time", 20, Colors.black, FontWeight.w500),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0.0,
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.close,
              color: Colors.black,
            ),
            onPressed: () {},
          )
        ],
      ),
      backgroundColor: Colors.white,
      body: Container(
        height: mediaQueryData.size.height,
        width: mediaQueryData.size.width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            QuicksandText(
              "Today, 5 March",
              22,
              accentColor,
              FontWeight.bold,
              textAlign: TextAlign.center,
            ),
            Stack(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Container(
                      width: mediaQueryData.size.width * 0.5,
                      alignment: Alignment.centerRight,
                      child: NumberPicker.integer(
                          zeroPad: true,
                          initialValue: _hourValue,
                          minValue: 1,
                          maxValue: 24,
                          highlightSelectedValue: false,
                          itemExtent: mediaQueryData.size.height * 0.2,
                          infiniteLoop: true,
                          onChanged: (value) {
                            setState(() {
                              _hourValue = value;
                            });
                          }),
                    ),
                    Container(
                      width: mediaQueryData.size.width * 0.5,
                      alignment: Alignment.centerLeft,
                      child: NumberPicker.integer(
                          zeroPad: false,
                          initialValue: _minuteValue,
                          minValue: 0,
                          maxValue: 59,
                          highlightSelectedValue: false,
                          itemExtent: mediaQueryData.size.height * 0.2,
                          infiniteLoop: true,
                          onChanged: (value) {
                            setState(() {
                              _minuteValue = value;
                            });
                          }),
                    )
                  ],
                ),
                Positioned(
                  top: mediaQueryData.size.height * 0.23,
                  child: Container(
                      width: mediaQueryData.size.width,
                      height: mediaQueryData.size.height * 0.1,
                      alignment: Alignment.center,
                      padding: EdgeInsets.only(
                          left: mediaQueryData.size.width * 0.05,
                          right: mediaQueryData.size.width * 0.05),
                      child: Container(
                        height: mediaQueryData.size.height * 0.1,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            color: orangeColor),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            MontserratText(
                                _hourValue < 10
                                    ? "0$_hourValue"
                                    : "$_hourValue",
                                32,
                                Colors.white,
                                FontWeight.w600),
                            SizedBox(width: mediaQueryData.size.width * 0.07,),
                            MontserratText(
                                ":", 32, Colors.white, FontWeight.w600),
                            SizedBox(width: mediaQueryData.size.width * 0.07,),
                            MontserratText(
                                _minuteValue < 10
                                    ? "0$_minuteValue"
                                    : "$_minuteValue",
                                32,
                                Colors.white,
                                FontWeight.w600),
                          ],
                        ),
                      )),
                )
              ],
            ),
            Container(
              width: mediaQueryData.size.width,
              height: 60,
              margin: EdgeInsets.only(
                  left: mediaQueryData.size.height * 0.05,
                  right: mediaQueryData.size.height * 0.05,
                  bottom: mediaQueryData.size.height * 0.01),
              child: RaisedButton(
                  color: accentColor,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0)),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => DatePicker()));
                  },
                  child: MontserratText(
                      "SAVE & CONTINUE", 14, Colors.white, FontWeight.w300)),
            ),
          ],
        ),
      ),
    );
  }
}

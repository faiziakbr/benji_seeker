import 'package:benji_seeker/constants/MyColors.dart';
import 'package:benji_seeker/custom_texts/MontserratText.dart';
import 'package:benji_seeker/custom_texts/QuicksandText.dart';
import 'package:flutter/material.dart';

import 'Calender/When.dart';

class OrderPage5 extends StatefulWidget {
  @override
  _OrderPage5State createState() => _OrderPage5State();
}

class _OrderPage5State extends State<OrderPage5> {
  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    return Scaffold(
      body: SafeArea(
        child: Container(
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Visibility(
                  visible: true,
                  child: Container(
                    width: mediaQueryData.size.width,
                    height: mediaQueryData.size.height * 0.1,
                    padding: EdgeInsets.all(8.0),
                    color: separatorColor,
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: QuicksandText(
                            "Lets find you someone to take care of your lawn",
                            18,
                            Colors.white,
                            FontWeight.bold,
                            maxLines: 3,
                          ),
                        ),
                        IconButton(
                          onPressed: () {},
                          icon: Icon(
                            Icons.close,
                            color: Colors.white,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(
                      horizontal: mediaQueryData.size.width * 0.05),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                          margin: EdgeInsets.only(
                              top: mediaQueryData.size.height * 0.03),
                          child: QuicksandText(
                              "Where?", 18, Colors.black, FontWeight.bold)),
                      Container(
                        margin: EdgeInsets.only(
                            top: mediaQueryData.size.height * 0.005),
                        child: MontserratText(
                            "Tell us where your lawn is located.",
                            14,
                            separatorColor,
                            FontWeight.w400),
                      ),
                      Container(
                        margin: EdgeInsets.only(
                            top: mediaQueryData.size.height * 0.005),
                        child: RaisedButton(
                          padding: EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 8.0),
                          color: accentColor,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0)),
                          onPressed: () {},
                          child: MontserratText(
                              "ADD ADDRESS", 14, Colors.white, FontWeight.w500),
                        ),
                      ),
                      Container(
                        height: 2.0,
                        color: lightSeparatorColor,
                        margin: EdgeInsets.only(
                            top: mediaQueryData.size.height * 0.02),
                      )
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(
                      horizontal: mediaQueryData.size.width * 0.05),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                          margin: EdgeInsets.only(
                              top: mediaQueryData.size.height * 0.03),
                          child: QuicksandText(
                              "When?", 18, Colors.black, FontWeight.bold)),
                      Container(
                        margin: EdgeInsets.only(
                            top: mediaQueryData.size.height * 0.005),
                        child: MontserratText(
                            "Tell us when you want your lawn mowed",
                            14,
                            separatorColor,
                            FontWeight.w400),
                      ),
                      Container(
                        margin: EdgeInsets.only(
                            top: mediaQueryData.size.height * 0.005),
                        child: RaisedButton(
                          padding: EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 8.0),
                          color: accentColor,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0)),
                          onPressed: () {
//                            Navigator.push(context,
//                                MaterialPageRoute(builder: (context) => When()));
                          },
                          child: MontserratText("SET DATE AND TIME", 14,
                              Colors.white, FontWeight.w500),
                        ),
                      ),
                      Container(
                        height: 2.0,
                        color: lightSeparatorColor,
                        margin: EdgeInsets.only(
                            top: mediaQueryData.size.height * 0.02),
                      )
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(
                      horizontal: mediaQueryData.size.width * 0.05),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                          margin: EdgeInsets.only(
                              top: mediaQueryData.size.height * 0.03),
                          child: QuicksandText("Show us some pictures", 18,
                              Colors.black, FontWeight.bold)),
                      Container(
                        margin: EdgeInsets.only(
                            top: mediaQueryData.size.height * 0.005),
                        child: MontserratText(
                            "Upload some pictures of your lawn for better understanding.",
                            14,
                            separatorColor,
                            FontWeight.w400),
                      ),
                      Container(
                        margin: EdgeInsets.only(
                            top: mediaQueryData.size.height * 0.005),
                        child: RaisedButton(
                          padding: EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 8.0),
                          color: accentColor,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0)),
                          onPressed: () {},
                          child: MontserratText(
                              "UPLOAD PHOTOS", 14, Colors.white, FontWeight.w500),
                        ),
                      ),
                      Container(
                        height: 2.0,
                        color: lightSeparatorColor,
                        margin: EdgeInsets.only(
                            top: mediaQueryData.size.height * 0.02),
                      )
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(
                      horizontal: mediaQueryData.size.width * 0.05),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                          margin: EdgeInsets.only(
                              top: mediaQueryData.size.height * 0.03),
                          child: QuicksandText("Tell us about this job", 18,
                              Colors.black, FontWeight.bold)),
                      Container(
                        margin: EdgeInsets.only(
                            top: mediaQueryData.size.height * 0.005),
                        child: TextField(),
                      ),
                      Container(
                        height: 2.0,
                        color: lightSeparatorColor,
                        margin: EdgeInsets.only(
                            top: mediaQueryData.size.height * 0.02),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:auto_size_text/auto_size_text.dart';
import 'package:benji_seeker/constants/MyColors.dart';
import 'package:flutter/material.dart';

import 'OrderPage5.dart';

class OrderPage4 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
                stops: [0.2, 0.3],
                colors: [whiteColor, lightGreenBackgroundColor],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                height: 5.0,
                color: accentColor,
                width: mediaQueryData.size.width,
              ),
              Container(
                height: mediaQueryData.size.height * 0.9,
                padding: EdgeInsets.only(
                  top: mediaQueryData.size.width * 0.05,
                  left: mediaQueryData.size.width * 0.05,
                  right: mediaQueryData.size.width * 0.05,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        IconButton(
                          icon: Icon(Icons.arrow_back),
                          padding: EdgeInsets.all(0.0),
                          alignment: Alignment.topLeft,
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                        AutoSizeText(
                          "Small Grass - 3 hours",
                          style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 20.0 + mediaQueryData.textScaleFactor,
                              color: Color.fromRGBO(76, 82, 100, 1)),
                          maxLines: 1,
                        ),
                      ],
                      crossAxisAlignment: CrossAxisAlignment.start,
                    ),

//                  SizedBox(height: mediaQueryData.size.height * 0.05,),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              AutoSizeText(
                                "\$50",
                                style: TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontSize:
                                        38.0 * mediaQueryData.textScaleFactor,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold),
                              ),
                              AutoSizeText(
                                "approx",
                                style: TextStyle(
                                    fontSize:
                                        16.0 * mediaQueryData.textScaleFactor,
                                    fontWeight: FontWeight.w400),
                              )
                            ],
                          ),
//                  SizedBox(height: mediaQueryData.size.height * 0.05,),
                          RichText(
                            text: TextSpan(
                                text: "Note: ",
                                style: TextStyle(
                                    color: orangeColor,
                                    fontFamily: 'Montserrat',
                                    fontWeight: FontWeight.bold,
                                    fontSize:
                                        14.0 * mediaQueryData.textScaleFactor),
                                children: <InlineSpan>[
                                  TextSpan(
                                      text:
                                          "Price may slightly vary depending on when the service is required.",
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14.0 *
                                              mediaQueryData.textScaleFactor))
                                ]),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              AutoSizeText(
                                "Heading:",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize:
                                        16.0 * mediaQueryData.textScaleFactor,
                                    fontFamily: 'Montserrat',
                                    fontWeight: FontWeight.bold),
                              ),
                              Container(
                                height: mediaQueryData.size.height * 0.3,
                                child: SingleChildScrollView(
                                  child: Text(
                                    "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book.",
                                    style: TextStyle(
                                      fontSize:
                                          14.0 * mediaQueryData.textScaleFactor,
                                      fontFamily: 'Montserrat',
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    Container(
                      width: mediaQueryData.size.width,
                      height: 60,
                      margin: EdgeInsets.only(
                          top: mediaQueryData.size.height * 0.01),
                      child: RaisedButton(
                        color: accentColor,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0)),
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => OrderPage5()));
                        },
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: Text(
                                "ORDER THIS PACKAGE",
                                style: TextStyle(
                                    fontFamily: 'Montserrat',
                                    color: Colors.white,
                                    fontSize: 14.0),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.white,
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

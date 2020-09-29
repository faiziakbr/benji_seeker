import 'package:benji_seeker/constants/MyColors.dart';
import 'package:benji_seeker/custom_texts/MontserratText.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'MyDarkButton.dart';

class InfoDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      backgroundColor: Colors.white,
      child: Container(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Align(
                alignment: Alignment.topRight,
                child: GestureDetector(onTap: (){
                  Get.back();
                },child: Icon(Icons.close)),
              ),
              Image.asset(
                "assets/task_hint_icon.png",
                width: mediaQueryData.size.width * 0.45,
                height: 150,
                fit: BoxFit.contain,
              ),
              _textWithCircularIcon(mediaQueryData, Colors.grey, Colors.grey,
                  Colors.white, "Service Completed"),
              _textWithCircularIcon(mediaQueryData, accentColor, accentColor,
                  Colors.white, "Current Date"),
              _textWithCircularIcon(mediaQueryData, orangeColor, Colors.white,
                  orangeColor, "Incomplete Details"),
              _textWithCircularIcon(mediaQueryData, accentColor, Colors.white,
                  accentColor, "Complete Details"),
              Container(
                  width: mediaQueryData.size.width * 0.55,
                  height: 45,
                  margin: EdgeInsets.only(top: 16.0),
                  child: MyDarkButton("I UNDERSTAND", () {
                    Get.back();
                  }))
            ],
          ),
        ),
      ),
    );
  }

  Widget _textWithCircularIcon(MediaQueryData mediaQueryData, Color borderColor,
      Color backgroundColor, Color iconTextColor, String text) {
    return Container(
      margin: EdgeInsets.only(top: 8.0, left: mediaQueryData.size.width * 0.1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: backgroundColor,
              border: Border.all(color: borderColor, width: 1),
            ),
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: MontserratText(
                "15",
                18,
                iconTextColor,
                FontWeight.normal,
                textAlign: TextAlign.center,
              ),
            ),
          ),
          MontserratText(
            "$text",
            16,
            navBarColor,
            FontWeight.normal,
            left: 16.0,
          )
        ],
      ),
    );
  }
}

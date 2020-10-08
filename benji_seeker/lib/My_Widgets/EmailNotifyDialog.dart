import 'package:benji_seeker/constants/MyColors.dart';
import 'package:benji_seeker/custom_texts/MontserratText.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'MyDarkButton.dart';

class EmailNotifyDialog extends StatelessWidget {
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
                child: GestureDetector(
                    onTap: () {
                      Get.back();
                    },
                    child: Icon(Icons.close)),
              ),
              Image.asset(
                "assets/warning_icon.png",
                width: 100,
                height: 100,
                fit: BoxFit.contain,
              ),
              Container(
                width: mediaQueryData.size.width * 0.55,
                  child: MontserratText(
                "We will notify you once we launch there.",
                14,
                separatorColor,
                FontWeight.normal,
                textAlign: TextAlign.center,
                    top: 16.0,
              )),
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
}

import 'package:benji_seeker/constants/MyColors.dart';
import 'package:benji_seeker/custom_texts/MontserratText.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'MyDarkButton.dart';


class NotifyServiceDialog extends StatelessWidget {
  final Function onComplete;

  NotifyServiceDialog(this.onComplete);

  final TextEditingController _textEditingController = TextEditingController();

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
                child: GestureDetector(onTap: () => Get.back(),child: Icon(Icons.close)),
              ),
              Image.asset(
                "assets/warning_icon.png",
                width: mediaQueryData.size.width * 0.55,
                height: 150,
                fit: BoxFit.cover,
              ),
              SizedBox(
                width: mediaQueryData.size.width * 0.55,
                child: MontserratText(
                  "Unfortunately, we don't serve in your area right now. Please provide us with your Email ID",
                  18,
                  navBarColor,
                  FontWeight.normal,
                  textAlign: TextAlign.center,
                  top: 16.0,
                  bottom: 16.0,
                ),
              ),
              Container(
                width: mediaQueryData.size.width * 0.55,
                // margin: EdgeInsets.only(
                //     left: mediaQueryData.size.width * 0.1,
                //     right: mediaQueryData.size.width * 0.1),
                child: TextField(
                  controller: _textEditingController,
                  textAlign: TextAlign.center,
                  cursorColor: accentColor,
                  keyboardType: TextInputType.number,
                  style: TextStyle(color: separatorColor),
                  enableSuggestions: false,
                  decoration: InputDecoration(
                      hintText: "Email Id",
                      contentPadding: const EdgeInsets.all(4.0),
                      hintStyle: TextStyle(color: lightTextColor),
                      border: OutlineInputBorder(
                          borderSide: BorderSide(color: separatorColor),
                          borderRadius: BorderRadius.circular(50))),
                ),
              ),
              Container(
                  width: mediaQueryData.size.width * 0.55,
                  height: 45,
                  margin: EdgeInsets.only(top: 16.0),
                  child: MyDarkButton("NOTIFY ME", (){
                    onComplete(_textEditingController.text.toString());
                  }))
            ],
          ),
        ),
      ),
    );
  }
}

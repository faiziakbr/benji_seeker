import 'package:benji_seeker/constants/MyColors.dart';
import 'package:benji_seeker/custom_texts/MontserratText.dart';
import 'package:flutter/material.dart';

class DialogInfo extends StatelessWidget {
  final String imagePath;
  final String title;
  final String description;


  DialogInfo(this.imagePath, this.title, this.description);

  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      backgroundColor: dialogBackgroundColor,
      child: Container(
        padding: const EdgeInsets.all(15.0),
        width: mediaQueryData.size.width * 0.8,
        height: 250,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Image.asset(
              imagePath,
              width: mediaQueryData.size.width,
              height: 120,
            ),
            MontserratText(title, 20.0, Colors.white, FontWeight.bold,
                textAlign: TextAlign.center),
            MontserratText(description, 16.0, Colors.white, FontWeight.normal,
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

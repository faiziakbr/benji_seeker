import 'package:benji_seeker/constants/MyColors.dart';
import 'package:benji_seeker/custom_texts/MontserratText.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LocationAndDescriptionDialog extends StatelessWidget {
  final String location;
  final String description;

  LocationAndDescriptionDialog(this.location, this.description);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      backgroundColor: Colors.white,
      child: Container(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Align(
                alignment: Alignment.topRight,
                child: GestureDetector(onTap: (){
                  Get.back();
                },child: Icon(Icons.close)),
              ),
              _textWithIcon("assets/location_orange_icon.png", "Job Location"),
              MontserratText("$location", 12, separatorColor, FontWeight.normal,
                  top: 8.0, bottom: 8.0,),
              _textWithIcon("assets/description_icon.png", "Job Description"),
              MontserratText(
                  "$description", 12, separatorColor, FontWeight.normal,
                  top: 8.0),
            ],
          ),
        ),
      ),
    );
  }

  Widget _textWithIcon(String image, String text) {
    return Container(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(
            "$image",
            color: accentColor,
            width: 18,
            height: 18,
          ),
          Flexible(
            child: MontserratText(
              "$text",
              16,
              accentColor,
              FontWeight.bold,
              left: 8.0,
              right: 8.0,
            ),
          )
        ],
      ),
    );
  }
}

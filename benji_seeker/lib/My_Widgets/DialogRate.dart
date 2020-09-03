import 'package:benji_seeker/My_Widgets/MyToast.dart';
import 'package:benji_seeker/constants/MyColors.dart';
import 'package:benji_seeker/custom_texts/MontserratText.dart';
import 'package:benji_seeker/custom_texts/QuicksandText.dart';
import 'package:flutter/material.dart';
import 'package:rating_bar/rating_bar.dart';

import 'MyDarkButton.dart';

class DialogRating extends StatefulWidget {
  final String title;
  final String inputTextLabel;
  final String hintText;
  final String btnText;

  DialogRating(
    this.title,
    this.inputTextLabel,
    this.hintText,
    this.btnText,
  );

  @override
  _DialogRatingState createState() => _DialogRatingState();
}

class _DialogRatingState extends State<DialogRating> {
  double _rating = 0;
  TextEditingController _textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      backgroundColor: dialogBackgroundColor,
      child: Container(
        width: mediaQueryData.size.width * 0.8,
        height: 250,
        padding: const EdgeInsets.all(15.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            QuicksandText(widget.title, 20.0, Colors.white, FontWeight.bold,
                textAlign: TextAlign.center),
            RatingBar(
              maxRating: 5,
              filledIcon: Icons.star,
              emptyIcon: Icons.star,
              halfFilledIcon: Icons.star_half,
              isHalfAllowed: false,
              filledColor: starColor,
              emptyColor: Colors.grey,
              halfFilledColor: accentColor,
              initialRating: _rating,
              size: 30,
              onRatingChanged: (double rating) {
                setState(() {
                  _rating = rating;
                });
              },
            ),
            Column(
              children: <Widget>[
                MontserratText(
                    widget.inputTextLabel, 14, Colors.white, FontWeight.normal),
                Container(
                  margin: EdgeInsets.only(
                      left: mediaQueryData.size.width * 0.2,
                      right: mediaQueryData.size.width * 0.2),
                  child: TextField(
                    controller: _textEditingController,
                    textAlign: TextAlign.center,
                    cursorColor: Colors.white,
                    keyboardType: TextInputType.text,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: widget.hintText,
                      hintStyle: TextStyle(color: lightTextColor),
                    ),
                  ),
                ),
              ],
            ),
            Container(
                width: mediaQueryData.size.width * 0.5,
                child: MyDarkButton(widget.btnText, _sendRating))
          ],
        ),
      ),
    );
  }

  _sendRating() {
    if(_rating == 0.0){
      MyToast("Rating is required.", context, position: 1);
      return;
    }
    Map<String, dynamic> map = {
      "RATING": _rating,
      "REVIEW": _textEditingController.text.toString()
    };
    Navigator.pop(context, map);
  }
}

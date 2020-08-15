import 'package:benji_seeker/constants/MyColors.dart';
import 'package:benji_seeker/custom_texts/MontserratText.dart';
import 'package:flutter/material.dart';

class DialogYesNo extends StatelessWidget {
  final String mainText;
  final String secondaryText;
  final Function positiveButton;
  final Function negativeButton;

  DialogYesNo(this.mainText, this.secondaryText, this.positiveButton,
      this.negativeButton);

  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      backgroundColor: dialogBackgroundColor,
      child: Container(
        padding: const EdgeInsets.all(15.0),
        width: mediaQueryData.size.width * 0.8,
        height: 200,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            MontserratText(mainText, 20.0, Colors.white, FontWeight.bold,
                textAlign: TextAlign.center),
            MontserratText(secondaryText, 16.0, Colors.white, FontWeight.normal,
                textAlign: TextAlign.center),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                FloatingActionButton(
                  onPressed: negativeButton,
                  child: Icon(Icons.close),
                  backgroundColor: Color.fromRGBO(249, 132, 17, 1),
                ),
                FloatingActionButton(
                  onPressed: positiveButton,
                  child: Icon(Icons.check),
                  backgroundColor: Color.fromRGBO(129, 221, 116, 1),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

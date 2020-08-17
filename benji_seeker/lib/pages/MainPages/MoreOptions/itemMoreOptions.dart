import 'package:benji_seeker/My_Widgets/Separator.dart';
import 'package:benji_seeker/constants/MyColors.dart';
import 'package:benji_seeker/custom_texts/MontserratText.dart';
import 'package:flutter/material.dart';

class ItemMoreOptions extends StatelessWidget {
  final String image;
  final String name;
  final Function btnClick;

  ItemMoreOptions(this.image, this.name, this.btnClick);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: btnClick,
      child: Container(
          margin: const EdgeInsets.only(top: 16.0),
          child: Column(
              children: <Widget>[
                 Row(
                    children: <Widget>[
                      image != null ?
                      Image.asset(
                        image,
                        width: 30,
                        height: 30,
                      ) : Icon(Icons.input, color: orangeColor,),
                      MontserratText(name, 16, image == null ? orangeColor : lightTextColor, FontWeight.normal,left: 8.0),
                      Expanded(
                        child: Container(),
                      ),
                      image == null ? Container() : Icon(Icons.arrow_forward_ios, size: 16,color: lightTextColor,)
                    ],
                  ),

                image == null ? Container() : Separator(topMargin: 16.0)
              ],
            ),

        ),
    );

  }
}

import 'package:benji_seeker/My_Widgets/Separator.dart';
import 'package:benji_seeker/constants/MyColors.dart';
import 'package:benji_seeker/custom_texts/MontserratText.dart';
import 'package:flutter/material.dart';

class ItemGetHelp extends StatelessWidget {
  final String name;

  ItemGetHelp(this.name);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8.0, bottom: 8.0),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              MontserratText(name, 16, lightTextColor, FontWeight.normal,left: 8.0),
              Expanded(
                child: Container(),
              ),
              Icon(Icons.arrow_forward_ios, size: 16,color: lightTextColor,)
            ],
          ),
          Separator()
        ],
      ),
    );
  }
}


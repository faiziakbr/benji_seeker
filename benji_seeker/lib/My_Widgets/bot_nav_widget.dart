import 'package:benji_seeker/constants/MyColors.dart';
import 'package:benji_seeker/custom_texts/MontserratText.dart';
import 'package:flutter/material.dart';

class BotNavWidget extends StatelessWidget {
  final String iconPath;
  final String text;
  final int selectedTab;
  final Function onClick;
  final int index;
  final int count;

  BotNavWidget(
      this.iconPath, this.text, this.selectedTab, this.onClick, this.index,
      {this.count = 0});

  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    return InkWell(
      onTap: () => onClick(index),
      child: Stack(
        overflow: Overflow.visible,
        alignment: Alignment.center,
        children: <Widget>[
          Container(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Image.asset(
                  "$iconPath",
                  color:
                  (selectedTab == index) ? Colors.white : navBarIconColor,
                  width: mediaQueryData.size.width * 0.06,
                  height: mediaQueryData.size.width * 0.06,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    "$text",
                    maxLines: 1,
                    style: TextStyle(
                        fontSize: mediaQueryData.size.width * 0.023,
                        color: (selectedTab == index)
                            ? Colors.white
                            : navBarIconColor, fontFamily: "Montserrat"),
                  ),
                )
              ],
            ),
          ),
          count == 0
              ? Container()
              : Positioned(
            right: mediaQueryData.size.width * 0.04,
            top: -8,
            child: Container(
              width: mediaQueryData.size.width * 0.046,
              height: mediaQueryData.size.height * 0.046,
              child: CircleAvatar(
                backgroundColor: yellowColor,
                child: MontserratText("${count > 99 ? '99' : count}", 12,
                    Colors.white, FontWeight.normal),
              ),
            ),
          )
        ],
      ),
    );
  }
}


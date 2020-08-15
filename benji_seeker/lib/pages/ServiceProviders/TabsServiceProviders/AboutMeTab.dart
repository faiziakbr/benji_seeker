import 'package:benji_seeker/constants/MyColors.dart';
import 'package:benji_seeker/custom_texts/MontserratText.dart';
import 'package:benji_seeker/models/ProviderDetail.dart';
import 'package:flutter/material.dart';

class AboutMeTab extends StatelessWidget {
  final Provider provider;

  AboutMeTab(this.provider);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          MontserratText("About me:", 20.0, Colors.black, FontWeight.bold),
          MontserratText(
            "${provider.about}",
            16.0,
            lightTextColor,
            FontWeight.normal,
            top: 8.0,
          ),
//          MontserratText(
//            "Specialization:",
//            20.0,
//            Colors.black,
//            FontWeight.w500,
//            top: 8.0,
//          ),
//          Expanded(
//            child: GridView.count(
//              padding: const EdgeInsets.only(top: 8.0),
//              crossAxisCount: 2,
//              mainAxisSpacing: 10,
//              crossAxisSpacing: 20,
//              childAspectRatio: 10.0 / 2.0,
//              children: List.generate(5, (index) {
//                return Container(
//                  height: 10.0,
//                  decoration: BoxDecoration(
//                      border: Border.all(width: 1, color: accentColor),
//                      borderRadius: BorderRadius.circular(12.0)),
//                  child: Center(
//                      child: MontserratText(
//                          "Skill", 14, Colors.black, FontWeight.bold)),
//                );
//              }),
//            ),
//          )
        ],
      ),
    );
  }
}

import 'package:benji_seeker/constants/MyColors.dart';
import 'package:benji_seeker/custom_texts/MontserratText.dart';
import 'package:benji_seeker/pages/ServiceProviders/itemServiceProvider.dart';
import 'package:flutter/material.dart';

class BrowserServiceProviders extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    return Scaffold(
        body: Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
            stops: [0.2, 0.3],
            colors: [whiteColor, lightGreenBackgroundColor],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter),
      ),
      padding:
          EdgeInsets.symmetric(horizontal: mediaQueryData.size.width * 0.05),
      child: Column(
        children: <Widget>[
          SafeArea(child: Container(),),
          Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: MontserratText("Browse Service Providers", 22.0, lightTextColor, FontWeight.normal, textAlign: TextAlign.center,),
          ),
//          Expanded(
//            child: MediaQuery.removePadding(
//              context: context,
//              removeTop: true,
//              child: ListView.builder(
//                  physics: BouncingScrollPhysics(),
//                  itemCount: 2,
//                  itemBuilder: (context, index) {
//                    return ItemServiceProvider();
//                  }),
//            ),
//          ),
        ],
      ),
    ));
  }
}

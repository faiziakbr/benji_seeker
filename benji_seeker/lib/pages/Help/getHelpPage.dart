import 'package:benji_seeker/My_Widgets/MyDarkButton.dart';
import 'package:benji_seeker/custom_texts/MontserratText.dart';
import 'package:benji_seeker/custom_texts/QuicksandText.dart';
import 'package:benji_seeker/pages/Help/itemGetHelp.dart';
import 'package:flutter/material.dart';

class GetHelpPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
                stops: [0.4, 0.8],
                colors: [Colors.white, Colors.green[100]],
                begin: Alignment.topLeft,
                end: Alignment.topRight),
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: QuicksandText("Get Help", 22, Colors.black, FontWeight.bold),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.search,
              color: Colors.black,
            ),
            onPressed: () {},
          )
        ],
      ),

      body: Container(
        margin: EdgeInsets.only(
            top: 8.0,
            left: mediaQueryData.size.width * 0.05,
            right: mediaQueryData.size.width * 0.05),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              MontserratText("Browse help topics",20,Colors.black, FontWeight.w500, top: 8.0,bottom: 16.0,),
              ItemGetHelp("Popular Questions"),
              ItemGetHelp("Payment method"),
              ItemGetHelp("Offers & Promotions"),
              ItemGetHelp("Identification & vertification"),
              ItemGetHelp("Cancellation"),
              MontserratText("All topics",20,Colors.black, FontWeight.w500, top: 8.0,bottom: 16.0,),
              ItemGetHelp("Get started"),
              ItemGetHelp("Booking"),
              ItemGetHelp("Your plan"),
              ItemGetHelp("Your account"),
              ItemGetHelp("Become a service provider"),
              ItemGetHelp("Community"),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  MontserratText("Still need help?", 16, Colors.black, FontWeight.bold),
                  MyDarkButton("Contact us",btnContactUsClick)
                ],
              )
            ],
          ),
        ),
      )
    );
  }

  void btnContactUsClick(){
    }
}

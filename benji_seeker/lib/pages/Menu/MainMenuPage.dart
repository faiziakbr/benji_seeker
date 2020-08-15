import 'package:benji_seeker/constants/MyColors.dart';
import 'package:benji_seeker/custom_texts/MontserratText.dart';
import 'package:benji_seeker/custom_texts/QuicksandText.dart';
import 'package:benji_seeker/pages/Menu/MoreMenuPage.dart';
import 'package:benji_seeker/pages/Menu/WorkMenuPage.dart';
import 'package:flutter/material.dart';

import 'PlanMenuPage.dart';

class MenuPage extends StatefulWidget {
  @override
  _MenuPageState createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage>
    with SingleTickerProviderStateMixin {
  TabController _tabController;

  @override
  void initState() {
    _tabController = new TabController(length: 3, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    return Scaffold(
      appBar: AppBar(
        elevation: 3,
        backgroundColor: Colors.white,
        title: QuicksandText("bnji", 22, accentColor, FontWeight.bold),
        centerTitle: false,
        automaticallyImplyLeading: false,
        actions: <Widget>[
          Center(
              child: MontserratText(
            "Log in",
            14,
            Colors.black,
            FontWeight.bold,
            right: 8.0,
          )),
          Center(
              child: MontserratText(
                  "Sign up", 14, Colors.black, FontWeight.bold,
                  right: 8.0)),
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.close,
              color: accentColor,
            ),
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
            children: <Widget>[
              Container(
                child: TabBar(
                  controller: _tabController,
                  labelStyle: TextStyle(
                      fontFamily: "Quicksand",
                      fontWeight: FontWeight.bold,
                      fontSize: 22),
                  labelColor: accentColor,
                  unselectedLabelColor: Colors.black,
                  unselectedLabelStyle: TextStyle(
                      fontFamily: "Quicksand", fontWeight: FontWeight.bold),
                  labelPadding:
                      EdgeInsets.only(right: mediaQueryData.size.width * 0.15),
                  indicatorWeight: 3,
                  tabs: <Widget>[
                    Tab(
                      text: "Plan",
                    ),
                    Tab(
                      text: "Work",
                    ),
                    Tab(
                      text: "More",
                    ),
                  ],
                ),
              ),
              Container(
//                    margin: const EdgeInsets.only(top: 8.0),
                height: mediaQueryData.size.height * 0.8,
                child: TabBarView(
                  controller: _tabController,
                  children: <Widget>[
                    PlanMenuPage(),
                    WorkMenuPage(),
                    MoreMenuPage()
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

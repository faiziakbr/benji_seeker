import 'package:auto_size_text/auto_size_text.dart';
import 'package:benji_seeker/My_Widgets/item_estimate.dart';
import 'package:benji_seeker/My_Widgets/item_order.dart';
import 'package:benji_seeker/constants/MyColors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'OrderPage4.dart';

class OrderPage3 extends StatefulWidget {
  final String categoryId;
  final String subCategoryId;

  OrderPage3(this.categoryId, this.subCategoryId);

  @override
  _OrderPage3State createState() => _OrderPage3State();
}

class _OrderPage3State extends State<OrderPage3> {
  GlobalKey _keyTitle = GlobalKey();
  Offset position = Offset.zero;
  String radioGroup;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback(_afterLayout);
    super.initState();
  }

  _afterLayout(_) {
    RenderBox renderBox = _keyTitle.currentContext.findRenderObject();
    setState(() {
      position = renderBox.localToGlobal(Offset.zero);
    });
  }

  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQueryData = MediaQuery.of(context);

    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
                stops: [0.2, 0.3],
                colors: [whiteColor, lightGreenBackgroundColor],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter),
          ),
          child: Stack(
            children: <Widget>[
              Positioned(
                top: position.dy - 15.0,
                right: mediaQueryData.size.width * 0.01,
                child: SvgPicture.asset(
                  'assets/yard_shears.svg',
                  fit: BoxFit.contain,
                  color: backgroundIconColor,
                  height: mediaQueryData.size.height * 0.2,
                  width: mediaQueryData.size.width * 0.4,
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    height: 5.0,
                    color: accentColor,
                    width: mediaQueryData.size.width * 0.75,
                  ),
                  Container(
                    padding: EdgeInsets.only(
                        top: mediaQueryData.size.width * 0.05,
                        left: mediaQueryData.size.width * 0.05,
                        right: mediaQueryData.size.width * 0.05),
                    child: IconButton(
                        icon: Icon(Icons.arrow_back),
                        padding: EdgeInsets.all(0.0),
                        alignment: Alignment.topLeft,
                        onPressed: () {
                          Navigator.pop(context);
                        }),
                  ),
                  Container(
                    key: _keyTitle,
                    padding: EdgeInsets.only(
                        left: mediaQueryData.size.width * 0.05,
                        right: mediaQueryData.size.width * 0.05),
                    child: AutoSizeText(
                      "Lawn Mowing",
                      style: TextStyle(
                          fontFamily: 'Quicksand',
                          fontWeight: FontWeight.bold,
                          fontSize: 22.0 * mediaQueryData.textScaleFactor),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: mediaQueryData.size.width * 0.05),
                    child: AutoSizeText(
                      "Tell us your estimate",
                      style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 16.0 * mediaQueryData.textScaleFactor),
                    ),
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: mediaQueryData.size.width * 0.05),
                      child: ListView.builder(
                          itemCount: 4,
                          itemBuilder: (context, index) {
                            if (index == 3)
                              return ItemEstimate(
                                radioGroup,
                                mediaQueryData,
                                "Enter your own estimate",
                                "Lorem Ipsum",
                                "Around 3 hrs",
                                isClientEstimate: true,
                              );
                            return ItemEstimate(radioGroup, mediaQueryData,
                                "Small Grass", "Lorem Ipsum", "Around 3 hrs");
                          }),
                    ),
                  ),
                  Container(
                    width: mediaQueryData.size.width,
                    height: 60,
                    padding: EdgeInsets.only(
                        bottom: mediaQueryData.size.width * 0.01,
                        left: mediaQueryData.size.width * 0.05,
                        right: mediaQueryData.size.width * 0.05),
                    child: RaisedButton(
                      color: accentColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0)),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => OrderPage4()));
                      },
                      child: Text(
                        "CONTINUE",
                        style: TextStyle(
                            fontFamily: 'Montserrat', color: Colors.white),
                      ),
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void itemClick() {}
}

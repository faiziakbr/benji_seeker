import 'dart:convert';
import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:benji_seeker/My_Widgets/item_order.dart';
import 'package:benji_seeker/SharedPref/SavedData.dart';
import 'package:benji_seeker/constants/Constants.dart';
import 'package:benji_seeker/constants/MyColors.dart';
import 'package:benji_seeker/constants/Urls.dart';
import 'package:benji_seeker/custom_texts/MontserratText.dart';
import 'package:benji_seeker/models/CreateJobModel.dart';
import 'package:benji_seeker/models/SubCategoryModel.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'OrderPage3.dart';


class OrderPage2 extends StatefulWidget {
  @override
  _OrderPage2State createState() => _OrderPage2State();
}

class _OrderPage2State extends State<OrderPage2> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

//class OrderPage2 extends StatefulWidget {
//  final CreateJobModel createJobModel;
//
//  OrderPage2(this.createJobModel);
//
//  @override
//  _OrderPage2State createState() => _OrderPage2State();
//}

//class _OrderPage2State extends State<OrderPage2> {
//  GlobalKey _keyTitle = GlobalKey();
//  Offset position = Offset.zero;
//
//  @override
//  void initState() {
//    WidgetsBinding.instance.addPostFrameCallback(_afterLayout);
//    super.initState();
//  }
//
//  _afterLayout(_) {
//    RenderBox renderBox = _keyTitle.currentContext.findRenderObject();
//    setState(() {
//      position = renderBox.localToGlobal(Offset.zero);
//    });
//  }
//
//  @override
//  Widget build(BuildContext context) {
//    MediaQueryData mediaQueryData = MediaQuery.of(context);
//
//    return Scaffold(
//      body: SafeArea(
//        child: Container(
//          decoration: BoxDecoration(
//            gradient: LinearGradient(
//                stops: [0.2, 0.3],
//                colors: [whiteColor, lightGreenBackgroundColor],
//                begin: Alignment.topCenter,
//                end: Alignment.bottomCenter),
//          ),
//          child: Stack(
//            children: <Widget>[
//              Positioned(
//                top: position.dy - 15.0,
//                right: mediaQueryData.size.width * 0.01,
//                child: SvgPicture.asset(
//                  'assets/yard_shears.svg',
//                  fit: BoxFit.contain,
//                  color: backgroundIconColor,
//                  height: mediaQueryData.size.height * 0.2,
//                  width: mediaQueryData.size.width * 0.4,
//                ),
//              ),
//              Column(
//                crossAxisAlignment: CrossAxisAlignment.start,
//                children: <Widget>[
//                  Container(
//                    height: 5.0,
//                    color: accentColor,
//                    width: mediaQueryData.size.width * 0.45,
//                  ),
//                  Padding(
//                    padding: EdgeInsets.only(
//                        top: mediaQueryData.size.width * 0.05,
//                        left: mediaQueryData.size.width * 0.05,
//                        right: mediaQueryData.size.width * 0.05),
//                    child: IconButton(
//                      icon: Icon(Icons.arrow_back),
//                      padding: EdgeInsets.all(0.0),
//                      alignment: Alignment.topLeft,
//                      onPressed: () {
//                        Navigator.pop(context);
//                      },
//                    ),
//                  ),
//                  Container(
//                    key: _keyTitle,
//                    padding: EdgeInsets.symmetric(
//                        horizontal: mediaQueryData.size.width * 0.05),
//                    child: AutoSizeText(
//                      "Yard / Garden",
//                      style: TextStyle(
//                          fontFamily: 'Quicksand',
//                          fontWeight: FontWeight.bold,
//                          fontSize: 22.0 * mediaQueryData.textScaleFactor),
//                    ),
//                  ),
//                  Container(
//                    padding: EdgeInsets.symmetric(
//                        horizontal: mediaQueryData.size.width * 0.05),
//                    child: AutoSizeText(
//                      "Select a job below:",
//                      style: TextStyle(
//                          fontFamily: 'Montserrat',
//                          fontSize: 16.0 * mediaQueryData.textScaleFactor),
//                    ),
//                  ),
//                  SizedBox(
//                    height: 10.0,
//                  ),
//                  Expanded(
//                    child: FutureBuilder<SubCategoryModel>(
//                        future: _getSubCategoryResponse(widget.createJobModel.categoryId),
//                        builder: (context, snap) {
//                          switch (snap.connectionState) {
//                            case ConnectionState.none:
//                              return Center(child: Text("No Internet"));
//                            case ConnectionState.waiting:
//                              return Center(child: CircularProgressIndicator());
//                            case ConnectionState.active:
//                            case ConnectionState.done:
//                              if (snap.hasError) {
//                                print("Categories ERROR: ${snap.error}");
//                                return Center(
//                                    child: MontserratText("Error loading jobs",
//                                        22, Colors.black, FontWeight.normal));
//                              } else if (snap.data.subCategories != null &&
//                                  snap.data.subCategories.length > 0) {
//                                var item = snap.data.subCategories;
//                                return ListView.builder(
//                                    padding: EdgeInsets.symmetric(
//                                        horizontal:
//                                            mediaQueryData.size.width * 0.05),
//                                    physics: BouncingScrollPhysics(),
//                                    itemCount: item.length,
//                                    itemBuilder: (context, index) {
//                                      return ItemOrder(
//                                          mediaQueryData,
//                                          item[index].name,
//                                          'assets/yard_shears.svg',
//                                          item[index].id,
//                                          itemClick);
//                                    });
//                              } else
//                                return Center(
//                                  child: MontserratText("No jobs!", 22,
//                                      Colors.black, FontWeight.normal),
//                                );
//                          }
//                          return Container();
//                        }),
//                  )
//                ],
//              ),
//            ],
//          ),
//        ),
//      ),
//    );
//  }
//
//  void itemClick(BuildContext context, String subCategoryId) {
//    Navigator.push(
//        context, MaterialPageRoute(builder: (context) => OrderPage3(widget.createJobModel.categoryId, subCategoryId)));
//  }
//
//  Future<SubCategoryModel> _getSubCategoryResponse(String categoryId) async {
//    try {
//      BaseOptions baseOptions = new BaseOptions(
//        connectTimeout: 15000,
//        receiveTimeout: 15000,
//      );
//      Dio dio = new Dio(baseOptions);
//      SavedData savedData = new SavedData();
//      String token = await savedData.getValue(TOKEN);
//
//      Options options = new Options(headers: {"token": token});
//
//      final response = await dio.get(BASE_URL + URL_SUB_CATEGORY(categoryId),
//          options: options);
//      if (response.statusCode == HttpStatus.ok)
//        return subCategoryResponseFromJson(json.encode(response.data));
//      else
//        return SubCategoryModel(status: false);
//    } on DioError catch (e) {
//      if (e.response != null) {
//        return subCategoryResponseFromJson(json.encode(e.response.data));
//      } else {
//        return SubCategoryModel(status: false);
//      }
//    }
//  }
//}

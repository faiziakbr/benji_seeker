import 'dart:convert';

import 'package:benji_seeker/My_Widgets/EmailNotifyDialog.dart';
import 'package:benji_seeker/My_Widgets/MyLoadingDialog.dart';
import 'package:benji_seeker/My_Widgets/MyToast.dart';
import 'package:benji_seeker/My_Widgets/ZipCodeDialog.dart';
import 'package:benji_seeker/My_Widgets/item_order.dart';
import 'package:benji_seeker/constants/MyColors.dart';
import 'package:benji_seeker/constants/Urls.dart';
import 'package:benji_seeker/custom_texts/MontserratText.dart';
import 'package:benji_seeker/custom_texts/QuicksandText.dart';
import 'package:benji_seeker/models/CategoryModel.dart';
import 'package:benji_seeker/models/CreateJobModel.dart';
import 'package:benji_seeker/models/JustStatusModel.dart';
import 'package:benji_seeker/pages/BotNav.dart';
import 'package:benji_seeker/pages/CreateJobPages/PackageSelection/PackageSelectionPage.dart';
import 'package:benji_seeker/utils/DioHelper.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OrderPage1 extends StatefulWidget {
  final CreateJobModel createJobModel;
  final bool showCloseIcon;

  OrderPage1(this.createJobModel, {this.showCloseIcon = true});

  @override
  _OrderPage1State createState() => _OrderPage1State();
}

class _OrderPage1State extends State<OrderPage1> {
  DioHelper _dioHelper;
  List<ItemCategory> _itemCategories = [];
  bool _isLoading = true;
  bool _isError = false;

  @override
  void initState() {
    _dioHelper = DioHelper.instance;

    _fetchCategories();
    super.initState();
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                height: 5.0,
                width: mediaQueryData.size.width * 0.33,
                color: accentColor,
              ),
              widget.showCloseIcon ? Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  onPressed: () {
                    while (Navigator.canPop(context)) {
                      Navigator.pop(context);
                    }
                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (context) => BotNavPage(pageIndex: 1,)));
                  },
                  icon: Icon(Icons.close),
                ),
              ) : Container(),
              _isLoading
                  ? Container(
                      height: mediaQueryData.size.height * 0.75,
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : _isError
                      ? Container(
                          height: mediaQueryData.size.height * 0.75,
                          child: Center(
                            child: MontserratText("Error loading categories!",
                                18, separatorColor, FontWeight.normal),
                          ),
                        )
                      : Expanded(
//                          height: mediaQueryData.size.height * 0.85,
//                          padding: EdgeInsets.symmetric(
//                              horizontal: mediaQueryData.size.width * 0.04),
                          child: Container(
                            margin: EdgeInsets.only(top: widget.showCloseIcon ? 0.0 : 16.0),
                            padding: EdgeInsets.symmetric(
                                horizontal: mediaQueryData.size.width * 0.04),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                QuicksandText("Schedule Your Tasks", 22,
                                    Colors.black, FontWeight.bold),
                                MontserratText(
                                  "Select a job below:",
                                  16,
                                  separatorColor,
                                  FontWeight.normal,
                                  top: 8.0,
                                ),
                                SizedBox(
                                  height: mediaQueryData.size.height * 0.05,
                                ),
                                _itemCategories.length == 0
                                    ? Container(
                                        height:
                                            mediaQueryData.size.height * 0.5,
                                        child: Center(
                                          child: MontserratText(
                                              "No categories!",
                                              18,
                                              separatorColor,
                                              FontWeight.normal),
                                        ),
                                      )
                                    : Expanded(
                                        child: ListView.builder(
                                            physics: BouncingScrollPhysics(),
                                            itemCount: _itemCategories.length,
                                            itemBuilder: (context, index) {
                                              String image = BASE_URL_CATEGORY +
                                                  _itemCategories[index].image;
                                              return ItemOrder(
                                                  mediaQueryData,
                                                  _itemCategories[index].name,
                                                  '$image',
                                                  _itemCategories[index].id,
                                                  itemClick);
                                            }))
                              ],
                            ),
                          ),
                        ),
            ],
          ),
        ),
      ),
    );
  }

  void itemClick(BuildContext context, String categoryId, String text) {
    // print("CATEGORY ID: $categoryId");
    Get.dialog(ZipCodeDialog((value) {
      if(value.isNotEmpty && value.toString().isNumericOnly){
        _checkZipCodeRequest(value, categoryId, text);
      } else {
        MyToast("Enter valid Zip Code", context);
      }
    }));
    // widget.createJobModel.categoryId = categoryId;
    // Navigator.push(context,
    //     MaterialPageRoute(builder: (context) => PackageSelectionPage(widget.createJobModel, text)));
  }

  void _checkZipCodeRequest(String zipCode, String categoryId, String text){
    MyLoadingDialog(context, "Checking...");
    _dioHelper.getRequest(BASE_URL + URL_CHECK_ZIP_CODE(zipCode), {"token":""}).then((value){
      Navigator.pop(context);//pop dialog
      print("ZIP $value");
      JustStatusModel justStatusModel = justStatusResponseFromJson(json.encode(value.data));

      if(justStatusModel.status){
        widget.createJobModel.categoryId = categoryId;
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => PackageSelectionPage(widget.createJobModel, text)));
      }

    }).catchError((error){
      Navigator.pop(context);//pop dialog
      try {
        var err = error as DioError;
        if (err.type == DioErrorType.RESPONSE) {
          JustStatusModel response =
          justStatusResponseFromJson(json.encode(err.response.data));

          if(response.errors[0].toString().contains("Sorry we do not")) {
            _notifyOfUnServeZipCode(zipCode);
          }else{
            MyToast("${response.errors[0]}", context);
          }
        } else {
          MyToast("${err.message}", context);
        }
      } catch (e) {}
    });
  }

  void _notifyOfUnServeZipCode(String zipCode){
    MyLoadingDialog(context, "Checking...");

    _dioHelper.postRequest(BASE_URL + URL_NOTIFY_OF_ZIP_CODE, {"token":""}, {"zip": zipCode}).then((value){
      Navigator.pop(context);//pop dialog
      JustStatusModel justStatusModel = justStatusResponseFromJson(json.encode(value.data));

      if(justStatusModel.status){
        Navigator.pop(context);
        Get.dialog(EmailNotifyDialog());
      }

    }).catchError((error){
      Navigator.pop(context);//pop dialog
      try {
        var err = error as DioError;
        if (err.type == DioErrorType.RESPONSE) {
          JustStatusModel response =
          justStatusResponseFromJson(json.encode(err.response.data));
          MyToast("${response.errors[0]}", context);
        } else {
          MyToast("${err.message}", context);
        }
      } catch (e) {}
    });
  }

  void _fetchCategories() {
    _dioHelper
        .getRequest(BASE_URL + URL_SUB_CATEGORIES, {"token": ""}).then((value) {
      CategoryModel categoryModel =
          categoryResponseFromJson(json.encode(value.data));

      if (categoryModel.status) {
        _itemCategories.addAll(categoryModel.categories);
      } else {
        setState(() {
          _isError = true;
        });
      }
    }).catchError((error) {
      try {
        var err = error as DioError;
        if (err.type == DioErrorType.RESPONSE) {
          CategoryModel response =
              categoryResponseFromJson(json.encode(err.response.data));
          MyToast("${response.errors[0]}", context, position: 1);
        } else {
          MyToast("${err.message}", context, position: 1);
        }
      } catch (e) {}
      setState(() {
        _isError = true;
      });
    }).whenComplete(() {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }
}

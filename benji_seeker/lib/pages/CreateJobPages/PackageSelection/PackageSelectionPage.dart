import 'dart:convert';

import 'package:benji_seeker/My_Widgets/MyToast.dart';
import 'package:benji_seeker/constants/MyColors.dart';
import 'package:benji_seeker/constants/Urls.dart';
import 'package:benji_seeker/custom_texts/MontserratText.dart';
import 'package:benji_seeker/custom_texts/QuicksandText.dart';
import 'package:benji_seeker/models/CreateJobModel.dart';
import 'package:benji_seeker/models/PackageModel.dart';
import 'package:benji_seeker/utils/DioHelper.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../BotNav.dart';
import 'ItemPackagePage.dart';

class PackageSelectionPage extends StatefulWidget {
  final CreateJobModel createJobModel;
  final String title;

  PackageSelectionPage(this.createJobModel, this.title);

  @override
  _PackageSelectionPageState createState() => _PackageSelectionPageState();
}

class _PackageSelectionPageState extends State<PackageSelectionPage> {
  bool _isLoading = true;
  bool _isError = false;
  DioHelper _dioHelper;
  double wage = 0.0;
  List<ItemPackage> _packageList = [];
  List<bool> _openedPackages = [];

  var openTab = true;
  var previousIndex = 0;

  @override
  void initState() {
    _dioHelper = DioHelper.instance;

    _fetchPackageDetails(widget.createJobModel.categoryId);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
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
                  width: mediaQueryData.size.width * 0.66,
                  color: accentColor,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.arrow_back),
                    ),
                    IconButton(
                      onPressed: () {
                        while (Navigator.canPop(context)) {
                          Navigator.pop(context);
                        }
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => BotNavPage()));
                      },
                      icon: Icon(Icons.close),
                    ),
                  ],
                ),
                _isLoading
                    ? Container(
                        height: mediaQueryData.size.height,
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      )
                    : _isError
                        ? Container(
                            height: mediaQueryData.size.height,
                            child: Center(
                              child: MontserratText("Error loading packages!",
                                  18, separatorColor, FontWeight.normal),
                            ),
                          )
                        : Container(
                            height: mediaQueryData.size.height * 0.85,
                            padding: EdgeInsets.symmetric(
                                horizontal: mediaQueryData.size.width * 0.04),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                QuicksandText("${widget.title}", 22,
                                    Colors.black, FontWeight.bold),
                                MontserratText(
                                  "Select your package:",
                                  16,
                                  separatorColor,
                                  FontWeight.normal,
                                  top: 8.0,
                                ),
                                SizedBox(
                                  height: mediaQueryData.size.height * 0.05,
                                ),
                                Expanded(
                                    child: ListView.builder(
                                        physics: BouncingScrollPhysics(),
                                        itemCount: _packageList.length,
                                        itemBuilder: (context, index) {
                                          return ItemPackagePage(
                                              mediaQueryData,
                                              index,
                                              _packageList.length,
                                              wage,
                                              _packageList,
                                              widget.createJobModel, (value) {
                                            setState(() {
                                              for (var item
                                                  in _packageList) {
                                                if (item !=
                                                    _packageList[value]) {
                                                  item.isOpen = false;
                                                }
                                              }
                                            });
                                          });
                                        }))
                              ],
                            ),
                          ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _fetchPackageDetails(String subCategoryId) {
    _dioHelper.getRequest(BASE_URL + URL_SUB_CATRGORY_DETAIL(subCategoryId),
        {"token": ""}).then((value) {
      print("RESPONSE: ${value.data}");
      PackageModel packageModel =
          packageResponseFromJson(json.encode(value.data));

      if (packageModel.status) {
        widget.createJobModel.setRecurringOptions
            .addAll(packageModel.recurringOptions);
        _packageList.addAll(packageModel.packages);
        _packageList.add(ItemPackage());
        for (ItemPackage data in packageModel.packages) {
          _openedPackages.add(false);
        }
        wage = packageModel.wage;
      } else {
        setState(() {
          _isError = true;
        });
      }
    }).catchError((error) {
      try {
        print("ERROR IS $error");
        var err = error as DioError;
        print("ERR RESPONSE: ${err.response.data}");
        if (err.type == DioErrorType.RESPONSE) {
          PackageModel response =
              packageResponseFromJson(json.encode(err.response.data));
          MyToast("${response.errors[0]}", context, position: 1);
        } else {
          MyToast("${err.message}", context, position: 1);
        }
      } catch (e) {
        MyToast("Unexpected Error!", context, position: 1);
      }
      setState(() {
        _isError = true;
      });
    }).whenComplete(() {
      setState(() {
        _isLoading = false;
      });
    });
  }
}

import 'dart:convert';

import 'package:benji_seeker/My_Widgets/MyDarkButton.dart';
import 'package:benji_seeker/My_Widgets/MyLoadingDialog.dart';
import 'package:benji_seeker/My_Widgets/MyToast.dart';
import 'package:benji_seeker/constants/MyColors.dart';
import 'package:benji_seeker/constants/Urls.dart';
import 'package:benji_seeker/custom_texts/MontserratText.dart';
import 'package:benji_seeker/custom_texts/QuicksandText.dart';
import 'package:benji_seeker/models/JustStatusModel.dart';
import 'package:benji_seeker/models/ProviderDetail.dart';
import 'package:benji_seeker/pages/BotNav.dart';
import 'package:benji_seeker/pages/ServiceProviders/TabsServiceProviders/OverviewTab.dart';
import 'package:benji_seeker/utils/DioHelper.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'TabsServiceProviders/AboutMeTab.dart';
import 'TabsServiceProviders/ReviewsTab.dart';

class ServiceProviderDetail extends StatefulWidget {
  final String providerId;
  final String jobId;

  ServiceProviderDetail(this.providerId, this.jobId);

  @override
  _ServiceProviderDetailState createState() => _ServiceProviderDetailState();
}

class _ServiceProviderDetailState extends State<ServiceProviderDetail>
    with SingleTickerProviderStateMixin {
  DioHelper _dioHelper;
  TabController _tabController;

  bool _isLoading = true;
  bool _isError = false;

  Provider _provider;

  @override
  void initState() {
    _dioHelper = DioHelper.instance;
    _tabController = new TabController(length: 2, vsync: this);

    _fetchProviderDetail();
    super.initState();
  }

  _fetchProviderDetail() {
    _dioHelper.getRequest(BASE_URL + URL_PROVIDER_DETAIL(widget.providerId),
        {"token": ""}).then((value) {
      ProviderDetail providerDetail =
          providerDetailResponseFromJson(json.encode(value.data));
      if (providerDetail.status) {
        _provider = providerDetail.provider;
      } else {
        MyToast("${providerDetail.errors[0]}", context, position: 1);
        setState(() {
          _isError = true;
        });
      }
    }).catchError((error) {
      try {
        var err = error as DioError;
        if (err.type == DioErrorType.RESPONSE) {
          ProviderDetail providerDetail =
              providerDetailResponseFromJson(json.encode(err.response.data));
          MyToast("${providerDetail.errors[0]}", context, position: 1);
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

  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
              stops: [0.2, 0.3],
              colors: [whiteColor, lightGreenBackgroundColor],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter),
        ),
        child: _isLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : _isError
                ? Center(
                    child: MontserratText("Error loading provider!", 18,
                        Colors.black.withOpacity(0.4), FontWeight.normal))
                : Stack(
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: mediaQueryData.size.width * 0.04),
                        child: SingleChildScrollView(
                          child: Column(
                            children: <Widget>[
//                    Row(
//                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                      children: <Widget>[
//                        IconButton(
//                          icon: Icon(Icons.arrow_back),
//                          onPressed: () {
//                            Navigator.pop(context);
//                          },
//                        ),
//                        IconButton(
//                          icon: Icon(Icons.tune),
//                          onPressed: () {},
//                        )
//                      ],
//                    ),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: FadeInImage(
                                  fit: BoxFit.cover,
                                  width: mediaQueryData.size.width * 0.23,
                                  height: mediaQueryData.size.height * 0.13,
                                  placeholder:
                                      AssetImage("assets/placeholder.png"),
                                  image: NetworkImage(
                                      "$BASE_PROFILE_URL${_provider.profilePic}"),
                                  imageErrorBuilder: (x, y, z) {
                                    return Container(
                                        width: mediaQueryData.size.width * 0.23,
                                        height:
                                            mediaQueryData.size.height * 0.13,
                                        child: Image.asset(
                                            "assets/placeholder.png"));
                                  },
                                ),
                              ),
                              QuicksandText(
                                "${_provider.nickName}",
                                26.0,
                                Colors.black,
                                FontWeight.bold,
                                textAlign: TextAlign.center,
                                top: 8.0,
                              ),
//                              MontserratText(
//                                "Outdoors Services",
//                                18.0,
//                                lightTextColor,
//                                FontWeight.normal,
//                                textAlign: TextAlign.center,
//                                top: 8.0,
//                              ),
                              MontserratText(
                                "${_provider.address}",
                                18.0,
                                lightTextColor,
                                FontWeight.normal,
                                textAlign: TextAlign.center,
                                top: 8.0,
                              ),
                              Card(
                                elevation: 6.0,
                                margin: const EdgeInsets.only(
                                    top: 8.0,
                                    bottom: 8.0,
                                    left: 8.0,
                                    right: 8.0),
                                child: Container(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: <Widget>[
                                      Column(
                                        children: <Widget>[
                                          Row(
                                            children: <Widget>[
                                              QuicksandText(
                                                _provider.rating != null ? "${_provider.rating.toStringAsFixed(1)}" : "0.0",
                                                30.0,
                                                Colors.black,
                                                FontWeight.bold,
                                                textAlign: TextAlign.center,
                                              ),
                                              Icon(
                                                Icons.star,
                                                color: starColor,
                                              )
                                            ],
                                          ),
                                          MontserratText(
                                            "Average Rating",
                                            16.0,
                                            lightTextColor,
                                            FontWeight.normal,
                                            textAlign: TextAlign.center,
                                          )
                                        ],
                                      ),
                                      Column(
                                        children: <Widget>[
                                          QuicksandText(
                                            _provider.totalJobs > 199
                                                ? "200+"
                                                : "${_provider.totalJobs}",
                                            30.0,
                                            Colors.black,
                                            FontWeight.bold,
                                            textAlign: TextAlign.center,
                                          ),
                                          MontserratText(
                                            "Times hired",
                                            16.0,
                                            lightTextColor,
                                            FontWeight.normal,
                                            textAlign: TextAlign.center,
                                          )
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Container(
                                child: TabBar(
                                  controller: _tabController,
                                  labelStyle: TextStyle(
                                      fontFamily: "Quicksand",
                                      fontWeight: FontWeight.bold),
                                  labelColor: accentColor,
                                  unselectedLabelColor: Colors.black,
                                  unselectedLabelStyle: TextStyle(
                                      fontFamily: "Quicksand",
                                      fontWeight: FontWeight.bold),
                                  tabs: <Widget>[
//                                    Tab(
//                                      text: "Overview",
//                                    ),
                                    Tab(
                                      text: "About",
                                    ),
                                    Tab(
                                      text: "Reviews",
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
//                                    OverviewTab(_provider),
                                    AboutMeTab(_provider),
                                    ReviewsTab(_provider),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: mediaQueryData.size.height * 0.04,
                        width: mediaQueryData.size.width,
                        child: Container(
                          width: mediaQueryData.size.width * 0.8,
                          height: 50,
                          margin: EdgeInsets.only(
                              left: mediaQueryData.size.width * 0.04,
                              right: mediaQueryData.size.width * 0.04),
                          child: MyDarkButton("HIRE", onClicked),
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }

  void onClicked() {
    DioHelper dioHelper = DioHelper.instance;
    MyLoadingDialog(context, "Hiring...");

    Map<String, dynamic> request = {
      "process_id": "${widget.jobId}",
      "provider_id": "${widget.providerId}"
    };
    dioHelper
        .postRequest(BASE_URL + URL_ACCEPT_BID, {"token": ""}, request)
        .then((value) {
      JustStatusModel justStatusModel =
          justStatusResponseFromJson(json.encode(value.data));
      if (justStatusModel.status) {
        while (Navigator.canPop(context)) {
          Navigator.pop(context);
        }
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => BotNavPage(pageIndex: 1,)));
      } else {
        Navigator.pop(context);
        MyToast("${justStatusModel.errors[0]}", context);
      }
    }).catchError((error) {
      try {
        Navigator.pop(context);
        var err = error as DioError;
        if (err.type == DioErrorType.RESPONSE) {
          JustStatusModel justModel =
              justStatusResponseFromJson(json.encode(err.response.data));
          MyToast("${justModel.errors[0]}", context, position: 1);
        } else {
          MyToast("${err.message}", context, position: 1);
        }
      } catch (e) {
        MyToast("Unexpected Error!", context, position: 1);
      }
    });
  }
}

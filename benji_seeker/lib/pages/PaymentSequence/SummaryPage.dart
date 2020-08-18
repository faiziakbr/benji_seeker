import 'dart:convert';

import 'package:benji_seeker/My_Widgets/DialogRate.dart';
import 'package:benji_seeker/My_Widgets/InputDialog.dart';
import 'package:benji_seeker/My_Widgets/MyDarkButton.dart';
import 'package:benji_seeker/My_Widgets/MyLightButton.dart';
import 'package:benji_seeker/My_Widgets/MyLoadingDialog.dart';
import 'package:benji_seeker/My_Widgets/MyToast.dart';
import 'package:benji_seeker/My_Widgets/Separator.dart';
import 'package:benji_seeker/constants/MyColors.dart';
import 'package:benji_seeker/constants/Urls.dart';
import 'package:benji_seeker/custom_texts/MontserratText.dart';
import 'package:benji_seeker/custom_texts/QuicksandText.dart';
import 'package:benji_seeker/models/CompletedJobModel.dart';
import 'package:benji_seeker/models/JustStatusModel.dart';
import 'package:benji_seeker/models/SummaryModel.dart';
import 'package:benji_seeker/utils/DioHelper.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rating_bar/rating_bar.dart';

class SummaryPage extends StatefulWidget {
  final String jobId;
  final CompletedJobModel completedJobModel;
  final String processId;

  SummaryPage(this.jobId, this.completedJobModel, this.processId);

  @override
  _SummaryPageState createState() => _SummaryPageState();
}

class _SummaryPageState extends State<SummaryPage> {
  DioHelper _dioHelper;
  bool _isLoading = true;
  bool _isError = false;

  bool _showTip = false;
  bool _hasGivenReview = false;
  double _rating = 0;
  String _review = "";
  String _tip;
  SummaryModel _summaryModel;

  @override
  void initState() {
    _dioHelper = DioHelper.instance;
    _showTip = widget.completedJobModel.tipGiven;
    _hasGivenReview = widget.completedJobModel.rated;

    _fetchSummary();
    super.initState();
  }

  _fetchSummary() {
    _dioHelper.getRequest(
        BASE_URL + URL_SUMMARY(widget.jobId), {"token": ""}).then((value) {
      print("SUMMARY: $value");
      SummaryModel summaryModel =
          summaryModelResponseFromJson(json.encode(value.data));

      if (summaryModel.status) {
        _summaryModel = summaryModel;
      } else {
        MyToast("${_summaryModel.errors[0]}", context);
        setState(() {
          _isError = true;
        });
      }
    }).catchError((error) {
      print("SUMMARY ERROR: $error");
      try {
        print("ERROR: $error");
        var err = error as DioError;
        if (err.type == DioErrorType.RESPONSE) {
          SummaryModel summaryModel =
              summaryModelResponseFromJson(json.encode(err.response.data));
          MyToast("${summaryModel.errors[0]}", context, position: 1);
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

  _postAddTip(double tip) {
    MyLoadingDialog(context, "Giving tip...");
    Map<String, dynamic> data = {
      "tip": tip,
      "process_id": "${widget.processId}"
    };
    _dioHelper
        .postRequest(BASE_URL + URL_ADD_TIP, {"token": ""}, data)
        .then((value) {
      Navigator.pop(context);
      print("UPCOMING JOBS: ${value.data}");
      JustStatusModel justStatusModel =
          justStatusResponseFromJson(json.encode(value.data));

      if (justStatusModel.status) {
        MyToast("Job rescheduled successfully", context, position: 1);
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => SummaryPage(
                    widget.jobId, widget.completedJobModel, widget.processId)));
      } else {
        MyToast("${justStatusModel.errors[0]}", context, position: 1);
      }
    }).catchError((error) {
      Navigator.pop(context);
      try {
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

  _postAddReview(double rating, String review){
    MyLoadingDialog(context, "Giving review...");
    Map<String, dynamic> data = {
      "process_id":"${widget.processId}",
      "rating":rating,
      "review":"$review"
    };

    _dioHelper.postRequest(BASE_URL + URL_REVIEW, {"token":""}, data).then((value) {
      Navigator.pop(context);
      print("UPCOMING JOBS: ${value.data}");
      JustStatusModel justStatusModel =
      justStatusResponseFromJson(json.encode(value.data));

      if (justStatusModel.status) {
        MyToast("Job rescheduled successfully", context, position: 1);
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => SummaryPage(
                    widget.jobId, widget.completedJobModel, widget.processId)));
      } else {
        MyToast("${justStatusModel.errors[0]}", context, position: 1);
      }
    }).catchError((error){
      Navigator.pop(context);
      try {
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

  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: MontserratText(
          "SUMMARY",
          20.0,
          lightTextColor,
          FontWeight.normal,
        ),
      ),
      body: Container(
        height: mediaQueryData.size.height,
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : _isError
                ? Center(
                    child: MontserratText("Error loading summary", 18,
                        Colors.black.withOpacity(0.4), FontWeight.normal),
                  )
                : Stack(
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.symmetric(
                            horizontal: mediaQueryData.size.width * 0.04),
                        child: SingleChildScrollView(
                          child: Column(
                            children: <Widget>[
                              Stack(
                                children: <Widget>[
                                  Image.asset(
                                    "assets/background_summary.png",
                                    height: mediaQueryData.size.height * 0.2,
                                  ),
                                  Positioned(
                                    top: mediaQueryData.size.height * 0.03,
                                    width: mediaQueryData.size.width * 0.94,
                                    child: Column(
                                      children: <Widget>[
                                        MontserratText("${_summaryModel.name}",
                                            18, Colors.white, FontWeight.bold),
                                        MontserratText(
                                          "\$${_summaryModel.total}",
                                          45,
                                          Colors.white,
                                          FontWeight.bold,
                                          top: mediaQueryData.size.height *
                                              0.045,
                                        )
                                      ],
                                    ),
                                  )
                                ],
                              ),
                              amountDetails(
                                  "Actual Wage", "\$${_summaryModel.amount.toStringAsFixed(2)}"),
                              amountDetails("Payment Processing Fee",
                                  "\$${_summaryModel.applicationFee.toStringAsFixed(2)}"),
                              Separator(
                                topMargin: 8.0,
                              ),
                              Container(
                                  margin: const EdgeInsets.only(bottom: 8.0),
                                  child: amountDetails("Total",
                                      "\$${_summaryModel.amount + _summaryModel.applicationFee}",
                                      size: 22,
                                      fontWeight: FontWeight.bold,
                                      fontType: false)),
//                    Container(
//                      decoration: BoxDecoration(
//                          borderRadius: BorderRadius.circular(12.0),
//                          border: Border.all(width: 1.5, color: Colors.black)),
//                      padding: const EdgeInsets.all(8.0),
//                      child: Column(
//                        crossAxisAlignment: CrossAxisAlignment.start,
//                        children: <Widget>[
//                          Row(
//                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                            children: <Widget>[
//                              MontserratText("PAYMENT METHOD", 14,
//                                  ultraLightTextColor, FontWeight.w600),
//                              Icon(Icons.tune)
//                            ],
//                          ),
//                          MontserratText("XXXX-XXXX-XXXX-1908", 16,
//                              Colors.black, FontWeight.bold)
//                        ],
//                      ),
//                    ),
                              _showTip || _summaryModel.tip != null
                                  ? Column(
                                      children: <Widget>[
                                        Separator(),
                                        amountDetails(
                                            "Tip", "${_summaryModel.tip}",
                                            fontWeight: FontWeight.bold,
                                            size: 22,
                                            fontType: false),
                                        Separator(),
                                        amountDetails(
                                            "Total", "\$${_summaryModel.total}",
                                            size: 22,
                                            fontWeight: FontWeight.bold,
                                            fontType: false)
                                      ],
                                    )
                                  : Container(),
                              _hasGivenReview || _summaryModel.rating != null
                                  ? Container(
                                      margin: const EdgeInsets.only(top: 16.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          MontserratText("Your review", 16,
                                              accentColor, FontWeight.bold),
                                          Row(
                                            children: <Widget>[
                                              RatingBar.readOnly(
                                                maxRating: 5,
                                                filledIcon: Icons.star,
                                                emptyIcon: Icons.star,
                                                halfFilledIcon: Icons.star_half,
                                                isHalfAllowed: true,
                                                filledColor: starColor,
                                                emptyColor: Colors.grey,
                                                halfFilledColor: accentColor,
                                                initialRating:
                                                    _summaryModel.rating != null
                                                        ? _summaryModel.rating.toDouble()
                                                        : 0.0,
                                                size: 20,
                                              ),
                                            ],
                                          ),
                                          MontserratText(
                                              _summaryModel.review != null ? "${_summaryModel.review}" : "",
                                              14,
                                              lightTextColor,
                                              FontWeight.normal),
                                        ],
                                      ),
                                    )
                                  : Container()
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        width: mediaQueryData.size.width,
                        bottom: mediaQueryData.size.height * 0.03,
                        child: Container(
                          margin: EdgeInsets.only(
                              left: mediaQueryData.size.width * 0.04,
                              right: mediaQueryData.size.width * 0.04),
                          child: Column(
                            children: <Widget>[
                              _summaryModel.canGiveTip
                                  ? Container(
                                      width: mediaQueryData.size.width,
                                      height: 50.0,
                                      margin:
                                          const EdgeInsets.only(bottom: 8.0),
                                      child: MyLightButton(
                                        "ADD TIP",
                                        _addTipButtonClick,
                                        textColor: Colors.black,
                                      ),
                                    )
                                  : Container(),
                              _summaryModel.canRateProvider
                                  ? Container(
                                      width: mediaQueryData.size.width,
                                      height: 50.0,
                                      child: MyDarkButton(
                                        "RATE JOHN",
                                        _rateButtonClick,
                                      ),
                                    )
                                  : Container(),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
      ),
    );
  }

  void _addTipButtonClick() async {
    var tipValue = await showDialog(
        context: context,
        builder: (_) =>
            InputDialog("ADD TIP", "Enter Amount", "\$0.00", "CONFIRM & PAY"));

    if (tipValue != null && tipValue != "") {
      setState(() {
        _showTip = true;
        _tip = "\$" + tipValue;
      });
      _postAddTip(double.parse(tipValue));
    }
  }

  void _rateButtonClick() async {
    var result = await showDialog(
        context: context,
        builder: (_) => DialogRating("Rate your experience", "Write a review",
            "Type here", "SUBMIT HERE"));

    if (result != null) {
      setState(() {
        _hasGivenReview = true;
        _rating = result["RATING"];
        _review = result["REVIEW"];
      });

//      print("RATING IS: ${_rating} and review is $_review");
      _postAddReview(_rating, _review);
    }
  }


  Widget amountDetails(String title, String amount,
      {double size = 16,
      FontWeight fontWeight = FontWeight.normal,
      bool fontType = true}) {
    return Container(
      margin: const EdgeInsets.only(top: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          fontType
              ? MontserratText("$title", size, lightTextColor, fontWeight)
              : QuicksandText("$title", size, lightTextColor, fontWeight),
          fontType
              ? MontserratText("$amount", size, lightTextColor, fontWeight)
              : QuicksandText("$amount", size, lightTextColor, fontWeight),
        ],
      ),
    );
  }
}

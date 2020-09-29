import 'dart:async';
import 'dart:convert';

import 'package:benji_seeker/My_Widgets/DescriptionTextWidget.dart';
import 'package:benji_seeker/My_Widgets/DialogYesNo.dart';
import 'package:benji_seeker/My_Widgets/MyDarkButton.dart';
import 'package:benji_seeker/My_Widgets/MyLightButton.dart';
import 'package:benji_seeker/My_Widgets/MyLoadingDialog.dart';
import 'package:benji_seeker/My_Widgets/MyToast.dart';
import 'package:benji_seeker/My_Widgets/Separator.dart';
import 'package:benji_seeker/My_Widgets/TransparentRoute.dart';
import 'package:benji_seeker/SharedPref/SavedData.dart';
import 'package:benji_seeker/constants/Constants.dart';
import 'package:benji_seeker/constants/MyColors.dart';
import 'package:benji_seeker/constants/Urls.dart';
import 'package:benji_seeker/custom_texts/MontserratText.dart';
import 'package:benji_seeker/custom_texts/QuicksandText.dart';
import 'package:benji_seeker/models/BiddersModel.dart';
import 'package:benji_seeker/models/CompletedJobModel.dart';
import 'package:benji_seeker/models/JobDetailModel.dart';
import 'package:benji_seeker/models/JustStatusModel.dart';
import 'package:benji_seeker/models/ProviderDetail.dart';
import 'package:benji_seeker/pages/Chat/ChatPage.dart';
import 'package:benji_seeker/pages/MainPages/OrderSequence/Calender/When.dart';
import 'package:benji_seeker/pages/PaymentSequence/SummaryPage.dart';
import 'package:benji_seeker/pages/PhotoViewPage.dart';
import 'package:benji_seeker/pages/ServiceProviders/itemServiceProvider.dart';
import 'package:benji_seeker/utils/DioHelper.dart';
import 'package:carousel_pro/carousel_pro.dart';
import 'package:dio/dio.dart';
import 'package:expandable_bottom_sheet/expandable_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class NewJobPageDetailPage extends StatefulWidget {
  final String jobId;
  final String generatedRecurringTime;
  final bool fromNotification;

  NewJobPageDetailPage(
      this.jobId, this.generatedRecurringTime, this.fromNotification);

  @override
  _NewJobPageDetailPageState createState() => _NewJobPageDetailPageState();
}

class _NewJobPageDetailPageState extends State<NewJobPageDetailPage> with WidgetsBindingObserver {

  DioHelper _dioHelper;
  var platform = MethodChannel('samples.flutter.dev/battery');
  bool _isLoading = true;
  bool _isError = false;

  bool _biddersLoading = true;
  bool _biddersError = false;
  List<Bidder> _biddersList = [];

  bool _providerLoading = true;
  bool _providerError = false;
  Provider _provider;

  bool _completedJobLoading = true;
  bool _completedJobError = false;
  CompletedJobModel _completedJobModel;

  Detail _jobDetail;
  JobDetailModel _jobDetailModel;

  @override
  void initState() {
    _dioHelper = DioHelper.instance;
    WidgetsBinding.instance.addObserver(this);

    _connectSocket();
    _isSocketConnected();

    _listenJobChanges(widget.jobId);

    _fetchData(widget.jobId);
    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _fetchData(widget.jobId);
    }
    super.didChangeAppLifecycleState(state);
  }

  void _reconnectSocket() {
    Timer(const Duration(seconds: 2), () {
      _connectSocket();
      _isSocketConnected();
      _listenJobChanges(widget.jobId);
    });
  }

  Future<void> _connectSocket() async {
    try {
      await platform.invokeMethod('connectSocket');
    } on PlatformException catch (e) {
      print("Failed to connect ${e.toString()}");
    }
  }

  Future<void> _isSocketConnected() async {
    try {
      await platform.invokeMethod('isSocketConnected');
    } on PlatformException catch (e) {
      print("Failed ${e.toString()}");
    }
  }

  Future<void> _addUserForSocket() async {
    try {
      SavedData savedData = new SavedData();
      String token = await savedData.getValue(TOKEN);
      await platform.invokeMethod('addUserForSocket', {"token": token});
    } on PlatformException catch (e) {
      print("Exception adding user to socket $e");
    }
  }

  Future<bool> _checkForJobChange(String processId) async {
    try {
      return await platform
          .invokeMethod("aJobChanged", {"processId": "$processId"});
    } on PlatformException catch (e) {
      print("Failed ${e.toString()}");
      return false;
    }
  }

  Future<bool> _checkForJobBidsChange(String processId) async {
    try {
      return await platform
          .invokeMethod("aJobBidChanged", {"processId": "$processId"});
    } on PlatformException catch (e) {
      print("Failed ${e.toString()}");
      return false;
    }
  }

  void _listenJobChanges(String processId) {
    platform.setMethodCallHandler((call) {
      if (call.method == "socketConnected") {
        _addUserForSocket().then((_) {
          _checkForJobChange(processId);
          _checkForJobBidsChange(processId);
        });
      } else if (call.method == "updateTheJob") {
        _fetchData(widget.jobId);
      } else if (call.method == "updateTheJobBid") {
        _fetchBiddersInfo();
      } else {
        print("METHOD CALLED: ${call.method}");
      }
      return;
    });
  }

  void _fetchData(String jobId) {
    _dioHelper.getRequest(BASE_URL + URL_JOB_DETAIL(jobId), {"token": {}}).then(
            (value) {
          print("JOB DETAIL RESPONSE: $value");
          JobDetailModel jobDetailModel =
          jobDetailResponseFromJson(json.encode(value.data));
          if (jobDetailModel.status) {
            _jobDetailModel = jobDetailModel;
            _jobDetail = jobDetailModel.detail;
            if (_jobDetail.nextStep == "active") {
              _fetchBiddersInfo();
            } else if (_jobDetail.nextStep == "booking_accepted") {
              if (_jobDetail.providerId != null) {
                _fetchProviderDetail(_jobDetail.providerId);
              }
            } else if (_jobDetail.nextStep == "summary") {
              _fetchCompletedJobInfo();
            } else if (_jobDetail.nextStep == "under_progress") {
              _fetchProviderDetail(_jobDetail.providerId);
            } else if (_jobDetail.nextStep == "arrived_at_location") {
              _fetchProviderDetail(_jobDetail.providerId);
            }
          } else {
            MyToast("${jobDetailModel.errors[0]}", context, position: 1);
            if (mounted) {
              setState(() {
                _isError = true;
              });
            }
          }
        }).catchError((error) {
      try {
        var err = error as DioError;
        print("ERROR JOB DETAIl: ${err.response.data}");
        if (err.type == DioErrorType.RESPONSE) {
          JobDetailModel jobDetailModel =
          jobDetailResponseFromJson(json.encode(err.response.data));
          MyToast("${jobDetailModel.errors[0]}", context, position: 1);
        } else {
          MyToast("${err.message}", context, position: 1);
        }
      } catch (e) {
//        MyToast("Unexpected Error! 17", context, position: 1);
      }
      if (mounted) {
        setState(() {
          _isError = true;
        });
      }
    }).whenComplete(() {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  _fetchBiddersInfo() {
    _dioHelper.getRequest(
        BASE_URL + URL_JOB_BIDS(widget.jobId), {"token": ""}).then((value) {
      print("BIDDER RESPONSE: $value");
      BiddersModel bidderModel =
      bidderResponseFromJson(json.encode(value.data));

      if (bidderModel.status) {
        _biddersList = bidderModel.bidders;
      } else {
        setState(() {
          _biddersError = true;
        });
      }
    }).catchError((error) {
      try {
        print("ERROR: $error");
        var err = error as DioError;
        print("BIDDER RESPONSE: $err");
        if (err.type == DioErrorType.RESPONSE) {
          BiddersModel bidderModel =
          bidderResponseFromJson(json.encode(err.response.data));
          MyToast("${bidderModel.errors[0]}", context, position: 1);
        } else {
          MyToast("${err.message}", context, position: 1);
        }
      } catch (e) {
        MyToast("Unexpected Error!", context, position: 1);
      }
      setState(() {
        _biddersError = true;
      });
    }).whenComplete(() {
      if (mounted) {
        setState(() {
          _biddersLoading = false;
        });
      }
    });
  }

  _fetchProviderDetail(String providerId) {
    _dioHelper.getRequest(BASE_URL + URL_PROVIDER_DETAIL(providerId),
        {"token": ""}).then((value) {
      ProviderDetail providerDetail =
      providerDetailResponseFromJson(json.encode(value.data));
      if (providerDetail.status) {
        _provider = providerDetail.provider;
      } else {
        MyToast("${providerDetail.errors[0]}", context, position: 1);
        setState(() {
          _providerError = true;
        });
      }
    }).catchError((error) {
      print("ERROR fetch provider details $error");
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
        _providerError = true;
      });
    }).whenComplete(() {
      setState(() {
        _providerLoading = false;
      });
    });
  }

  _fetchCompletedJobInfo() {
    _dioHelper.getRequest(BASE_URL + URL_COMPLETED_JOB(widget.jobId),
        {"token": ""}).then((value) {
      var completedJobModel =
      completedJobModelResponseFromJson(json.encode(value.data));
      if (completedJobModel.status) {
        _completedJobModel = completedJobModel;
        _fetchProviderDetail(_completedJobModel.providerId);
      } else {
        MyToast("${completedJobModel.errors[0]}", context);
        setState(() {
          _completedJobError = true;
        });
      }
    }).catchError((error) {
      try {
        var err = error as DioError;
        print("ERROR JOB DETAIl: ${err.response.data}");
        if (err.type == DioErrorType.RESPONSE) {
          JobDetailModel jobDetailModel =
          jobDetailResponseFromJson(json.encode(err.response.data));
          MyToast("${jobDetailModel.errors[0]}", context, position: 1);
        } else {
          MyToast("${err.message}", context, position: 1);
        }
      } catch (e) {
        MyToast("Unexpected Error!", context, position: 1);
      }
      setState(() {
        _completedJobError = true;
      });
    }).whenComplete(() {
      setState(() {
        _completedJobLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    return Scaffold(
      body: SafeArea(
        child: Container(
          width: mediaQueryData.size.width,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        "assets/background_summary.png",
                        width: mediaQueryData.size.width * 0.25,
                        height: mediaQueryData.size.height * 0.11,
                        fit: BoxFit.cover,
                      ),
                      MontserratText(
                          "3 photos", 10, separatorColor, FontWeight.normal)
                    ],
                  ),
                  Container(
                    margin: const EdgeInsets.only(left: 8.0, right: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            MontserratText(
                              "Lawn Mowing",
                              22,
                              accentColor,
                              FontWeight.bold,
                            ),
                            MontserratText(
                              "\$50",
                              16,
                              orangeColor,
                              FontWeight.w500,
                              left: 8.0,
                            ),
                          ],
                        ),
                        Container(
                          margin: const EdgeInsets.only(top: 16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              _textWithIcon(
                                  "assets/task_icon.png", "Mar 5, 2019"),
                              _separator(mediaQueryData),
                              MontserratText(
                                "7:30 AM",
                                14,
                                separatorColor,
                                FontWeight.normal,
                                left: 8.0,
                              )
                            ],
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(top: 16.0),
                          child: _textWithIcon(
                              "assets/location_orange_icon.png",
                              "Grandpa's Home"),
                        ),
                        Container(
                          margin: const EdgeInsets.only(top: 16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              _textWithHintAndIcon(
                                  true, "Recurring", "14 days"),
                              Container(
                                  margin: const EdgeInsets.only(
                                      left: 16.0, right: 8.0),
                                  child: _separator(mediaQueryData)),
                              _textWithHintAndIcon(
                                  false, "End Date", "Nov, 28, 2020")
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _button("assets/close_icon.png", Colors.black, borderColor,
                        "Cancel"),
                    _button("assets/reschedule_icon.png", accentColor,
                        accentColor.withOpacity(0.5), "Reschedule"),
                    _button("assets/close_icon.png", Colors.black, borderColor,
                        "Skip this Job"),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _textWithIcon(String image, String text) {
    return Container(
      child: Row(
        children: [
          Image.asset(
            "$image",
            color: accentColor,
            width: 18,
            height: 18,
          ),
          MontserratText(
            "$text",
            14,
            separatorColor,
            FontWeight.normal,
            left: 8.0,
            right: 8.0,
          )
        ],
      ),
    );
  }

  Widget _textWithHintAndIcon(bool showIcon, String hint, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        showIcon
            ? Icon(
                Icons.sync,
                color: accentColor,
                size: 18,
              )
            : Container(),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            MontserratText(
              "$hint",
              8,
              separatorColor,
              FontWeight.w100,
              left: 8.0,
            ),
            MontserratText(
              "$text",
              14,
              separatorColor,
              FontWeight.normal,
              left: 8.0,
              top: 2.0,
            )
          ],
        )
      ],
    );
  }

  Widget _button(
      String image, Color imageColor, Color borderColor, String text) {
    return Flexible(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        margin: const EdgeInsets.only(left: 8.0, right: 8.0),
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          border: Border.all(color: borderColor),
          borderRadius: BorderRadius.circular(10),
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset("$image", color: imageColor, width: 24, height: 24),
            MontserratText("$text", 12, separatorColor, FontWeight.normal)
          ],
        ),
      ),
    );
  }

  Widget _separator(MediaQueryData mediaQueryData) {
    return SizedBox(
      height: 20,
      width: 2.0,
      child: Container(
        color: Colors.black12,
      ),
    );
  }
}

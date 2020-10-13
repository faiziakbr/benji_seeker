import 'dart:async';
import 'dart:convert';

import 'package:benji_seeker/My_Widgets/DialogYesNo.dart';
import 'package:benji_seeker/My_Widgets/LocationAndDescriptionDialog.dart';
import 'package:benji_seeker/My_Widgets/MyDarkButton.dart';
import 'package:benji_seeker/My_Widgets/MyLoadingDialog.dart';
import 'package:benji_seeker/My_Widgets/MyToast.dart';
import 'package:benji_seeker/My_Widgets/SortingDialog.dart';
import 'package:benji_seeker/My_Widgets/TransparentRoute.dart';
import 'package:benji_seeker/SharedPref/SavedData.dart';
import 'package:benji_seeker/constants/Constants.dart';
import 'package:benji_seeker/constants/MyColors.dart';
import 'package:benji_seeker/constants/Urls.dart';
import 'package:benji_seeker/custom_texts/MontserratText.dart';
import 'package:benji_seeker/models/BiddersModel.dart';
import 'package:benji_seeker/models/CompletedJobModel.dart';
import 'package:benji_seeker/models/JobDetailModel.dart';
import 'package:benji_seeker/models/JustStatusModel.dart';
import 'package:benji_seeker/models/ProviderDetail.dart';
import 'package:benji_seeker/models/SkipModel.dart';
import 'package:benji_seeker/models/UpcomingJobModel.dart';
import 'package:benji_seeker/pages/Chat/ChatPage.dart';
import 'package:benji_seeker/pages/MainPages/OrderSequence/Calender/When.dart';
import 'package:benji_seeker/pages/PaymentSequence/SummaryPage.dart';
import 'package:benji_seeker/pages/PhotoViewPage.dart';
import 'package:benji_seeker/pages/ServiceProviders/itemServiceProvider.dart';
import 'package:benji_seeker/pages/bank/EditBankPage.dart';
import 'package:benji_seeker/utils/DioHelper.dart';
import 'package:dio/dio.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../BotNav.dart';

class NewJobDetailPage extends StatefulWidget {
  final String jobId;
  final String generatedRecurringTime;
  final bool fromNotification;
  // final List<ItemJobModel> recurrenceJobList;
  final bool jobChanged;

  NewJobDetailPage(this.jobId,
      {this.generatedRecurringTime,
      this.fromNotification = false,
      // this.recurrenceJobList,
      this.jobChanged = false});

  @override
  _NewJobDetailPageState createState() => _NewJobDetailPageState();
}

class _NewJobDetailPageState extends State<NewJobDetailPage>
    with WidgetsBindingObserver {
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

  bool _jobChanged = false;

  @override
  void initState() {
    _dioHelper = DioHelper.instance;
    WidgetsBinding.instance.addObserver(this);

    _jobChanged = widget.jobChanged;

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
      if (mounted) {
        setState(() {
          _providerLoading = false;
        });
      }
    });
  }

  _fetchCompletedJobInfo() {
    _dioHelper.getRequest(BASE_URL + URL_COMPLETED_JOB(widget.jobId),
        {"token": ""}).then((value) {
      var completedJobModel =
          completedJobModelResponseFromJson(json.encode(value.data));
      if (completedJobModel.status) {
        print("DATA: $value");
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
      if (mounted) {
        setState(() {
          _completedJobLoading = false;
        });
      }
    });
  }

  void _showPics() {
    List<NetworkImage> networkImages = [];
    for (String image in _jobDetail.images) {
      networkImages.add(NetworkImage("$BASE_JOB_IMAGE_URL$image"));
    }
    Navigator.of(context).push(TransparentRoute(
        builder: (BuildContext context) => PhotoViewPage(networkImages, 0)));
  }

  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    DateTime dateTimee;
    if (_isLoading == false && _isError == false) {
      dateTimee =
          DateTime.parse(widget.generatedRecurringTime ?? _jobDetail.when);
    }

    // List<NetworkImage> networkImages = [];
    // for (String image in _jobDetail.images) {
    //   networkImages.add(NetworkImage("$BASE_JOB_IMAGE_URL$image"));
    // }
    return WillPopScope(
      onWillPop: () async {
        Get.offAll(BotNavPage(
          pageIndex: 1,
        ));
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Get.offAll(BotNavPage(
              pageIndex: 1,
            )),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: SafeArea(
          child: _isLoading
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : _isError
                  ? Center(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          MontserratText("Job doesn't exists!", 18,
                              Colors.black.withOpacity(0.4), FontWeight.normal,
                              left: 16, right: 16),
                          MyDarkButton("Go Back", () {
                            Navigator.pop(context);
                          })
                        ],
                      ),
                    )
                  : Container(
                      padding: const EdgeInsets.all(16.0),
                      child: ListView(
                        physics: BouncingScrollPhysics(),
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              GestureDetector(
                                onTap: () => _showPics(),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10.0),
                                  child: Image.network(
                                    "$BASE_JOB_IMAGE_URL${_jobDetail.images[0]}",
                                    width: mediaQueryData.size.width * 0.2,
                                    height: mediaQueryData.size.width * 0.18,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Container(
                                width: mediaQueryData.size.width * 0.7,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Flexible(
                                          flex: 3,
                                          child: MontserratText(
                                            "${_jobDetail.category}",
                                            20,
                                            accentColor,
                                            FontWeight.bold,
                                            left: 16.0,
                                          ),
                                        ),
                                        Flexible(
                                          flex: 1,
                                          child: MontserratText(
                                            "\$${_jobDetail.estimatedIncome.toStringAsFixed(2)}",
                                            18,
                                            orangeColor,
                                            FontWeight.w500,
                                            left: 4.0,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      margin: const EdgeInsets.only(
                                          top: 12.0, left: 16.0),
                                      child: Row(
                                        children: [
                                          _textWithIcon("assets/task_icon.png",
                                              "${DateFormat.yMMMd().format(dateTimee.toLocal())}",
                                              iconColor: accentColor,
                                              fontWeight: _jobChanged
                                                  ? FontWeight.bold
                                                  : FontWeight.normal),
                                          _separator(mediaQueryData),
                                          MontserratText(
                                            "${DateFormat.jm().format(dateTimee.toLocal())}",
                                            14,
                                            separatorColor,
                                            FontWeight.normal,
                                            left: 8.0,
                                          )
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Container(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                GestureDetector(
                                  onTap: () => _showPics(),
                                  child: Container(
                                    width: mediaQueryData.size.width * 0.2,
                                    alignment: Alignment.center,
                                    child: MontserratText(
                                      "${_jobDetail.images.length} Photos",
                                      10,
                                      accentColor,
                                      FontWeight.normal,
                                      underline: true,
                                      top: 4.0,
                                    ),
                                  ),
                                ),
                                Container(
                                  width: mediaQueryData.size.width * 0.7,
                                  child: Stack(
                                    overflow: Overflow.visible,
                                    children: [
                                      GestureDetector(
                                        onTap: () => Get.dialog(
                                            LocationAndDescriptionDialog(
                                                _jobDetail.where,
                                                _jobDetail.description)),
                                        child: MontserratText(
                                          "View location and description",
                                          10,
                                          accentColor,
                                          FontWeight.normal,
                                          underline: true,
                                          left: 16.0,
                                          top: 4.0,
                                        ),
                                      ),
                                      _jobChanged
                                          ? Positioned(
                                              top: -10,
                                              left: 0,
                                              child: Card(
                                                elevation: 10,
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      MontserratText(
                                                          "Date has been changed.",
                                                          12,
                                                          separatorColor,
                                                          FontWeight.w500),
                                                      GestureDetector(
                                                          onTap: () {
                                                            setState(() {
                                                              _jobChanged =
                                                                  false;
                                                            });
                                                          },
                                                          child: MontserratText(
                                                              "OK",
                                                              12,
                                                              orangeColor,
                                                              FontWeight.bold,
                                                              left: 8.0))
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            )
                                          : Container()
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          _jobDetail.isRecurring
                              ? Row(
                                  children: [
                                    Container(
                                      width: mediaQueryData.size.width * 0.2,
                                    ),
                                    Container(
                                      margin: EdgeInsets.only(
                                          left: 16.0, top: 16.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          _textWithHintAndIcon(
                                              true,
                                              "Recurring",
                                              "${_jobDetail.recurringDays} days"),
                                          Container(
                                              margin: const EdgeInsets.only(
                                                  left: 8.0, right: 8.0),
                                              child:
                                                  _separator(mediaQueryData)),
                                          _textWithHintAndIcon(
                                              false,
                                              "End Date",
                                              "${DateFormat.yMMMd().format(DateTime.parse(_jobDetail.endDate).toLocal())}")
                                        ],
                                      ),
                                    ),
                                  ],
                                )
                              : Container(),
                          _jobDetail.nextStep == "summary" ||
                                  _jobDetail.transactionPending
                              ? Container()
                              : Container(
                                  margin: const EdgeInsets.symmetric(
                                      vertical: 16.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      _button(
                                          "assets/close_icon.png",
                                          Colors.black,
                                          borderColor,
                                          "Cancel",
                                          _cancelThisJob,
                                          marginRight: 4.0),
                                      _button(
                                          "assets/reschedule_icon.png",
                                          accentColor,
                                          accentColor.withOpacity(0.5),
                                          "Reschedule",
                                          _rescheduleThisJob,
                                          marginLeft: 4.0),
                                      _jobDetail.isRecurring
                                          ? _button(
                                              "assets/skip_icon.png",
                                              Colors.black,
                                              borderColor,
                                              "Skip this Job",
                                              _skipThisWeek,
                                              marginLeft: 8.0)
                                          : Container()
                                    ],
                                  ),
                                ),
                           _providerInfo(
                                  mediaQueryData, _jobDetail.nextStep)
                        ],
                      ),
                    ),
        ),
      ),
    );
  }

  _skipThisWeek() {
    Get.dialog(DialogYesNo(
      "Skip this job?",
      "",
      () {
        DateTime dateTime =
            DateTime.parse(widget.generatedRecurringTime ?? _jobDetail.when);
        // print("SKIP TIME: ${dateTime.toLocal()}");
        // widget.recurrenceJobList
        //     .removeWhere((element) => DateTime.parse(element.when) == dateTime);
        _skipJob(_jobDetailModel.detail.processId, dateTime);
      },
      () {
        Get.back();
      },
      useRichText: true,
      richText: _richText(),
    ));
  }

  Widget _richText() {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
          text: "Are you sure you want to skip ",
          style: TextStyle(
            fontSize: 15,
            color: navBarColor,
            fontWeight: FontWeight.normal,
            fontFamily: "Montserrat",
          ),
          children: [
            TextSpan(
                text: "${_jobDetail.subCategory}",
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontFamily: "Montserrat")),
            TextSpan(text: " for "),
            TextSpan(
                text:
                    "${DateFormat.yMMMd().format(DateTime.parse(widget.generatedRecurringTime ?? _jobDetail.when).toLocal())}",
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontFamily: "Montserrat"))
          ]),
    );
  }

  _rescheduleThisJob() {
    _rescheduleJob();
  }

  _cancelThisJob() {
    Get.dialog(DialogYesNo(
        "Cancel this service?", "Are you sure you want to cancel this service.",
        () {
      _cancelJob(_jobDetail.processId);
    }, () {
      Get.back();
    }));
  }

  _chatPage() async {
    print("HREE");
    var result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ChatPage(
                  widget.jobId,
                  _jobDetailModel,
                  providerName: _provider.nickName,
                )));
    if (result == null) _reconnectSocket();
  }

  _summaryPage() async {
    var result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => SummaryPage(_jobDetail.processId)));
    if (result == null) {
      setState(() {
        _isLoading = true;
        _isError = false;
      });
      _reconnectSocket();
      _fetchData(widget.jobId);
    }
  }

  _ratePage() async {
    var result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => SummaryPage(
                  _jobDetail.processId,
                  rateAndTip: true,
                )));
    print("RESULT ON BACK: $result");
    if (result == null) {
      setState(() {
        _isLoading = true;
        _isError = false;
      });
      _reconnectSocket();
      _fetchData(widget.jobId);
    }
  }

  Widget _providerInfo(MediaQueryData mediaQueryData, String jobNextStep) {
    print("JOB NEXT STEP: $jobNextStep");
    switch (jobNextStep) {
      case "active":
        return _browseProviders(mediaQueryData);
      case "booking_accepted":
        return _providerDetail(mediaQueryData);
      case "summary":
        return _providerSummary(mediaQueryData);
      case "under_progress":
        return _providerDetail(mediaQueryData);
      case "arrived_at_location":
        return _providerDetail(mediaQueryData);
      default:
        return Container(
          color: Colors.white,
        );
    }
  }

  Widget _browseProviders(MediaQueryData mediaQueryData) {
    return Container(
      width: mediaQueryData.size.width,
      child: _biddersLoading
          ? Container(
              height: 100,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
          : _biddersError
              ? Container(
                  margin: const EdgeInsets.only(top: 32.0),
                  child: Center(
                    child: MontserratText("Error loading bidders!", 18,
                        Colors.black.withOpacity(0.4), FontWeight.normal),
                  ),
                )
              : _biddersList.length > 0
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                         Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              MontserratText(
                                "${_biddersList.length} Providers Available",
                                18,
                                Colors.black,
                                FontWeight.bold,
                                bottom: 8.0,
                              ),
                              GestureDetector(
                                onTap: () async {
                                  var result = await Get.dialog(SortingDialog());
                                  if (result != null) {
                                    if (result == 0) {
                                      setState(() {
                                        _biddersList.sort((a, b) {
                                          return a.rating.compareTo(b.rating);
                                        });
                                      });
                                    } else if (result == 1) {
                                      setState(() {
                                        _biddersList.sort((a, b) {
                                          return b.rating.compareTo(a.rating);
                                        });
                                      });
                                    }
                                  }
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: borderColor)),
                                  padding: const EdgeInsets.all(4.0),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      MontserratText("Sort by", 14, navBarColor,
                                          FontWeight.normal),
                                      Icon(
                                        Icons.keyboard_arrow_down,
                                        size: 20,
                                      )
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),

                         ListView.builder(
                            shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: _biddersList.length,
                              itemBuilder: (context, index) {
                                return ItemServiceProvider(
                                    _biddersList[index], widget.jobId);
                              }),

                      ],
                    )
                  : Container(
                      margin: const EdgeInsets.only(top: 16.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                "assets/standing_person_icon.png",
                                width: 50,
                                height: 120,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Image.asset(
                                  "assets/warning_icon.png",
                                  width: 50,
                                  height: 50,
                                ),
                              )
                            ],
                          ),
                          MontserratText(
                              "Unfortunately, we don't have any professionals available to serve you right now",
                              14,
                              navBarColor,
                              FontWeight.w600,
                              textAlign: TextAlign.center,
                              top: 8.0)
                        ],
                      ),
                    ),
    );
  }

  Widget _providerDetail(MediaQueryData mediaQueryData) {
    return Container(
      width: mediaQueryData.size.width,
      child: _providerLoading
          ? Container(
              margin: const EdgeInsets.only(top: 32.0),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
          : _providerError
              ? Container(
                  margin: const EdgeInsets.only(top: 32.0),
                  child: Center(
                    child: MontserratText("Error loading provider.", 18,
                        Colors.black.withOpacity(0.4), FontWeight.normal),
                  ),
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _jobDetail.transactionPending
                        ? Container(
                            margin:
                                const EdgeInsets.only(top: 16.0, bottom: 16.0),
                            child: RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                  text:
                                      "We received some issues while charging your card for this transaction. Please ",
                                  style: TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: "Montserrat"),
                                  children: [
                                    TextSpan(
                                        text: "update",
                                        style: TextStyle(color: Colors.blue),
                                        recognizer: TapGestureRecognizer()
                                          ..onTap = () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        EditBankDetails()));
                                          }),
                                    TextSpan(
                                        text:
                                            " your credit card info or contact your bank.")
                                  ]),
                            ),
                            // child: MontserratText(
                            //     "We received some issues while charging your card for this transaction. Please update your credit card info or contact your bank.",
                            //     14,
                            //     Colors.red,
                            //     FontWeight.w600,
                            //     textAlign: TextAlign.center,
                            //     top: 8.0, bottom: 16.0,)
                          )
                        : Container(),
                    MontserratText(
                      "Provider Available",
                      18,
                      Colors.black,
                      FontWeight.bold,
                      bottom: 8.0,
                    ),
                    _textWithIcon("${_icon(_jobDetail.nextStep)}",
                        "${_nextStepTextFormatter(_jobDetail.nextStep)}",
                        iconColor: _jobDetail.nextStep == "under_progress"
                            ? orangeColor
                            : _jobDetail.nextStep == "booking_accepted"
                                ? null
                                : accentColor,
                        textColor: _jobDetail.nextStep == "under_progress"
                            ? orangeColor
                            : accentColor,
                        fontWeight: FontWeight.bold),
                    Container(
                      margin: const EdgeInsets.only(top: 16.0),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: FadeInImage(
                              fit: BoxFit.cover,
                              width: 70,
                              height: 70,
                              placeholder: AssetImage("assets/placeholder.png"),
                              image: NetworkImage(
                                  "$BASE_PROFILE_URL${_provider.profilePic}"),
                            ),
                          ),
                          Flexible(
                            child: Container(
                              margin: const EdgeInsets.only(left: 16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      MontserratText(
                                        "${_provider.nickName}",
                                        16,
                                        Colors.black,
                                        FontWeight.bold,
                                        right: 8.0,
                                        bottom: 8.0,
                                      ),
                                      _separator(mediaQueryData),
                                      MontserratText(
                                        _provider.rating != null
                                            ? "${_provider.rating.toStringAsFixed(1)}"
                                            : "0.0",
                                        16,
                                        Colors.black,
                                        FontWeight.bold,
                                        left: 8.0,
                                        bottom: 8.0,
                                      ),
                                      Icon(
                                        Icons.star,
                                        color: Colors.orange,
                                        size: 18,
                                      ),
                                    ],
                                  ),
                                  _textWithIcon(
                                      "assets/location_orange_icon.png",
                                      "${_provider.address}",
                                      iconColor: accentColor)
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    Align(
                      alignment: Alignment.topCenter,
                      child: Container(
                        width: 110,
                        height: 70,
                        margin: const EdgeInsets.only(top: 16.0),
                        child: Row(
                          children: [
                            _button("assets/message_icon.png", separatorColor,
                                borderColor, "Message", () {
                              _chatPage();
                            }),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
    );
  }

  Widget _providerSummary(MediaQueryData mediaQueryData) {
    return Container(
      width: mediaQueryData.size.width,
      margin: const EdgeInsets.only(top: 8.0),
      child: (_completedJobLoading || _providerLoading)
          ? Container(
              margin: const EdgeInsets.only(top: 32.0),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
          : (_completedJobError || _providerError)
              ? Container(
                  margin: const EdgeInsets.only(top: 32.0),
                  child: Center(
                    child: MontserratText("Error loading provider.", 18,
                        Colors.black.withOpacity(0.4), FontWeight.normal),
                  ),
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    MontserratText(
                      "Provider Available",
                      18,
                      Colors.black,
                      FontWeight.bold,
                      top: 4.0,
                      bottom: 8.0,
                    ),
                    _textWithIcon("${_icon(_jobDetail.nextStep)}",
                        "${_nextStepTextFormatter(_jobDetail.nextStep)}",
                        iconColor: _jobDetail.nextStep == "under_progress"
                            ? orangeColor
                            : _jobDetail.nextStep == "summary"
                                ? null
                                : accentColor,
                        textColor: _jobDetail.nextStep == "under_progress"
                            ? orangeColor
                            : accentColor,
                        fontWeight: FontWeight.bold),
                    Container(
                      margin: const EdgeInsets.only(top: 16.0),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: FadeInImage(
                              fit: BoxFit.cover,
                              width: 70,
                              height: 70,
                              placeholder: AssetImage("assets/placeholder.png"),
                              image: NetworkImage(
                                  "$BASE_PROFILE_URL${_provider.profilePic}"),
                            ),
                          ),
                          Flexible(
                            child: Container(
                              margin: const EdgeInsets.only(left: 16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      MontserratText(
                                        "${_provider.nickName}",
                                        16,
                                        Colors.black,
                                        FontWeight.bold,
                                        right: 8.0,
                                        bottom: 8.0,
                                      ),
                                      _separator(mediaQueryData),
                                      MontserratText(
                                        _provider.rating != null
                                            ? "${_provider.rating.toStringAsFixed(1)}"
                                            : "0.0",
                                        16,
                                        Colors.black,
                                        FontWeight.bold,
                                        left: 8.0,
                                        bottom: 8.0,
                                      ),
                                      Icon(
                                        Icons.star,
                                        color: Colors.orange,
                                        size: 18,
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      MontserratText("Estimate Amount", 12,
                                          lightTextColor, FontWeight.normal),
                                      MontserratText(
                                          "\$${_completedJobModel.estimatedWage.toStringAsFixed(1)}",
                                          12,
                                          lightTextColor,
                                          FontWeight.bold),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      MontserratText(
                                          "Time Spend (in minutes)",
                                          12,
                                          lightTextColor,
                                          FontWeight.normal),
                                      MontserratText(
                                          "${_completedJobModel.timeInMinutes}",
                                          12,
                                          lightTextColor,
                                          FontWeight.bold),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      MontserratText(
                                          "Amount paid (incl. of Tax)",
                                          12,
                                          lightTextColor,
                                          FontWeight.normal),
                                      MontserratText(
                                          "\$${_completedJobModel.amountPaid}",
                                          12,
                                          lightTextColor,
                                          FontWeight.bold),
                                    ],
                                  ),
                                  // _textWithIcon(
                                  //     "assets/location_orange_icon.png",
                                  //     "${_provider.address}",
                                  //     iconColor: accentColor)
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        !_completedJobModel.rated ||
                                !_completedJobModel.tipGiven
                            ? Flexible(
                                flex: 1,
                                child: Container(
                                  width: 120,
                                  height: 60,
                                  margin: const EdgeInsets.only(top: 16.0),
                                  child: Row(
                                    children: [
                                      _button(
                                          "assets/rate_icon.png",
                                          separatorColor,
                                          borderColor,
                                          "${_tipText(_completedJobModel.tipGiven, _completedJobModel.rated)}",
                                          () {
                                        _ratePage();
                                      }, marginRight: 4.0),
                                    ],
                                  ),
                                ),
                              )
                            : Container(),
                        Flexible(
                          flex: 1,
                          child: Container(
                            width: 120,
                            height: 60,
                            margin: const EdgeInsets.only(top: 16.0),
                            child: Row(
                              children: [
                                _button("assets/summary_icon.png",
                                    separatorColor, borderColor, "SUMMARY", () {
                                  _summaryPage();
                                }, marginLeft: 4.0),
                              ],
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
    );
  }

  String _icon(String nextStep) {
    switch (nextStep) {
      case "booking_accepted":
        return "assets/booking_accepted_icon.png";
      case "summary":
        return "assets/booking_accepted_icon.png";
      case "under_progress":
        return "assets/under_progress_icon.png";
      case "arrived_at_location":
        return "assets/location_orange_icon.png";
      default:
        return "";
    }
  }

  String _nextStepTextFormatter(String nextStep) {
    switch (nextStep) {
      case "active":
        return "Active";
      case "booking_accepted":
        return "Booking Accepted";
      case "summary":
        return "All Done!";
      case "under_progress":
        return "Under Progress";
      case "arrived_at_location":
        return "Arrived at Location";
      default:
        return "";
    }
  }

  Widget _textWithIcon(String image, String text,
      {Color textColor = separatorColor,
      FontWeight fontWeight = FontWeight.normal,
      Color iconColor}) {
    return Container(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(
            "$image",
            color: iconColor,
            width: 18,
            height: 18,
          ),
          // Flexible(
          //     child: Text(
          //   "$text",
          //   style: TextStyle(
          //       color: textColor,
          //       fontSize: 10,
          //       fontWeight: fontWeight,
          //       fontFamily: "Montserrat"),
          //   maxLines: 1,
          //       overflow: TextOverflow.ellipsis,
          // ))
          Flexible(
            child: MontserratText(
              "$text",
              14,
              textColor,
              fontWeight,
              left: 8.0,
              right: 8.0,
            ),
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

  Widget _button(String image, Color imageColor, Color borderColor, String text,
      Function onClick,
      {double marginLeft = 0.0, double marginRight = 0.0}) {
    return Flexible(
      child: GestureDetector(
        onTap: onClick,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          margin: EdgeInsets.only(left: marginLeft, right: marginRight),
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
              // MontserratText("$text", 12, separatorColor, FontWeight.normal)
              Container(
                margin: const EdgeInsets.only(top: 4.0),
                child: Text(
                  "$text",
                  style: TextStyle(
                      color: separatorColor,
                      fontSize: 10,
                      fontWeight: FontWeight.normal,
                      fontFamily: "Montserrat"),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              )
            ],
          ),
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

  void _rescheduleJob() async {
    var result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                When(null, rescheduleJob: true, jobDetail: _jobDetail)));
    if (result == null) _reconnectSocket();
  }

  void _skipJob(String processId, DateTime date) {
    Navigator.pop(context); //popping DialogYesNo
    MyLoadingDialog(context, "Skipping job...");
    DioHelper dioHelper = DioHelper.instance;

    //DateTime.now is used for timezoneOffset
    Map<String, dynamic> map = {
      "process_id": "$processId",
      "date":
          "${DateFormat("E MMM d y HH:mm:ss", Locale(Intl.getCurrentLocale()).languageCode).format(date)} ${_gmtFormatter(DateTime.now())}"
    };

    print("MAP: $map");

    dioHelper
        .postRequest(BASE_URL + URL_SKIP_JOB, {"token": ""}, map)
        .then((value) {
          print("SKIP RESPONSE: $value");
      SkipModel skipModel =
          skipResponseFromJson(json.encode(value.data));
      if (skipModel.status) {
        if (skipModel.nextdate != null) {
          Navigator.pop(context);
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => NewJobDetailPage(
                        widget.jobId,
                        generatedRecurringTime:
                            skipModel.nextdate,
                        jobChanged: true,
                      )));
        } else {
          while (Navigator.canPop(context)) {
            Navigator.pop(context);
          }
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => BotNavPage()));
        }
      } else {
        Navigator.pop(context);
        MyToast("${skipModel.errors[0]}", context);
      }
    }).catchError((error) {
      try {
        Navigator.pop(context);
        var err = error as DioError;
        if (err.type == DioErrorType.RESPONSE) {
          SkipModel justModel =
          skipResponseFromJson(json.encode(err.response.data));
          MyToast("${justModel.errors[0]}", context, position: 1);
        } else {
          MyToast("${err.message}", context, position: 1);
        }
      } catch (e) {
        MyToast("Unexpected Error!", context, position: 1);
      }
    });
  }

  void _cancelJob(String jobId) {
    Navigator.pop(context); //popping DialogYesNo
    MyLoadingDialog(context, "Cancelling job...");
    DioHelper dioHelper = DioHelper.instance;

    dioHelper.postRequest(BASE_URL + URL_CANCEL_JOB, {"token": ""},
        {"process_id": "$jobId"}).then((value) {
      print("CANCEL JOB RESPONSE: $value");
      JustStatusModel justStatusModel =
          justStatusResponseFromJson(json.encode(value.data));
      if (justStatusModel.status) {
        while (Navigator.canPop(context)) {
          Navigator.pop(context);
        }
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => BotNavPage()));
      } else {
        Navigator.pop(context);
        MyToast("${justStatusModel.errors[0]}", context);
      }
    }).catchError((error) {
      try {
        print("CANCEL JOB ERROR: $error");
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

  String _gmtFormatter(DateTime dateTime) {
    print("GMT: ${dateTime.timeZoneOffset.inHours}");
    if (dateTime.timeZoneOffset.isNegative) {
      return "GMT${dateTime.timeZoneOffset.inHours}00";
    } else {
      return "GMT+${dateTime.timeZoneOffset.inHours}00";
    }
  }

  String _tipText(bool tipGiven, bool rated) {
    if (!tipGiven && !rated) {
      return "Rate & Tip";
    } else if (!tipGiven) {
      return "Tip ${_provider.nickName}";
    } else if (!rated) {
      return "Rate ${_provider.nickName}";
    } else {
      return "";
    }
  }
}

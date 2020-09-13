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
import 'package:benji_seeker/models/UpcomingJobModel.dart';
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

import '../BotNav.dart';
import '../ImageViewer.dart';

class JobDetailPage extends StatefulWidget {
  final String jobId;
  final String generatedRecurringTime;
  final bool fromNotification;

  JobDetailPage(this.jobId,
      {this.generatedRecurringTime, this.fromNotification = false});

  @override
  _JobDetailPageState createState() => _JobDetailPageState();
}

class _JobDetailPageState extends State<JobDetailPage>
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

  GlobalKey<ExpandableBottomSheetState> key = new GlobalKey();
  int _contentAmount = 0;
  ExpansionStatus _expansionStatus = ExpansionStatus.contracted;

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
      CompletedJobModel completedJobModel =
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
        child: ExpandableBottomSheet(
          //use the key to get access to expand(), contract() and expansionStatus
          key: key,

          //optional
          //callbacks (use it for example for an animation in your header)
          onIsContractedCallback: () => print('contracted'),
          onIsExtendedCallback: () => print('extended'),

          //optional; default: Duration(milliseconds: 250)
          //The durations of the animations.
          animationDurationExtend: Duration(milliseconds: 500),
          animationDurationContract: Duration(milliseconds: 250),

          //optional; default: Curves.ease
          //The curves of the animations.
          animationCurveExpand: Curves.decelerate,
          animationCurveContract: Curves.ease,

          //optional
          //The content extend will be at least this height. If the content
          //height is smaller than the persistentContentHeight it will be
          //animated on a height change.
          //You can use it for example if you have no header.
          persistentContentHeight: _contentHeight(mediaQueryData),

          //required
          //This is the widget which will be overlapped by the bottom sheet.
          background: _isLoading
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
                  : _body(mediaQueryData),

          //optional
          //This widget is sticking above the content and will never be contracted.
          persistentHeader: !_isLoading && !_isError
              ? Container(
                  constraints: BoxConstraints.expand(height: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.9),
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset: Offset(0, 2), // changes position of shadow
                      ),
                    ],
                  ),
                  child: Center(
                    child: Container(
                      height: 4.0,
                      width: mediaQueryData.size.width * 0.25,
                      color: Color.fromARGB((0.25 * 255).round(), 0, 0, 0),
                    ),
                  ),
                )
              : Container(),

          //required
          //This is the content of the bottom sheet which will be extendable by dragging.
          expandableContent: !_isLoading && !_isError
              ? _bottomSheet(mediaQueryData, _jobDetail.nextStep)
              : Container(
                  width: 0.0,
                  height: 0.0,
                ),
        ),
      ),
    );
  }

  double _contentHeight(MediaQueryData mediaQueryData) {
    if (_jobDetail != null && _jobDetail.nextStep != null) {
      if (_jobDetail.nextStep == "booking_accepted") {
        return mediaQueryData.size.height * 0.4;
      } else if (_jobDetail.nextStep == "summary") {
        return mediaQueryData.size.height * 0.4;
      } else if (_jobDetail.nextStep == "under_progress") {
        return mediaQueryData.size.height * 0.18;
      } else if (_jobDetail.nextStep == "arrived_at_location") {
        return mediaQueryData.size.height * 0.18;
      } else {
        return mediaQueryData.size.height * 0.2;
      }
    }
    return 0.0;
  }

  Widget _body(MediaQueryData mediaQueryData) {
    DateTime dateTimee =
        DateTime.parse(widget.generatedRecurringTime ?? _jobDetail.when);

    List<NetworkImage> networkImages = [];
    for (String image in _jobDetail.images) {
      networkImages.add(NetworkImage("$BASE_JOB_IMAGE_URL$image"));
    }
    return SingleChildScrollView(
      child: Container(
        height: mediaQueryData.size.height * 1.3,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Stack(
              children: <Widget>[
                _carousel(mediaQueryData, networkImages),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    GestureDetector(
                      onTap: () {
                        if (Navigator.canPop(context))
                          Navigator.pop(context);
                        else {
                          while (Navigator.canPop(context)) {
                            Navigator.pop(context);
                          }
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => BotNavPage(
                                        fromNotifications:
                                            widget.fromNotification,
                                      )));
                        }
                      },
                      child: Container(
                        margin: const EdgeInsets.only(top: 8.0, left: 8.0),
                        padding: const EdgeInsets.all(4.0),
                        child: CircleAvatar(
                          backgroundColor: Colors.grey.withOpacity(0.7),
                          child: Icon(
                            Icons.close,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    )
//                          Container(
//                            color: Colors.grey.withOpacity(0.7),
//                            child: IconButton(
//                              icon: Icon(
//                                Icons.close,
//                                color: Colors.white,
//                              ),
//                              onPressed: () {
//                                Navigator.pop(context);
//                              },
//                            ),
//                          ),
                  ],
                )
              ],
            ),
            Container(
              margin: EdgeInsets.only(
                  top: 24.0,
                  left: mediaQueryData.size.width * 0.05,
                  right: mediaQueryData.size.width * 0.05),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  QuicksandText(
                    "${_jobDetail.category}",
                    22,
                    accentColor,
                    FontWeight.bold,
                    top: 8.0,
                  ),
                  MontserratText(
                    "${_jobDetail.subCategory}",
                    16,
                    Colors.black,
                    FontWeight.bold,
                    top: 8.0,
                    bottom: 8.0,
                  ),
                  _info(
                      mediaQueryData,
                      Icons.calendar_today,
                      "${DateFormat.yMMMd().add_jm().format(dateTimee.toLocal())}",
                      null,
                      isImage: true,
                      imagePath: "assets/calender_icon_2.png"),
                  _info(mediaQueryData, Icons.location_on,
                      "${_jobDetail.where}", null,
                      isImage: true,
                      imagePath: "assets/green_location_icon.png"),
                  DescriptionTextWidget(
                    text: "${_jobDetail.description}",
                  ),
//                  _info(mediaQueryData, Icons.menu, null,
//                      "${_jobDetail.description}"),
                  _jobDetail.isRecurring
                      ? _recurringTextWidget(mediaQueryData, _jobDetail)
                      : Container(),
                ],
              ),
            ),
            _buttons(mediaQueryData)
          ],
        ),
      ),
    );
  }

  Widget _buttons(MediaQueryData mediaQueryData) {
    if (_jobDetailModel.detail.nextStep == "active" &&
        _jobDetailModel.detail.isRecurring == false)
      return _cancelAndRescheduleButtons(mediaQueryData);
    else if (_jobDetailModel.detail.nextStep == "active" &&
        _jobDetailModel.detail.isRecurring) {
      return Column(
        children: [
          _cancelAndRescheduleButtons(mediaQueryData),
          Container(
            height: 50,
            width: mediaQueryData.size.width * 0.6,
            margin: const EdgeInsets.only(top: 16.0, bottom: 16.0),
            child: MyLightButton(
              "SKIP THIS WEEK",
              () {
                showDialog(
                    context: context,
                    barrierDismissible: bool.fromEnvironment("dismiss dialog"),
                    builder: (BuildContext context) {
                      return DialogYesNo("Skip upcoming job service?",
                          "Are you sure you want to skip this job.", () {
                        DateTime dateTime = DateTime.parse(
                            widget.generatedRecurringTime ?? _jobDetail.when);
                        _skipJob(_jobDetailModel.detail.processId, dateTime);
                      }, () {
                        Navigator.pop(context);
                      });
                    });
              },
              textColor: Colors.black,
              fontWeight: FontWeight.w600,
              borderColor: Colors.black,
            ),
          ),
        ],
      );
    } else {
      return Container();
    }
  }

  Widget _cancelAndRescheduleButtons(MediaQueryData mediaQueryData) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Flexible(
          flex: 1,
          child: Container(
            height: 50,
            width: mediaQueryData.size.width * 0.6,
            margin: const EdgeInsets.only(left: 16.0),
            child: MyLightButton(
              "CANCEL",
              () {
                showDialog(
                    context: context,
                    barrierDismissible: bool.fromEnvironment("dismiss dialog"),
                    builder: (BuildContext context) {
                      return DialogYesNo("Cancel this service?",
                          "Are you sure you want to cancel this service.", () {
                        _cancelJob(_jobDetail.processId);
                      }, () {
                        Navigator.pop(context);
                      });
                    });
              },
              textColor: Colors.black,
              fontWeight: FontWeight.w600,
              borderColor: Colors.black,
            ),
          ),
        ),
        Flexible(
          flex: 1,
          child: Container(
            height: 50,
            width: mediaQueryData.size.width * 0.6,
            margin: const EdgeInsets.only(left: 8.0, right: 16.0),
            child: MyDarkButton(
              "RESCHEDULE",
              () {
                _rescheduleJob();
              },
              textSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        )
      ],
    );
  }

  Widget _recurringTextWidget(
      MediaQueryData mediaQueryData, Detail jobDetailModel) {
    String recurringText =
        "Recurring, Every ${jobDetailModel.recurringDays} days until ${DateFormat.yMMMMd().format(DateTime.parse(jobDetailModel.endDate).toLocal())}";
    if (jobDetailModel.skipDates.length > 0)
      recurringText = _addSkipDays(jobDetailModel.skipDates, recurringText);

    return _info(mediaQueryData, Icons.sync, "$recurringText", null);
  }

  String _addSkipDays(List<dynamic> dates, String recurringText) {
    if (dates.length > 0) {
      recurringText += "\n **Excluding these dates: (";
      List<dynamic> skipDates = dates;
      for (int i = 0; i < skipDates.length; i++) {
        DateTime day = DateTime.parse(skipDates[i]);
        recurringText += "${DateFormat.MMMMd().format(day)}";
        recurringText += (i == skipDates.length - 1) ? "" : ", ";
      }
      recurringText += ")";
    }
    return recurringText;
  }

  Widget _carousel(
      MediaQueryData mediaQueryData, List<NetworkImage> networkImage) {
    return Container(
      width: mediaQueryData.size.width,
      height: mediaQueryData.size.height * 0.35,
      child: Carousel(
        dotSize: 6.0,
        dotSpacing: 15.0,
        dotColor: unselectedDotColor,
        dotIncreasedColor: Colors.white,
        indicatorBgPadding: 5.0,
        dotBgColor: Colors.transparent,
        images: networkImage,
        onImageTap: (index) {
          Navigator.of(context).push(TransparentRoute(
              builder: (BuildContext context) =>
                  PhotoViewPage(networkImage, index)));
        },
      ),
    );
  }

  Widget _info(MediaQueryData mediaQueryData, IconData icon, String title,
      String description,
      {bool isImage = false, String imagePath = ""}) {
    return Container(
      margin: const EdgeInsets.only(top: 8.0, bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          isImage
              ? Container(
                  margin: const EdgeInsets.only(left: 3),
                  child: Image.asset(
                    "$imagePath",
                    width: 16,
                    height: 16,
                  ),
                )
              : Icon(
                  icon,
                  color: accentColor,
                  size: 20,
                ),
          Container(
            width: mediaQueryData.size.width * 0.8,
            child: description == null
                ? MontserratText(
                    "$title",
                    16,
                    icon == Icons.sync ? redColor : lightTextColor,
                    FontWeight.w600,
                    left: 8.0,
                  )
                : (title != null && description != null)
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          MontserratText(
                            "$title",
                            16,
                            lightTextColor,
                            FontWeight.w600,
                            left: 8.0,
                          ),
                          MontserratText(
                            "$description",
                            14,
                            lightTextColor,
                            FontWeight.normal,
                            left: 8.0,
                            textAlign: TextAlign.left,
                          ),
                        ],
                      )
                    : MontserratText(
                        "$description",
                        14,
                        lightTextColor,
                        FontWeight.normal,
                        left: 8.0,
                      ),
          ),
        ],
      ),
    );
  }

  Widget _bottomSheet(MediaQueryData mediaQueryData, String jobNextStep) {
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
      height: mediaQueryData.size.height * 0.8,
      color: Colors.white,
      padding:
          EdgeInsets.symmetric(horizontal: mediaQueryData.size.width * 0.05),
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: MontserratText(
                "Browse Service Providers",
                20.0,
                lightTextColor,
                FontWeight.normal,
                textAlign: TextAlign.center,
              ),
            ),
            _biddersLoading
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : _biddersError
                    ? Center(
                        child: MontserratText("Error loading bidders!", 18,
                            Colors.black.withOpacity(0.4), FontWeight.normal),
                      )
                    : _biddersList.length > 0
                        ? Container(
                            height: mediaQueryData.size.height * 0.72,
                            child: ListView.builder(
                                physics: BouncingScrollPhysics(),
                                itemCount: _biddersList.length,
                                itemBuilder: (context, index) {
                                  return ItemServiceProvider(
                                      _biddersList[index], widget.jobId);
                                }),
                          )
                        : Center(
                            child: MontserratText(
                                "No one bid.",
                                18,
                                Colors.black.withOpacity(0.4),
                                FontWeight.normal),
                          ),
          ],
        ),
      ),
    );
  }

  Widget _providerDetail(MediaQueryData mediaQueryData) {
    print(
        "JOB DETAIL: ${_jobDetail.nextStep} and NextStep: ${_jobDetail.isRecurring}");
    return Container(
      color: Colors.white,
      child: _providerLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : _providerError
              ? Center(
                  child: MontserratText("Error loading provider.", 18,
                      Colors.black.withOpacity(0.4), FontWeight.normal),
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    ListTile(
                      leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: FadeInImage(
                            fit: BoxFit.cover,
                            width: 70,
                            height: 80,
                            placeholder: AssetImage("assets/placeholder.png"),
                            image: NetworkImage(
                                "$BASE_PROFILE_URL${_provider.profilePic}"),
                          )),
                      title: MontserratText("${_provider.nickName}", 16,
                          Colors.black, FontWeight.bold),
                      subtitle: MontserratText("${_provider.address}", 14,
                          lightTextColor, FontWeight.normal),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          MontserratText(
                              _provider.rating != null
                                  ? "${_provider.rating.toStringAsFixed(1)}"
                                  : "0.0",
                              14,
                              Colors.black,
                              FontWeight.bold),
                          Icon(
                            Icons.star,
                            color: Colors.orange,
                          ),
                          GestureDetector(
                            onTap: () async {
                              var result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ChatPage(
                                            widget.jobId,
                                            _jobDetailModel,
                                            providerName: _provider.nickName,
                                          )));
                              if (result == null) _reconnectSocket();
                            },
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: Container(
                                width: 40,
                                height: 40,
                                color: Colors.black,
                                child: Icon(
                                  Icons.message,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    (_jobDetail.nextStep == "under_progress" ||
                            _jobDetail.nextStep == "arrived_at_location")
                        ? Container()
                        : _jobDetail.isRecurring
                            ? GestureDetector(
                                onTap: () {
                                  showDialog(
                                      context: context,
                                      barrierDismissible: bool.fromEnvironment(
                                          "dismiss dialog"),
                                      builder: (BuildContext context) {
                                        return DialogYesNo(
                                            "Skip upcoming job service?",
                                            "Are you sure you want to skip this job.",
                                            () {
                                          DateTime dateTime = DateTime.parse(
                                              widget.generatedRecurringTime ??
                                                  _jobDetail.when);
                                          _skipJob(
                                              _jobDetailModel.detail.processId,
                                              dateTime);
                                        }, () {
                                          Navigator.pop(context);
                                        });
                                      });
                                },
                                child: Container(
                                    height: 50,
                                    width: mediaQueryData.size.width * 0.6,
                                    margin: const EdgeInsets.only(
                                        top: 16.0, bottom: 16.0),
                                    child: MyLightButton(
                                      "SKIP THIS WEEK",
                                      () {
                                        showDialog(
                                            context: context,
                                            barrierDismissible:
                                                bool.fromEnvironment(
                                                    "dismiss dialog"),
                                            builder: (BuildContext context) {
                                              return DialogYesNo(
                                                  "Skip upcoming job service?",
                                                  "Are you sure you want to skip this job.",
                                                  () {
                                                DateTime dateTime =
                                                    DateTime.parse(widget
                                                            .generatedRecurringTime ??
                                                        _jobDetail.when);
                                                _skipJob(
                                                    _jobDetailModel
                                                        .detail.processId,
                                                    dateTime);
                                              }, () {
                                                Navigator.pop(context);
                                              });
                                            });
                                      },
                                      textColor: Colors.black,
                                      fontWeight: FontWeight.w600,
                                      borderColor: Colors.black,
                                    ),
                                  ),

                              )
                            : Container(),
                    (_jobDetail.nextStep == "under_progress" ||
                            _jobDetail.nextStep == "arrived_at_location")
                        ? Container()
                        : Separator(
                            leftMargin: 16.0,
                            rightMargin: 16.0,
                          ),
                    (_jobDetail.nextStep == "under_progress" ||
                            _jobDetail.nextStep == "arrived_at_location")
                        ? Container()
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Flexible(
                                flex: 1,
                                child: Container(
                                  height: 50,
                                  width: mediaQueryData.size.width * 0.6,
                                  margin: const EdgeInsets.only(
                                      left: 16.0, bottom: 8.0),
                                  child: MyLightButton(
                                    "CANCEL",
                                    () {
                                      showDialog(
                                          context: context,
                                          barrierDismissible:
                                              bool.fromEnvironment(
                                                  "dismiss dialog"),
                                          builder: (BuildContext context) {
                                            return DialogYesNo(
                                                "Cancel this service?",
                                                "Are you sure you want to cancel this service.",
                                                () {
                                              _cancelJob(_jobDetail.processId);
                                            }, () {
                                              Navigator.pop(context);
                                            });
                                          });
                                    },
                                    textColor: Colors.black,
                                    fontWeight: FontWeight.w600,
                                    borderColor: Colors.black,
                                  ),
                                ),
                              ),
                              Flexible(
                                flex: 1,
                                child: Container(
                                  height: 50,
                                  width: mediaQueryData.size.width * 0.6,
                                  margin: const EdgeInsets.only(
                                      left: 8.0, right: 16.0, bottom: 8.0),
                                  child: MyDarkButton(
                                    "RESCHEDULE",
                                    () {
                                      _rescheduleJob();
                                    },
                                    textSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              )
                            ],
                          )
                  ],
                ),
    );
  }

  Widget _providerSummary(MediaQueryData mediaQueryData) {
    return Container(
      color: Colors.white,
      child: (_completedJobLoading || _providerLoading)
          ? Center(
              child: CircularProgressIndicator(),
            )
          : (_completedJobError || _providerError)
              ? Center(
                  child: MontserratText("Error loading.", 18,
                      Colors.black.withOpacity(0.4), FontWeight.normal),
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    ListTile(
                      leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: FadeInImage(
                            fit: BoxFit.cover,
                            width: 70,
                            height: 80,
                            placeholder: AssetImage("assets/placeholder.png"),
                            image: NetworkImage(
                                "$BASE_PROFILE_URL${_completedJobModel.profilePicture}"),
                          )),
                      title: MontserratText(
                          "${_completedJobModel.providerName}",
                          16,
                          Colors.black,
                          FontWeight.bold),
                      subtitle: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          MontserratText(
                              _provider.rating != null
                                  ? "${_provider.rating.toStringAsFixed(1)}"
                                  : "0.0",
                              14,
                              Colors.black,
                              FontWeight.bold),
                          Icon(
                            Icons.star,
                            color: Colors.orange,
                          )
                        ],
                      ),
//                      trailing: ClipRRect(
//                        borderRadius: BorderRadius.circular(8.0),
//                        child: Container(
//                          width: 40,
//                          height: 40,
//                          color: Colors.orange,
//                          child: Icon(
//                            Icons.local_hospital,
//                            color: Colors.white,
//                            size: 20,
//                          ),
//                        ),
//                      ),
                    ),
                    Separator(
                      leftMargin: 16.0,
                      rightMargin: 16.0,
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              MontserratText("Est Amount", 16, lightTextColor,
                                  FontWeight.normal),
                              MontserratText(
                                  "\$${_completedJobModel.estimatedWage.toStringAsFixed(2)}",
                                  16,
                                  lightTextColor,
                                  FontWeight.normal),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              MontserratText("Time Spent (in minutes)", 16,
                                  lightTextColor, FontWeight.normal),
                              MontserratText(
                                  "${_completedJobModel.timeInMinutes}",
                                  16,
                                  lightTextColor,
                                  FontWeight.normal),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              MontserratText("Amount paid", 16, lightTextColor,
                                  FontWeight.bold),
                              MontserratText(
                                  "\$${_completedJobModel.amountPaid}",
                                  16,
                                  lightTextColor,
                                  FontWeight.bold),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Separator(
                      leftMargin: 16.0,
                      rightMargin: 16.0,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        !_completedJobModel.rated ||
                                !_completedJobModel.tipGiven
                            ? Flexible(
                                flex: 1,
                                child: Container(
                                  height: 50,
                                  width: mediaQueryData.size.width * 0.6,
                                  margin: const EdgeInsets.only(
                                      left: 16.0, bottom: 8.0),
                                  child: MyLightButton(
                                    "${_tipText(_completedJobModel.tipGiven, _completedJobModel.rated)}",
                                    () async {
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
                                    },
                                    textColor: Colors.black,
                                    fontWeight: FontWeight.w600,
                                    borderColor: Colors.black,
                                  ),
                                ),
                              )
                            : Container(),
                        Flexible(
                          flex: 1,
                          child: Container(
                            height: 50,
                            width: mediaQueryData.size.width * 0.6,
                            margin: const EdgeInsets.only(
                                left: 8.0, right: 16.0, bottom: 8.0),
                            child: MyDarkButton(
                              "SUMMARY",
                              () async {
                                var result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            SummaryPage(_jobDetail.processId)));
                                if (result == null) {
                                  setState(() {
                                    _isLoading = true;
                                    _isError = false;
                                  });
                                  _reconnectSocket();
                                  _fetchData(widget.jobId);
                                }
                              },
                              textSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        )
                      ],
                    )
                  ],
                ),
    );
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

    Map<String, dynamic> map = {
      "process_id": "$processId",
      "date":
          "${DateFormat("E MMM d y HH:mm:ss", Locale(Intl.getCurrentLocale()).languageCode).format(date)} ${_gmtFormatter(date)}"
    };
    dioHelper
        .postRequest(BASE_URL + URL_SKIP_JOB, {"token": ""}, map)
        .then((value) {
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
    if (dateTime.timeZoneOffset.isNegative) {
      return "GMT${dateTime.timeZoneOffset.inHours}00";
    } else {
      return "GMT+${dateTime.timeZoneOffset.inHours}00";
    }
  }
}

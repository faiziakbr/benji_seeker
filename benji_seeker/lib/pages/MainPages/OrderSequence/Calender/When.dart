import 'dart:convert';

import 'package:benji_seeker/My_Widgets/MyDarkButton.dart';
import 'package:benji_seeker/My_Widgets/MyLoadingDialog.dart';
import 'package:benji_seeker/My_Widgets/MyToast.dart';
import 'package:benji_seeker/constants/MyColors.dart';
import 'package:benji_seeker/constants/Urls.dart';
import 'package:benji_seeker/custom_texts/MontserratText.dart';
import 'package:benji_seeker/models/CreateJobModel.dart';
import 'package:benji_seeker/models/JobDetailModel.dart';
import 'package:benji_seeker/models/JustStatusModel.dart';
import 'package:benji_seeker/models/PackageModel.dart';
import 'package:benji_seeker/pages/MainPages/OrderSequence/RecurringOptions/RecurringOptionsPage.dart';
import 'package:benji_seeker/utils/DioHelper.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../BotNav.dart';

class When extends StatefulWidget {
  final CreateJobModel createJobModel;
  final bool rescheduleJob;
  final Detail jobDetail;

  When(this.createJobModel, {this.rescheduleJob = false, this.jobDetail});

  @override
  _WhenState createState() => _WhenState();
}

class _WhenState extends State<When> {
  bool _showDatePickerSheet = false;
  String _type = "date";

  bool _setDateComplete = false;
  bool _setTimeComplete = false;
  bool _setRecurringComplete = false;

  bool _selected = true;

  bool _removeRecurringOption = false;

  //For rescheduling
  CreateJobModel _createJobModel;
  DioHelper _dioHelper;

  bool _isLoading = false;
  bool _isError = false;

  @override
  void initState() {
    _dioHelper = DioHelper.instance;
    if (widget.rescheduleJob) {
      _createJobModel = CreateJobModel();
      _createJobModel.jobTime = DateTime.parse(widget.jobDetail.when).toLocal();
      _setDateComplete = true;
      _setTimeComplete = true;
      if (widget.jobDetail.isRecurring) {
        _isLoading = true;
        _isError = false;
        _createJobModel.endTime =
            DateTime.parse(widget.jobDetail.endDate).toLocal();
        _fetchPackageDetails(widget.jobDetail.subCategoryId);
        _createJobModel.recurringText = "after ${widget.jobDetail.recurringDays} days";
        _createJobModel.isRecurringSet = true;
        _setRecurringComplete = true;
        _createJobModel.recurringDays = widget.jobDetail.recurringDays;
      } else {
        _isLoading = true;
        _isError = false;
        _fetchPackageDetails(widget.jobDetail.subCategoryId);
        _removeRecurringOption = false;
        _setRecurringComplete = false;
      }
    } else {
      _createJobModel = widget.createJobModel;
      if (_createJobModel.isJobTimeSet) {
        _setDateComplete = true;
        _setTimeComplete = true;
      } else {
        if (_createJobModel.createFromCalendar) {
          _setDateComplete = true;
        } else {
          _createJobModel.jobTime = DateTime(DateTime.now().year,
                  DateTime.now().month, DateTime.now().day, 5, 0, 0)
              .add(Duration(days: 7));
        }
      }
      if (_createJobModel.isRecurringSet) {
        _setRecurringComplete = true;
      }
    }
    super.initState();
  }

  void _fetchPackageDetails(String subCategoryId) {
    _dioHelper.getRequest(BASE_URL + URL_SUB_CATRGORY_DETAIL(subCategoryId),
        {"token": ""}).then((value) {
      print("RESPONSE: ${value.data}");
      PackageModel packageModel =
          packageResponseFromJson(json.encode(value.data));

      if (packageModel.status) {
        setState(() {
          _createJobModel.setRecurringOptions
              .addAll(packageModel.recurringOptions);
          _removeRecurringOption = false;
        });
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

  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios,
                color: Colors.black,
                size: 20,
              ),
              onPressed: () => Navigator.pop(context)),
          title: MontserratText(
              "Set Date & Time", 20, Colors.black, FontWeight.w500),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0.0,
        ),
        backgroundColor: Colors.white,
        body: GestureDetector(
          onTap: () {
            setState(() {
              _showDatePickerSheet = false;
            });
          },
          child: _isLoading
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
                        child: MontserratText("Error loading!", 18,
                            separatorColor, FontWeight.normal),
                      ),
                    )
                  : Container(
                      margin: EdgeInsets.only(
                          top: mediaQueryData.size.height * 0.05,
                          left: mediaQueryData.size.width * 0.05,
                          right: mediaQueryData.size.width * 0.05),
                      child: SingleChildScrollView(
                        child: Column(
                          children: <Widget>[
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _showDatePickerSheet = true;
                                  _type = "date";
                                });
                              },
                              child: _customCard(
                                  mediaQueryData,
                                  context,
                                  "assets/calender_icon.png",
                                  "DATE",
                                  _setDateComplete
                                      ? "Start date: ${DateFormat.yMd().format(_createJobModel.jobTime)}"
                                      : "Select start date.",
                                  _setDateComplete),
                            ),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _showDatePickerSheet = true;
                                  _type = "time";
                                });
                              },
                              child: _customCard(
                                  mediaQueryData,
                                  context,
                                  "assets/time_icon.png",
                                  "TIME",
                                  _setTimeComplete
                                      ? "Start time: ${DateFormat.jm().format(_createJobModel.jobTime)}"
                                      : "Set start time.",
                                  _setTimeComplete),
                            ),

//                    child: _removeRecurringOption ? Container() : _customCard(
//                        mediaQueryData,
//                        context,
//                        "assets/recursive_icon.png",
//                        "RECURRING",
//                        (_setRecurringComplete &&
//                                widget.createJobModel.endTime != null)
//                            ? "${widget.createJobModel.recurringText}\nEnd Data: ${DateFormat.yMd().format(widget.createJobModel.endTime)}"
//                            : "Is this recurring?", _setRecurringComplete),
                            _removeRecurringOption ||
                                    _createJobModel
                                            .setRecurringOptions.length ==
                                        0
                                ? Container()
                                : Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      MontserratText(
                                        "Recurring?",
                                        18,
                                        Colors.black,
                                        FontWeight.bold,
                                        bottom: 8.0,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          GestureDetector(
                                              onTap: () async {
                                                var result = await Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            RecurringOptionsPage(
                                                                _createJobModel)));
                                                if (result != null) {
                                                  setState(() {
                                                    _setRecurringComplete =
                                                        result;
                                                  });
                                                }
                                              },
                                              child: _recurringButtons(
                                                  mediaQueryData,
                                                  "YES",
                                                  _setRecurringComplete)),
                                          GestureDetector(
                                              onTap: () {
                                                _createJobModel.recurringText =
                                                    "";
                                                _createJobModel.isRecurringID =
                                                    "";
                                                _createJobModel.endTime = null;
                                                _createJobModel.isRecurringSet =
                                                    false;
                                                setState(() {
                                                  _setRecurringComplete = false;
                                                });
                                              },
                                              child: _recurringButtons(
                                                  mediaQueryData,
                                                  "NO",
                                                  !_setRecurringComplete))
                                        ],
                                      ),
                                      _createJobModel.isRecurringSet
                                          ? MontserratText(
                                              "Repeats ${_createJobModel.recurringText} till ${DateFormat.yMd().format(_createJobModel.endTime)}",
                                              18,
                                              Colors.black,
                                              FontWeight.w600,
                                              bottom: 16.0,
                                            )
                                          : Container()
                                    ],
                                  ),

                            Container(
                              width: mediaQueryData.size.width * 0.9,
                              height: 50,
                              child: MyDarkButton(
                                  widget.rescheduleJob
                                      ? "Reschedule"
                                      : "Continue", () {
//                        ${DateFormat.MMMM().add_d().add_y().add_jm().add_EEEE().format(widget.createJobModel.jobTime)}
                                print("JOB TIME: ${_createJobModel.jobTime}");

                                if (_setDateComplete && _setTimeComplete) {
                                  if (widget.rescheduleJob) {
                                    if (_createJobModel.jobTime
                                            .difference(DateTime.now())
                                            .inMinutes >
                                        45) {
                                      _createJobModel.emailDateLabel =
                                          "${DateFormat.EEEE().format(_createJobModel.jobTime)}, ${DateFormat.MMMM().add_d().format(_createJobModel.jobTime)}, ${DateFormat.y().add_jm().format(_createJobModel.jobTime)} (Local)";
                                      if (widget.rescheduleJob) {
                                        _rescheduleJob(
                                            widget.jobDetail.id,
                                            _createJobModel.jobTime,
                                            _createJobModel.emailDateLabel,
                                            recurring:
                                                _createJobModel.recurringDays,
                                            endTime: _createJobModel.endTime);
                                      } else {
                                        _rescheduleJob(
                                            widget.jobDetail.id,
                                            _createJobModel.jobTime,
                                            _createJobModel.emailDateLabel);
                                      }
                                      _createJobModel.isJobTimeSet = true;
                                    } else {
                                      MyToast("Can't set time under 45 minutes",
                                          context,
                                          position: 1);
                                    }
                                  } else {
                                    if (widget.createJobModel.jobTime
                                            .difference(DateTime.now())
                                            .inMinutes >
                                        45) {
                                      widget.createJobModel.jobTime =
                                          _createJobModel.jobTime;
                                      widget.createJobModel.emailDateLabel =
                                          "${DateFormat.EEEE().format(widget.createJobModel.jobTime)}, ${DateFormat.MMMM().add_d().format(widget.createJobModel.jobTime)}, ${DateFormat.y().add_jm().format(widget.createJobModel.jobTime)} (Local)";
                                      _createJobModel.isJobTimeSet = true;
                                      Navigator.pop(context, true);
                                    } else {
                                      MyToast("Can't set time under 45 minutes",
                                          context,
                                          position: 1);
                                    }
                                  }
                                } else {
                                  MyToast(
                                      "Date and Time are required!", context,
                                      position: 1);
                                }
                              }),
                            ),
                          ],
                        ),
                      ),
                    ),
        ),
        bottomSheet: _showIOSStyleDatePicker(mediaQueryData, _type));
  }

  Widget _customCard(MediaQueryData mediaQueryData, BuildContext context,
      String image, String title, String subTitle, bool isCompleted) {
    return Card(
      margin: EdgeInsets.only(bottom: mediaQueryData.size.height * 0.05),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
          side: BorderSide(color: accentColor, width: 1.0)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTile(
            contentPadding: EdgeInsets.only(top: 8.0),
            leading: Image.asset(
              image,
              width: mediaQueryData.size.width * 0.2,
              height: mediaQueryData.size.height * 0.15,
            ),
            title: MontserratText(title, 16, Colors.black, FontWeight.bold),
            subtitle:
                MontserratText(subTitle, 16, separatorColor, FontWeight.w300),
            trailing: isCompleted
                ? Container(
                    width: mediaQueryData.size.width * 0.1,
                    height: mediaQueryData.size.height * 0.2,
                    margin: const EdgeInsets.only(right: 8.0),
                    child: Icon(
                      Icons.check,
                      color: accentColor,
                    ),
                  )
                : Container(
                    width: 0,
                    height: 0,
                  ),
          ),
        ],
      ),
    );
  }

  Widget _recurringButtons(
      MediaQueryData mediaQueryData, String text, bool selected) {
    return Container(
        width: mediaQueryData.size.width * 0.45,
        margin: const EdgeInsets.only(bottom: 16.0),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
            border: Border.all(color: accentColor),
            borderRadius: text == "YES"
                ? BorderRadius.only(
                    topLeft: Radius.circular(8.0),
                    bottomLeft: Radius.circular(8.0))
                : BorderRadius.only(
                    topRight: Radius.circular(8.0),
                    bottomRight: Radius.circular(8.0))),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: 20,
              height: 20,
            ),
            MontserratText("$text", 22, selected ? Colors.green : Colors.black,
                FontWeight.bold),
            selected
                ? Icon(
                    Icons.check,
                    color: Colors.green,
                  )
                : SizedBox(
                    width: 20,
                    height: 20,
                  )
          ],
        ));
  }

  Widget _showIOSStyleDatePicker(MediaQueryData mediaQueryData, String type) {
    if (type == "date") {
      return AnimatedContainer(
        duration: Duration(milliseconds: 1800),
        height: _showDatePickerSheet ? mediaQueryData.size.height * 0.35 : 0,
        width: mediaQueryData.size.width,
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
        child: Column(
          children: <Widget>[
            MontserratText(
              "Select start date",
              18,
              Colors.black,
              FontWeight.w600,
              top: 16.0,
              bottom: 16.0,
            ),
            Flexible(
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.date,
                minimumDate: DateTime(DateTime.now().year, DateTime.now().month,
                    DateTime.now().day),
                initialDateTime: DateTime.now().add(Duration(days: 7)),
                onDateTimeChanged: (DateTime value) {
                  var time = _createJobModel.jobTime;
                  _createJobModel.jobTime = DateTime(value.year, value.month,
                      value.day, time.hour, time.minute);
                },
              ),
            ),
            Container(
                width: mediaQueryData.size.width * 0.35,
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                child: MyDarkButton("Done", () {
                  setState(() {
                    _showDatePickerSheet = false;
                    _setDateComplete = true;
                  });
                }))
          ],
        ),
      );
    } else if (type == "time") {
      return AnimatedContainer(
        duration: Duration(milliseconds: 1800),
        height: _showDatePickerSheet ? mediaQueryData.size.height * 0.35 : 0,
        width: mediaQueryData.size.width,
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
        child: Column(
          children: <Widget>[
            MontserratText(
              "Set start time",
              18,
              Colors.black,
              FontWeight.w600,
              top: 16.0,
              bottom: 16.0,
            ),
            Flexible(
              child: CupertinoDatePicker(
                initialDateTime: _createJobModel.jobTime,
                minuteInterval: 15,
                mode: CupertinoDatePickerMode.time,
                onDateTimeChanged: (DateTime value) {
                  var date = _createJobModel.jobTime;
                  _createJobModel.jobTime = DateTime(
                    date.year,
                    date.month,
                    date.day,
                    value.hour,
                    value.minute,
                  );
                },
              ),
            ),
            Container(
                width: mediaQueryData.size.width * 0.35,
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                child: MyDarkButton("Done", () {
                  setState(() {
                    _showDatePickerSheet = false;
                    _setTimeComplete = true;
                  });
                }))
          ],
        ),
      );
    } else if (type == "recurring") {
      return AnimatedContainer(
        duration: Duration(milliseconds: 1800),
        height: _showDatePickerSheet ? mediaQueryData.size.height * 0.25 : 0,
        width: mediaQueryData.size.width,
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            MontserratText(
              "Set recurring",
              18,
              Colors.black,
              FontWeight.w600,
              top: 16.0,
              bottom: 16.0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                GestureDetector(
                    onTap: () {
                      setState(() {
                        _selected = true;
                      });
                    },
                    child: MontserratText(
                        "Once a week",
                        16,
                        _selected ? Colors.black : separatorColor,
                        FontWeight.bold)),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _selected = false;
                    });
                  },
                  child: MontserratText(
                      "Every 2 weeks",
                      16,
                      _selected ? separatorColor : Colors.black,
                      FontWeight.bold),
                ),
              ],
            ),
            Container(
                width: mediaQueryData.size.width * 0.35,
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                child: MyDarkButton("Done", () {
                  setState(() {
                    _showDatePickerSheet = false;
                  });
                }))
          ],
        ),
      );
    } else {
      return Container();
    }
  }

  void _rescheduleJob(String jobId, DateTime startTime, String emailDateLabel,
      {int recurring = 0, DateTime endTime}) {
    MyLoadingDialog(context, "Rescheduling job");
    DioHelper dioHelper = DioHelper.instance;

    Map<String, dynamic> map;
    if (endTime == null || recurring == 0) {
      map = {
        "jobId": "$jobId",
        "start_date":
            "${DateFormat("E MMM d y HH:mm:ss", Locale(Intl.getCurrentLocale()).languageCode).format(startTime)} ${_gmtFormatter(startTime)}",
        "email_date_label": "$emailDateLabel"
      };
    } else {
      map = {
        "jobId": "$jobId",
        "start_date":
            "${DateFormat("E MMM d y HH:mm:ss", Locale(Intl.getCurrentLocale()).languageCode).format(startTime)} ${_gmtFormatter(startTime)}",
        "email_date_label": "$emailDateLabel",
        "recurring": recurring,
        "end_date":
            "${DateFormat("E MMM d y HH:mm:ss", Locale(Intl.getCurrentLocale()).languageCode).format(endTime)} ${_gmtFormatter(startTime)}",
      };
    }

    print("RESCHEDULE REQUEST: $map");

    dioHelper
        .postRequest(BASE_URL + URL_RESCHEDULE_JOB, {"token": ""}, map)
        .then((value) {
      Navigator.pop(context);
      print("UPCOMING JOBS: ${value.data}");
      JustStatusModel justStatusModel =
      justStatusResponseFromJson(json.encode(value.data));

      if (justStatusModel.status) {
        MyToast("Job rescheduled successfully", context, position: 1);
        while (Navigator.canPop(context)) {
          Navigator.pop(context);
        }
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => BotNavPage()));
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

  String _gmtFormatter(DateTime dateTime) {
    if (dateTime.timeZoneOffset.isNegative) {
      return "GMT${dateTime.timeZoneOffset.inHours}00";
    } else {
      return "GMT+${dateTime.timeZoneOffset.inHours}00";
    }
  }
}

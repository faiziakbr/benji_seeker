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
  bool _showEndTime = false;

  bool _setDateComplete = false;
  bool _setTimeComplete = false;
  bool _setRecurringComplete = false;

  bool _selected = true;

  //For rescheduling
  CreateJobModel _createJobModel = CreateJobModel();

  @override
  void initState() {
    if (widget.rescheduleJob) {
      _createJobModel.jobTime = DateTime.parse(widget.jobDetail.when);
      _setDateComplete = true;
      _setTimeComplete = true;
    } else {
      _createJobModel = widget.createJobModel;
      _createJobModel.jobTime = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 5, 0, 0).add(Duration(days: 7));
    }
    super.initState();
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
          child: Container(
            margin: EdgeInsets.only(
                top: mediaQueryData.size.height * 0.05,
                left: mediaQueryData.size.width * 0.05,
                right: mediaQueryData.size.width * 0.05),
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  GestureDetector(
                    onTap: () {
                      print("Clicked");
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
                            : "Select start date."),
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
                            : "Set start time."),
                  ),
                  GestureDetector(
                    onTap: () async {
                      var result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  RecurringOptionsPage(_createJobModel)));
                      if(result != null && result){
                        setState(() {
                          _setRecurringComplete = true;
                        });
                      }
                    },
                    child: _customCard(
                        mediaQueryData,
                        context,
                        "assets/recursive_icon.png",
                        "RECURRING",
                        (_setRecurringComplete && widget.createJobModel.endTime != null) ? "${widget.createJobModel.recurringText}\nEnd Data: ${DateFormat.yMd().format(widget.createJobModel.endTime)}" :"Is this recurring?"),
                  ),
                  Container(
                      width: mediaQueryData.size.width * 0.9,
                      height: 50,
                      child: MyDarkButton(
                          widget.rescheduleJob ? "Reschedule" : "Continue", () {
//                        ${DateFormat.MMMM().add_d().add_y().add_jm().add_EEEE().format(widget.createJobModel.jobTime)}
                      print("JOB TIME: ${_createJobModel.jobTime}");

                        if (widget.rescheduleJob) {
                          _createJobModel.emailDateLabel = "${DateFormat.EEEE().format(_createJobModel.jobTime)}, ${DateFormat.MMMM().add_d().format(_createJobModel.jobTime)}, ${DateFormat.y().add_jm().format(_createJobModel.jobTime)} (Local)";
                          _rescheduleJob(
                              widget.jobDetail.id,
                              _createJobModel.jobTime,
                             _createJobModel.emailDateLabel);
                        } else {
                          widget.createJobModel.jobTime = _createJobModel.jobTime;
                          widget.createJobModel.emailDateLabel = "${DateFormat.EEEE().format(widget.createJobModel.jobTime)}, ${DateFormat.MMMM().add_d().format(widget.createJobModel.jobTime)}, ${DateFormat.y().add_jm().format(widget.createJobModel.jobTime)} (Local)";
                          Navigator.pop(context, true);
                        }
                      }))
                ],
              ),
            ),
          ),
        ),
        bottomSheet: _showIOSStyleDatePicker(mediaQueryData, _type));
  }

  Widget _customCard(MediaQueryData mediaQueryData, BuildContext context,
      String image, String title, String subTitle) {
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
          ),
        ],
      ),
    );
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
                minimumDate: DateTime.now().add(Duration(days: 7)),
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
//                initialDateTime: DateTime(
//                    DateTime.now().year,
//                    DateTime.now().month,
//                    DateTime.now().day,
//                    DateTime.now().hour,
//                    15),
              initialDateTime: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 5, 0, 0).add(Duration(days: 7)),
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

    Map<String, dynamic> map = {
      "jobId": "$jobId",
      "start_date": "$startTime",
      "email_date_label": "$emailDateLabel"
    };

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
        while(Navigator.canPop(context)){
          Navigator.pop(context);
        }
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => BotNavPage()));
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
}

import 'dart:convert';

import 'package:benji_seeker/My_Widgets/MyToast.dart';
import 'package:benji_seeker/constants/MyColors.dart';
import 'package:benji_seeker/constants/Urls.dart';
import 'package:benji_seeker/custom_texts/MontserratText.dart';
import 'package:benji_seeker/custom_texts/QuicksandText.dart';
import 'package:benji_seeker/models/CreateJobModel.dart';
import 'package:benji_seeker/models/UpcomingJobModel.dart';
import 'package:benji_seeker/pages/JobDetailPage/JobDetailPage.dart';
import 'package:benji_seeker/pages/MainPages/OrderSequence/OrderPage1.dart';
import 'package:benji_seeker/utils/DioHelper.dart';
import 'package:date_util/date_util.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class NewDashboardPage extends StatefulWidget {
  @override
  _NewDashboardPageState createState() => _NewDashboardPageState();
}

class _NewDashboardPageState extends State<NewDashboardPage> {
  bool _isLoading = true;
  bool _isError = false;
  List<ItemJobModel> _itemJobModelList = [];
  DioHelper _dioHelper;

  var _selectedMonth = DateTime(DateTime.now().year,
      DateTime.now().month); // it should be a selected month
  int _daysInMonth = 0;

  List<DateTime> events = [];
  var dateTime = DateTime.now();

  List<String> _weekdaysName = [
    "Mon",
    "Tue",
    "Wed",
    "Thu",
    "Fri",
    "Sat",
    "Sun"
  ];

  List<String> _months = [
    "January",
    "February",
    "March",
    "April",
    "May",
    "June",
    "July",
    "August",
    "September",
    "October",
    "November",
    "December"
  ];

  @override
  void initState() {
    _dioHelper = DioHelper.instance;
    _fetchUpcomingJobs();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var dateUtil = DateUtil();
    _daysInMonth =
        dateUtil.daysInMonth(_selectedMonth.month, _selectedMonth.year);
    var date = DateTime(_selectedMonth.year, _selectedMonth.month);
    int startDay = 0;
    events.clear();
    if (!_isLoading) {
      _itemJobModelList.map((e) {
        var localDateTime = DateTime.parse(e.when).toLocal();
        var dateTime = DateTime(
            localDateTime.year, localDateTime.month, localDateTime.day);
//        print("EVENTS: $dateTime");
        events.add(dateTime);
      }).toList();
    }
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
                stops: [0.4, 0.8],
                colors: [Colors.white, Colors.green[100]],
                begin: Alignment.topLeft,
                end: Alignment.topRight),
          ),
        ),
        automaticallyImplyLeading: false,
        title: QuicksandText("Task Calendar", 22, accentColor, FontWeight.bold),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(34.0),
          child: Container(
            alignment: Alignment.topLeft,
            margin: const EdgeInsets.only(left: 16.0),
            child: DropdownButtonHideUnderline(
              child: DropdownButton(
                value: _months.elementAt(_selectedMonth.month - 1),
                items: _months.map((location) {
                  return DropdownMenuItem(
                    child: new MontserratText(
                        location, 16, Colors.black, FontWeight.bold),
                    value: location,
                  );
                }).toList(),
                onChanged: (String value) {
                  setState(() {
                    _selectedMonth = DateTime(
                        DateTime.now().year, _months.indexOf(value) + 1);
                  });
                },
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        shape: RoundedRectangleBorder(
            side: BorderSide(width: 1, color: orangeColor),
            borderRadius: BorderRadius.circular(10)),
        backgroundColor: orangeColor,
        child: Icon(Icons.add),
        onPressed: () {
          CreateJobModel createJobModel = CreateJobModel();
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => OrderPage1(createJobModel)));
        },
      ),
      body: SingleChildScrollView(
        child: _isLoading
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
                      child: MontserratText("Error loading jobs.", 18,
                          Colors.black.withOpacity(0.4), FontWeight.normal),
                    ),
                  )
                : Column(
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: _weekdaysName
                            .map((name) => MontserratText(
                                  "$name",
                                  14,
                                  separatorColor,
                                  FontWeight.w600,
                                  top: 16.0,
                                  bottom: 8.0,
                                ))
                            .toList(),
                      ),
                      Container(
                        height: mediaQueryData.size.height * 0.65,
                        child: GridView.builder(
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 7, childAspectRatio: 0.7),
                            itemCount: _daysInMonth + (date.weekday - 1),
                            itemBuilder: (context, index) {
                              if (index < (date.weekday - 1)) {
                                return Container(
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Colors.black.withOpacity(0.2),
                                          width: 1)),
                                );
                              } else {
                                startDay++;
                                bool isToday = false;

                                var boxDay = DateTime(_selectedMonth.year,
                                    _selectedMonth.month, startDay);

                                if (boxDay ==
                                    DateTime(
                                        DateTime.now().year,
                                        DateTime.now().month,
                                        DateTime.now().day)) {
                                  isToday = true;
                                }

                                if (events.contains(boxDay)) {
                                  return GestureDetector(
                                    onTap: () {
                                      print("EVENT CLICKED: $boxDay ");
                                      _itemJobModelList.forEach((element) {
                                        DateTime dateTime =
                                            DateTime.parse(element.when)
                                                .toLocal();
                                        if (boxDay ==
                                            DateTime(dateTime.year,
                                                dateTime.month, dateTime.day)) {
                                          Navigator.push(context,
                                              MaterialPageRoute(
                                                  builder: (context) {
                                            if (element.isWhenDeterminedLocally)
                                              return JobDetailPage(
                                                  element.jobId,
                                                  generatedRecurringTime:
                                                      element.when);
                                            else {
                                              return JobDetailPage(
                                                  element.jobId);
                                            }
                                          }));
                                        }
                                      });
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              color:
                                                  Colors.black.withOpacity(0.2),
                                              width: 1),
                                          color: isToday
                                              ? Colors.green
                                              : Colors.white),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          MontserratText(
                                            "$startDay",
                                            16,
                                            isToday
                                                ? Colors.white
                                                : separatorColor,
                                            FontWeight.bold,
                                            textAlign: TextAlign.center,
                                          ),
                                          Image.asset(
                                            isToday
                                                ? "assets/event_white_icon.png"
                                                : "assets/event_icon.png",
                                            width: 40,
                                            fit: BoxFit.contain,
                                          )
                                        ],
                                      ),
                                    ),
                                  );
                                } else
                                  return Container(
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                            color:
                                                Colors.black.withOpacity(0.2),
                                            width: 1),
                                        color: isToday
                                            ? Colors.green
                                            : Colors.white),
                                    child: MontserratText(
                                      "$startDay",
                                      16,
                                      isToday ? Colors.white : separatorColor,
                                      FontWeight.bold,
                                      textAlign: TextAlign.center,
                                    ),
                                  );
                              }
                            }),
                      ),
                    ],
                  ),
      ),
    );
  }

  void _fetchUpcomingJobs() {
    _dioHelper
        .getRequest(BASE_URL + URL_UPCOMING_JOBS, {"token": ""}).then((value) {
//      print("UPCOMING JOBS: ${value}");
      UpcomingJobsModel upcomingJobModel =
          upcomingJobsModelResponseFromJson(json.encode(value.data));

      if (upcomingJobModel.status) {
//          _itemJobModelList.addAll(upcomingJobModel.upcomingJobs);
//          _itemJobModelList = upcomingJobModel.upcomingJobs;
//        _addRecursiveEvents(_itemJobModelList);
        _addRecursiveEvents(upcomingJobModel.upcomingJobs);
      } else {
        setState(() {
          _isError = true;
        });
      }
    }).catchError((error) {
      try {
        var err = error as DioError;
        if (err.type == DioErrorType.RESPONSE) {
          UpcomingJobsModel categoryModel =
              upcomingJobsModelResponseFromJson(json.encode(err.response.data));
          MyToast("${categoryModel.errors[0]}", context, position: 1);
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

  void _addRecursiveEvents(List<ItemJobModel> _list) {
    try {
      for (ItemJobModel item in _list) {
//        print("JOB ID: ${item.jobId}");
        if (item.recurrence != null) {
          ItemJobModel itemJobModel = ItemJobModel(item.title, item.when,
              item.endDate, item.recurrence, item.jobId, item.skipDates);
          _itemJobModelList.add(itemJobModel);
//          print("ADDED 1 ${itemJobModel.toString()}");
          DateTime incrementedTime = DateTime.parse(item.when);
          DateTime endTime = DateTime.parse(item.endDate);
//          print("End TIME: $endTime");
          while (incrementedTime.isBefore(endTime)) {
//          temp.add(Duration(days: 7));
            incrementedTime =
                incrementedTime.add(Duration(days: item.recurrence));
//            print("temp TIME 1: $incrementedTime");
            if (incrementedTime.isBefore(endTime)) {
              item.when = incrementedTime.toIso8601String();
//              ItemJobModel itemJobModel = item;
              ItemJobModel itemJobModel = ItemJobModel(item.title, item.when,
                  item.endDate, item.recurrence, item.jobId, item.skipDates,
                  isWhenDeterminedLocally: true);
//              print("ADDED 2 ${itemJobModel.toString()}");
              _itemJobModelList.add(itemJobModel);
            }
          }
        } else {
          ItemJobModel itemJobModel = ItemJobModel(item.title, item.when,
              item.endDate, item.recurrence, item.jobId, item.skipDates);
//          print("ADDED 3 ${itemJobModel.toString()}");
          _itemJobModelList.add(itemJobModel);
        }
      }
      print("TOTAL JOB AFTER RECURR ADDED: ${_itemJobModelList.length}");
    } catch (e) {
      print("EXCEPTIOn :$e");
    }
  }
}

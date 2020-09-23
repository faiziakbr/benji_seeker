import 'dart:convert';

import 'package:benji_seeker/My_Widgets/MyToast.dart';
import 'package:benji_seeker/constants/MyColors.dart';
import 'package:benji_seeker/constants/Urls.dart';
import 'package:benji_seeker/custom_texts/MontserratText.dart';
import 'package:benji_seeker/custom_texts/QuicksandText.dart';
import 'package:benji_seeker/models/CreateJobModel.dart';
import 'package:benji_seeker/models/UpcomingJobModel.dart';
import 'package:benji_seeker/pages/MainPages/CalendarTypes/MonthlyViewPage.dart';
import 'package:benji_seeker/pages/MainPages/OrderSequence/OrderPage1.dart';
import 'package:benji_seeker/utils/DioHelper.dart';
import 'package:date_util/date_util.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:indexed_list_view/indexed_list_view.dart';

import '../ItemMonth.dart';

class NewDashboardPage extends StatefulWidget {
  final GlobalKey key;

  NewDashboardPage(this.key);

  @override
  NewDashboardPageState createState() => NewDashboardPageState();
}

class NewDashboardPageState extends State<NewDashboardPage>
    with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  bool _isError = false;
  List<ItemJobModel> _itemJobModelList = [];
  DioHelper _dioHelper;
  bool _monthlyView = true;

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

  List<DateTime> yearlyView = [];

//  ScrollController _scrollController;

  int _jumpToPosition = 1;
  var dateUtil = DateUtil();
  TabController _tabController;
  IndexedScrollController _indexedScrollController;

  @override
  void initState() {
    _tabController = TabController(vsync: this, length: 2);
    _dioHelper = DioHelper.instance;
    fetchUpcomingJobs();

    //yealy View
    var index = 0;
    var currentDate = DateTime.now();
    for (int i = currentDate.month; i < 13; i++) {
//      print("PREV DATE: ${DateTime(currentDate.year - 1, i)}");
      index += 1;
      yearlyView.add(DateTime(currentDate.year - 1, i));
    }

    for (int i = 1; i < 13; i++) {
//      print("CURR Date: ${DateTime(currentDate.year, i)}");
      if (DateTime(currentDate.year, i) ==
          DateTime(DateTime.now().year, DateTime.now().month)) {
        _jumpToPosition = index;
      }
      yearlyView.add(DateTime(currentDate.year, i));
      index += 1;
    }

    for (int i = 1; i <= currentDate.month; i++) {
//      print("NEXT DATE: ${DateTime(currentDate.year + 1, i)}");
      index += 1;
      yearlyView.add(DateTime(currentDate.year + 1, i));
    }

    _indexedScrollController =
        IndexedScrollController(initialIndex: _jumpToPosition);
//    for (int year = currentDate.year - 1; year < currentDate.year + 2; year++) {
//      for (int month = 1; month < 13; month++) {
//        if (DateTime(year, month) ==
//            DateTime(DateTime.now().year, DateTime.now().month)) {
//          _jumpToPosition = index;
////          _scrollController =
////              ScrollController(initialScrollOffset: _jumpToPosition * 560.0);
////          print("JUMP TO POS: $_jumpToPosition");
//        }
//        yearlyView.add(DateTime(year, month));
//        index += 1;
//      }
//    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //Monthly View
    _daysInMonth =
        dateUtil.daysInMonth(_selectedMonth.month, _selectedMonth.year);
//    var date = DateTime(_selectedMonth.year, _selectedMonth.month);
//    int startDay = 0;
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
    return DefaultTabController(
      length: 2,
      child: Scaffold(
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
          title:
              QuicksandText("Task Calendar", 22, accentColor, FontWeight.bold),
          actions: [
            _monthlyView
                ? DropdownButtonHideUnderline(
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
                  )
                : Container()
          ],
          bottom: PreferredSize(
              preferredSize: const Size.fromHeight(34.0),
              child: Container(
                margin: const EdgeInsets.only(bottom: 4.0),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: separatorColor)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                        onTap: () {
                          if (_monthlyView == false) {
                            setState(() {
                              _monthlyView = true;
                              _tabController.index = 0;
                            });
                          }
                        },
                        child: _monthlyYearlyToggleButton(
                            mediaQueryData, "MONTH", true)),
                    GestureDetector(
                        onTap: () {
                          if (_monthlyView) {
                            setState(() {
                              _monthlyView = false;
                              _tabController.index = 1;
//                              _autoScrollController.scrollToIndex(
//                                _jumpToPosition,
//                              );
                            });
//                          Timer(const Duration(milliseconds: 50), () {
//                            _scrollController.jumpTo(_jumpToPosition * 560.0);
//                          });
                          }
                        },
                        child: _monthlyYearlyToggleButton(
                            mediaQueryData, "YEAR", false))
                  ],
                ),
              )),
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
        body: _isLoading
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
//                  : _monthlyView
//                      ? _monthlyViewWidget(mediaQueryData, date, startDay)
//                      : _yearlyViewWidget(mediaQueryData),
                : TabBarView(
                    controller: _tabController,
                    children: [
                      MonthlyViewPage(_weekdaysName, _daysInMonth,
                          _selectedMonth, events, _itemJobModelList),
                      _yearlyViewWidget(mediaQueryData)
                    ],
                  ),
      ),
    );
  }

  Widget _yearlyViewWidget(MediaQueryData mediaQueryData) {
    return Container(
      width: mediaQueryData.size.width * 1,
//      height: mediaQueryData.size.height * 0.7,
      child: IndexedListView.builder(
          controller: _indexedScrollController,
//          shrinkWrap: true,
//          controller: _autoScrollController,
//          itemCount: yearlyView.length,
          maxItemCount: yearlyView.length - 1,
          minItemCount: 0,
          itemBuilder: (context, index) {
            return ItemMonth(yearlyView[index], events, _itemJobModelList);
//            return AutoScrollTag(
//                index: index,
//                key: ValueKey(index),
//                controller: _autoScrollController,
//                child: ItemMonth(yearlyView[index], events, _itemJobModelList));
          },
        emptyItemBuilder: (context, index){
            if(index < 0) {
              _indexedScrollController.animateToIndex(0);
            } else{
              _indexedScrollController.animateToIndex(yearlyView.length - 1);
              // _indexedScrollController.jumpTo(yearlyView.length - 1);
            }
            return Container(height: 5, width: 5);
        },
      ),
    );
  }

  Widget _monthlyYearlyToggleButton(
      MediaQueryData mediaQueryData, String text, bool monthlyView) {
    return Container(
        alignment: Alignment.center,
        width: mediaQueryData.size.width * 0.2475,
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: _monthlyView == monthlyView
                ? separatorColor
                : Colors.transparent),
        child: MontserratText(
          "$text",
          16,
          _monthlyView == monthlyView ? Colors.white : Colors.black,
          FontWeight.w600,
          maxLines: 1,
        ));
  }

//  Widget _jobImage(DateTime boxDay) {
//    String image = "";
//    for (var value in _itemJobModelList) {
//      DateTime dateTime = DateTime.parse(value.when).toLocal();
//      if (boxDay == DateTime(dateTime.year, dateTime.month, dateTime.day)) {
//        image = "$BASE_URL_CATEGORY${value.imageUrl}";
//      }
//    }
//    return SvgPicture.network(
//      "$image",
//      width: 40,
//      height: 40,
//      color: accentColor,
//      fit: BoxFit.contain,
//    );
//  }

  void fetchUpcomingJobs() {
    _dioHelper
        .getRequest(BASE_URL + URL_UPCOMING_JOBS, {"token": ""}).then((value) {
      print("UPCOMING JOBS: ${value}");
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
        print("FETCH JOBS: $error");
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

  //TODO SKIPS ARE REMAINING
  void _addRecursiveEvents(List<ItemJobModel> _list) {
    try {
      for (ItemJobModel item in _list) {
//        print("JOB ID: ${item.jobId}");
        if (item.recurrence != null) {
          ItemJobModel itemJobModel = ItemJobModel(
              item.title,
              item.when,
              item.endDate,
              item.recurrence,
              item.jobId,
              item.skipDates,
              item.imageUrl);
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
            DateTime justDate = DateTime(incrementedTime.year,
                incrementedTime.month, incrementedTime.day);
            if (_skipDays(item.skipDates).contains(justDate)) {
              continue;
            }
            if (incrementedTime.isBefore(endTime)) {
              item.when = incrementedTime.toIso8601String();
//              ItemJobModel itemJobModel = item;
              ItemJobModel itemJobModel = ItemJobModel(
                  item.title,
                  item.when,
                  item.endDate,
                  item.recurrence,
                  item.jobId,
                  item.skipDates,
                  item.imageUrl,
                  isWhenDeterminedLocally: true);
//              print("ADDED 2 ${itemJobModel.toString()}");
              _itemJobModelList.add(itemJobModel);
            }
          }
        } else {
          ItemJobModel itemJobModel = ItemJobModel(
            item.title,
            item.when,
            item.endDate,
            item.recurrence,
            item.jobId,
            item.skipDates,
            item.imageUrl,
          );
//          print("ADDED 3 ${itemJobModel.toString()}");
          _itemJobModelList.add(itemJobModel);
        }
      }
//      print("TOTAL JOB AFTER RECURR ADDED: ${_itemJobModelList.length}");
    } catch (e) {
      print("EXCEPTIOn :$e");
    }
  }

  List<DateTime> _skipDays(List<dynamic> dates) {
    List<DateTime> skipDatesList = List();
    if (dates.length > 0) {
      List<dynamic> skipDates = dates;
      for (int i = 0; i < skipDates.length; i++) {
        DateTime day = DateTime.parse(skipDates[i]);
        skipDatesList.add(DateTime(day.year, day.month, day.day));
      }
    }
    return skipDatesList;
  }
}

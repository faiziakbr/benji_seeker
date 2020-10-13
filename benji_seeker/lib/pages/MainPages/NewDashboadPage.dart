import 'dart:collection';
import 'dart:convert';

import 'package:benji_seeker/My_Widgets/InfoDialog.dart';
import 'package:benji_seeker/My_Widgets/MyToast.dart';
import 'package:benji_seeker/My_Widgets/ScheduledJobDailog.dart';
import 'package:benji_seeker/SharedPref/SavedData.dart';
import 'package:benji_seeker/constants/Constants.dart';
import 'package:benji_seeker/constants/MyColors.dart';
import 'package:benji_seeker/constants/Urls.dart';
import 'package:benji_seeker/custom_texts/MontserratText.dart';
import 'package:benji_seeker/custom_texts/QuicksandText.dart';
import 'package:benji_seeker/models/CreateJobModel.dart';
import 'package:benji_seeker/models/UpcomingJobModel.dart';
import 'package:benji_seeker/pages/MainPages/OrderSequence/OrderPage1.dart';
import 'package:benji_seeker/utils/DioHelper.dart';
import 'package:date_util/date_util.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
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

  // bool _monthlyView = true;

  List<DateTime> events = [];
  var dateTime = DateTime.now();

  // List<String> _locationNames = ["NY 10001 USA", "Denvor CO, USA"];

  List<DateTime> yearlyView = [];

  int _jumpToPosition = 1;
  var dateUtil = DateUtil();
  IndexedScrollController _indexedScrollController;
  List<int> _yearList = List();

  @override
  void initState() {
    _dioHelper = DioHelper.instance;
    fetchUpcomingJobs(DateTime.now().year.toString());
    _yearList.add(DateTime.now().year);

    var index = 0;
    var currentDate = DateTime.now();
    for (int i = currentDate.month; i < 13; i++) {
      index += 1;
      yearlyView.add(DateTime(currentDate.year - 1, i));
    }

    for (int i = 1; i < 13; i++) {
      if (DateTime(currentDate.year, i) ==
          DateTime(DateTime.now().year, DateTime.now().month)) {
        _jumpToPosition = index;
      }
      yearlyView.add(DateTime(currentDate.year, i));
      index += 1;
    }

    for (int i = 1; i <= currentDate.month; i++) {
      index += 1;
      yearlyView.add(DateTime(currentDate.year + 1, i));
    }

    _indexedScrollController =
        IndexedScrollController(initialIndex: _jumpToPosition);

    SavedData savedData = SavedData();
    savedData.getBoolValue(FIRST_TIME_DASHBOARD).then((value) {
      if (value != null && value) {
        Get.dialog(InfoDialog());
        savedData.setBoolValue(FIRST_TIME_DASHBOARD, false);
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    events.clear();
    if (!_isLoading) {
      _itemJobModelList.map((e) {
        var localDateTime = DateTime.parse(e.when).toLocal();
        var dateTime = DateTime(
            localDateTime.year, localDateTime.month, localDateTime.day);
        // print("EVENTS: $dateTime");
        events.add(dateTime);
      }).toList();
    }

    MediaQueryData mediaQueryData = MediaQuery.of(context);
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        flexibleSpace: Container(
          color: Colors.white,
          // decoration: BoxDecoration(
          //   gradient: LinearGradient(
          //       stops: [0.4, 0.8],
          //       colors: [Colors.white, Colors.green[100]],
          //       begin: Alignment.topLeft,
          //       end: Alignment.topRight),
          // ),
        ),
        automaticallyImplyLeading: false,
        title: QuicksandText("Task Calendar", 22, accentColor, FontWeight.bold),
        actions: [
          GestureDetector(
              onTap: () {
                _indexedScrollController.animateToIndex(_jumpToPosition);
              },
              child: _iconWithDay()),
          GestureDetector(
            onTap: () {
              Get.dialog(InfoDialog());
            },
            child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Image.asset(
                  "assets/question_icon.png",
                  width: 22,
                  height: 22,
                )),
          )
        ],
        // bottom: PreferredSize(
        //     preferredSize: const Size.fromHeight(34.0),
        //     child: Container(
        //       margin: const EdgeInsets.only(left: 8.0, right: 8.0),
        //       child: Row(
        //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //         children: [
        //           Row(
        //             children: [
        //               Icon(
        //                 Icons.location_on,
        //                 size: 18,
        //                 color: separatorColor,
        //               ),
        //               SizedBox(
        //                 width: 8.0,
        //               ),
        //               DropdownButtonHideUnderline(
        //                 child: DropdownButton(
        //                   value: _locationNames[1],
        //                   items: _locationNames.map((location) {
        //                     return DropdownMenuItem(
        //                       child: new MontserratText(location, 12,
        //                           separatorColor, FontWeight.normal),
        //                       value: location,
        //                     );
        //                   }).toList(),
        //                   onChanged: (String value) {
        //                     // setState(() {
        //                     //   _selectedMonth = DateTime(
        //                     //       DateTime.now().year, _locationNames.indexOf(value) + 1);
        //                     // });
        //                   },
        //                 ),
        //               )
        //             ],
        //           ),
        //           IconButton(
        //             onPressed: () {
        //               Get.dialog(ZipCodeDialog());
        //             },
        //             icon: Icon(
        //               Icons.calendar_today,
        //               size: 18,
        //             ),
        //           )
        //         ],
        //       ),
        //     )),
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
              color: Colors.white,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
          : _isError
              ? Container(
                  color: Colors.white,
                  height: mediaQueryData.size.height * 0.75,
                  child: Center(
                    child: MontserratText("Error loading jobs.", 18,
                        Colors.black.withOpacity(0.4), FontWeight.normal),
                  ),
                )
//                  : _monthlyView
//                      ? _monthlyViewWidget(mediaQueryData, date, startDay)
//                      : _yearlyViewWidget(mediaQueryData),
              : _yearlyViewWidget(mediaQueryData),
      // bottomSheet: Card(
      //   color: Colors.white,
      //   child: Container(
      //     child: Column(
      //       mainAxisSize: MainAxisSize.min,
      //       children: [
      //         Align(
      //           alignment: Alignment.topRight,
      //           child: IconButton(
      //             onPressed: () {},
      //             icon: Icon(Icons.close),
      //           ),
      //         ),
      //         Container(
      //           height: mediaQueryData.size.height * 0.4,
      //           width: mediaQueryData.size.width,
      //           child: ListView.builder(
      //             itemCount: _scheduledList.length,
      //             itemBuilder: (context, index){
      //               return Container(
      //                 height: 10,
      //                 // margin: const EdgeInsets.only(bottom: 8.0),
      //                 // decoration: BoxDecoration(
      //                 //     borderRadius: BorderRadius.circular(12.0),
      //                 //     shape: BoxShape.rectangle,
      //                 //     border: Border.all(color: accentColor, width: 1)),
      //                 // child: InkWell(
      //                 //   onTap: () {
      //                 //     // Navigator.push(context, MaterialPageRoute(builder: (context) => JobDetailPage(itemCompletedModel.processId)));
      //                 //   },
      //                 //   child: ListTile(
      //                 //     leading: Container(
      //                 //       width: mediaQueryData.size.width * 0.13,
      //                 //       height: mediaQueryData.size.width * 0.1,
      //                 //       child: SvgPicture.network(
      //                 //         "$BASE_URL_CATEGORY${_scheduledList[index].imageUrl}",
      //                 //         color: accentColor,
      //                 //         fit: BoxFit.contain,
      //                 //       ),
      //                 //       margin: EdgeInsets.all(5.0),
      //                 //     ),
      //                 //     title: MontserratText("${_scheduledList[index].title}", 16,
      //                 //         Colors.black, FontWeight.bold),
      //                 //     subtitle: MontserratText(
      //                 //         "${DateFormat.yMMMd().add_jm().format(DateTime.parse(_scheduledList[index].when).toLocal())}",
      //                 //         14,
      //                 //         lightTextColor,
      //                 //         FontWeight.normal),
      //                 //   ),
      //                 // ),
      //               );
      //             }
      //           ),
      //         )
      //       ],
      //     ),
      //   ),
      // ),
    );
  }

  Widget _iconWithDay() {
    return Align(
      alignment: Alignment.center,
      child: Stack(
        overflow: Overflow.visible,
        alignment: AlignmentDirectional.center,
        children: [
          Icon(
            Icons.calendar_today,
            color: Colors.black,
            size: 22,
          ),
          Positioned(
            bottom: 2.0,
            child: Text("${DateTime.now().day}",
                style: TextStyle(color: accentColor, fontSize: 10),
                textAlign: TextAlign.left),
          ),
        ],
      ),
    );
  }

  Widget _yearlyViewWidget(MediaQueryData mediaQueryData) {
    return Container(
      width: mediaQueryData.size.width * 1,
      color: Colors.white,
      child: IndexedListView.builder(
        controller: _indexedScrollController,
        maxItemCount: yearlyView.length - 1,
        minItemCount: 0,
        itemBuilder: (context, index) {
          return ItemMonth(yearlyView[index], events, _itemJobModelList,
              _itemClick, _itemPositionListener);
        },
        emptyItemBuilder: (context, index) {
          if (index < 0) {
            _indexedScrollController.animateToIndex(0);
          } else {
            _indexedScrollController.animateToIndex(yearlyView.length - 1);
          }
          return Container(height: 5, width: 5);
        },
      ),
    );
  }

  void _itemClick(List<ItemJobModel> data, DateTime date) {

    List<ItemJobModel> uniqueData = List();
    Map<String, ItemJobModel> map = Map();
    for (ItemJobModel value in data) {
      map["${value.jobId}"] = value;
    }

    map.forEach((key, value) {
      uniqueData.add(value);
    });

    Get.dialog(ScheduledJobDialog(uniqueData, date, _itemJobModelList));
  }

  void _itemPositionListener(DateTime dateTime) {
    if (!_yearList.contains(dateTime.year)) {
      _yearList.add(dateTime.year);
      fetchUpcomingJobs(dateTime.year.toString());
    }
  }

  // Widget _monthlyYearlyToggleButton(
  //     MediaQueryData mediaQueryData, String text, bool monthlyView) {
  //   return Container(
  //       alignment: Alignment.center,
  //       width: mediaQueryData.size.width * 0.2475,
  //       padding: const EdgeInsets.symmetric(vertical: 8.0),
  //       decoration: BoxDecoration(
  //           borderRadius: BorderRadius.circular(20),
  //           color: _monthlyView == monthlyView
  //               ? separatorColor
  //               : Colors.transparent),
  //       child: MontserratText(
  //         "$text",
  //         16,
  //         _monthlyView == monthlyView ? Colors.white : Colors.black,
  //         FontWeight.w600,
  //         maxLines: 1,
  //       ));
  // }

  void fetchUpcomingJobs(String year) {
    DioHelper dioHelper = DioHelper.instance;
    dioHelper.getRequest(BASE_URL + URL_UPCOMING("$year"), {"token": ""}).then(
        (value) {
      UpcomingJobsModel upcomingJobModel =
          upcomingJobsModelResponseFromJson(json.encode(value.data));
      print("UPCOMING JOBS $year: $value");
      if (upcomingJobModel.status) {
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
        print("ERROR: ${e.toString()}");
        MyToast("Unexpected Error!", context, position: 1);
      }
      setState(() {
        _isError = true;
      });
    }).whenComplete(() {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

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
              item.imageUrl,
              item.subCategory,
              item.status,
              item.package,
              item.hours);
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
                  item.subCategory,
                  item.status,
                  item.package,
                  item.hours,
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
              item.subCategory,
              item.status,
              item.package,
              item.hours);
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

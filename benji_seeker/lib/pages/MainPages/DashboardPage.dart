import 'dart:convert';
import 'dart:io';

import 'package:benji_seeker/My_Widgets/MyToast.dart';
import 'package:benji_seeker/SharedPref/SavedData.dart';
import 'package:benji_seeker/constants/Constants.dart';
import 'package:benji_seeker/constants/MyColors.dart';
import 'package:benji_seeker/constants/Urls.dart';
import 'package:benji_seeker/custom_texts/MontserratText.dart';
import 'package:benji_seeker/custom_texts/QuicksandText.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../constants/MyColors.dart';

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  var _calendarController = CalendarController();
  Map<DateTime, List> _events;
  List _selectedEvents;
  bool _monthView = false;
  var dateTime = DateTime.now();
  List<String> _months = [
    "Today",
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
  var _selectedMonth = "";

  bool _isLoading = true;
  bool _dataFetched = false;

  final Map<DateTime, List> _holidays = {
    DateTime(2019, 1, 1): ['New Year\'s Day'],
    DateTime(2019, 1, 6): ['Epiphany'],
    DateTime(2019, 2, 14): ['Valentine\'s Day'],
    DateTime(2019, 4, 21): ['Easter Sunday'],
    DateTime(2019, 4, 22): ['Easter Monday'],
  };

  @override
  void initState() {
    _selectedMonth = _months[0];
    final _selectedDay = DateTime.now();

    _events = {};

//    _getUpcomingJobs().then((upcomingJobModel) {
//      setState(() {
//        _isLoading = false;
//      });
//      if (upcomingJobModel.status) {
//        for (ItemJobModel item in upcomingJobModel.upcomingJobs) {
//          Map<DateTime, List> job = {
//            DateTime.parse(item.when): [item.jobId]
//          };
//          _events.addAll(job);
//        }
//        _dataFetched = true;
//      } else {
//        MyToast(TOAST_ERROR, context);
//        _dataFetched = false;
//      }
//    });

    _selectedEvents = _events[_selectedDay] ?? [];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
        actions: <Widget>[
          IconButton(
            icon: Icon(
              _monthView ? Icons.menu : Icons.apps,
              color: Colors.black,
            ),
            onPressed: _changeCalendarView,
          )
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(34.0),
          child: Container(
            alignment: Alignment.topLeft,
            margin: const EdgeInsets.only(left: 16.0),
            child: DropdownButtonHideUnderline(
              child: DropdownButton(
                value: _selectedMonth,
                items: _months.map((location) {
                  return DropdownMenuItem(
                    child: new MontserratText(
                        location, 16, Colors.black, FontWeight.bold),
                    value: location,
                  );
                }).toList(),
                onChanged: (String value) {
                  int selectedIndex = _months.indexOf(value);
                  _selectedMonth = value;
                  if (selectedIndex == 0) {
                    setState(() {
                      dateTime =
                          DateTime(DateTime.now().year, DateTime.now().month);
                      _calendarController.setSelectedDay(dateTime,
                          animate: true);
                    });
                  } else {
                    setState(() {
                      dateTime = DateTime(DateTime.now().year, selectedIndex);
                      _calendarController.setSelectedDay(dateTime,
                          animate: true);
                    });
                  }
                },
              ),
            ),
          ),
        ),
      ),
      body: Container(
          child: _isLoading
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : _dataFetched
                  ? TableCalendar(
                      calendarController: _calendarController,
                      events: _events,
//              holidays: _holidays,
                      startingDayOfWeek: StartingDayOfWeek.monday,
                      calendarStyle: CalendarStyle(
                          selectedColor: Colors.green[400],
                          todayColor: accentColor,
                          markersColor: orangeColor,
                          outsideDaysVisible: true,
                          markersMaxAmount: 1,
                          weekdayStyle: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              fontFamily: "Montserrat"),
                          weekendStyle: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              fontFamily: "Montserrat")),
                      headerStyle: HeaderStyle(
                        formatButtonTextStyle: TextStyle()
                            .copyWith(color: Colors.white, fontSize: 15.0),
                        formatButtonDecoration: BoxDecoration(
                          color: Colors.deepOrange[400],
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                        formatButtonVisible: false,
                        centerHeaderTitle: true,
                        rightChevronIcon: Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.transparent,
                        ),
                        leftChevronIcon: Icon(
                          Icons.arrow_back_ios,
                          color: Colors.transparent,
                        ),
                      ),
                      onDaySelected: _onDaySelected,
                      onVisibleDaysChanged: _onVisibleDaysChanged,
                    )
                  : Center(
                      child: MontserratText("Unexpected error occured!", 22,
                          Colors.black, FontWeight.normal),
                    )),
      floatingActionButton: FloatingActionButton(
        shape: RoundedRectangleBorder(
            side: BorderSide(width: 1, color: orangeColor),
            borderRadius: BorderRadius.circular(10)),
        backgroundColor: orangeColor,
        child: Icon(Icons.add),
        onPressed: () {
//          Navigator.push(context, MaterialPageRoute(builder: (context) => AddSkillsPage()));
        },
      ),
    );
  }

  void _changeCalendarView() {
    setState(() {
      _monthView = !_monthView;
    });
  }

  void _onDaySelected(DateTime day, List events) {
    print('CALLBACK: _onDaySelected');
    setState(() {
      _selectedEvents = events;
    });
  }

  void _onVisibleDaysChanged(
      DateTime first, DateTime last, CalendarFormat format) {
    print('CALLBACK: _onVisibleDaysChanged');
  }

}



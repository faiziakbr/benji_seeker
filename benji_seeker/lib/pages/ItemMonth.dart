import 'package:benji_seeker/My_Widgets/MyToast.dart';
import 'package:benji_seeker/constants/MyColors.dart';
import 'package:benji_seeker/constants/Urls.dart';
import 'package:benji_seeker/custom_texts/MontserratText.dart';
import 'package:benji_seeker/custom_texts/QuicksandText.dart';
import 'package:benji_seeker/models/CreateJobModel.dart';
import 'package:benji_seeker/models/UpcomingJobModel.dart';
import 'package:date_util/date_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';

import 'JobDetailPage/JobDetailPage.dart';
import 'MainPages/OrderSequence/OrderPage1.dart';

class ItemMonth extends StatefulWidget {
  final DateTime dateTime;
  final List<DateTime> events;
  final List<ItemJobModel> itemJobList;

  ItemMonth(this.dateTime, this.events, this.itemJobList);

  @override
  _ItemMonthState createState() => _ItemMonthState();
}

class _ItemMonthState extends State<ItemMonth> {
  int _daysInMonth = 0;
  var _selectedMonth;

  List<String> _weekdaysName = [
    "MON",
    "TUE",
    "WED",
    "THU",
    "FRI",
    "SAT",
    "SUN"
  ];

  List<DateTime> events = [];
  var dateUtil = DateUtil();

  @override
  void initState() {
    _selectedMonth = DateTime(widget.dateTime.year, widget.dateTime.month);
    events = widget.events;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    _daysInMonth =
        dateUtil.daysInMonth(_selectedMonth.month, _selectedMonth.year);
    var date = DateTime(_selectedMonth.year, _selectedMonth.month);
    int startDay = 0;
    return Container(
      color: Colors.white,
      child: Column(
        children: <Widget>[
          Align(
              alignment: Alignment.topLeft,
              child: QuicksandText(
                "${DateFormat.MMMM().format(widget.dateTime)} ${DateFormat.y().format(widget.dateTime)}",
                18,
                navBarColor,
                FontWeight.bold,
                left: 8.0,
                top: 8.0,
              )),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _weekdaysName
                .map((name) => MontserratText(
                      "$name",
                      12,
                      separatorColor,
                      FontWeight.w400,
                      top: 16.0,
                      bottom: 8.0,
                    ))
                .toList(),
          ),
          Container(
            height: 400,
            width: mediaQueryData.size.width * 1,
            child: GridView.builder(
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7, childAspectRatio: 0.85),
                itemCount: _daysInMonth + (date.weekday - 1),
                itemBuilder: (context, index) {
                  if (index < (date.weekday - 1)) {
                    return Container();
                  } else {
                    startDay++;
                    bool isToday = false;

                    var boxDay = DateTime(
                        _selectedMonth.year, _selectedMonth.month, startDay);

                    if (boxDay ==
                        DateTime(DateTime.now().year, DateTime.now().month,
                            DateTime.now().day)) {
                      isToday = true;
                    }

                    if (events.contains(boxDay)) {
                      return GestureDetector(
                        onTap: () {
                          print("EVENT CLICKED: $boxDay ");
                          widget.itemJobList.forEach((element) {
                            DateTime dateTime =
                                DateTime.parse(element.when).toLocal();
                            if (boxDay ==
                                DateTime(dateTime.year, dateTime.month,
                                    dateTime.day)) {
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) {
                                if (element.isWhenDeterminedLocally)
                                  return JobDetailPage(element.jobId,
                                      generatedRecurringTime: element.when);
                                else {
                                  return JobDetailPage(element.jobId);
                                }
                              }));
                            }
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: Colors.orange,
                                  width: 1),
                          ),
                          child: Center(
                            child: MontserratText(
                              "$startDay",
                              16,
                              Colors.orange,
                              FontWeight.normal,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      );
                    } else
                      return GestureDetector(
                        onTap: () {
                          DateTime clickedBoxDate =
                              DateTime(boxDay.year, boxDay.month, boxDay.day);
                          DateTime today = DateTime(DateTime.now().year,
                              DateTime.now().month, DateTime.now().day);

                          if (today.isBefore(clickedBoxDate) ||
                              today == clickedBoxDate) {
                            if (DateTime(boxDay.year, boxDay.month,
                                        boxDay.day + 1, 0, 0)
                                    .difference(DateTime.now())
                                    .inMinutes >
                                45) {
                              var createJobModel = CreateJobModel();
                              createJobModel.jobTime = DateTime(
                                  boxDay.year, boxDay.month, boxDay.day);
//                                        createJobModel.isJobTimeSet = true;
                              createJobModel.createFromCalendar = true;
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          OrderPage1(createJobModel)));
                            } else {
                              MyToast(
                                  "Can't set time under 45 minutes", context,
                                  position: 1);
                            }
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isToday ? accentColor : Colors.white,
                          ),
                          child: Center(
                            child: MontserratText(
                              "$startDay",
                              16,
                                isToday ? Colors.white : separatorColor,
                              FontWeight.normal,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      );
                  }
                }),
          ),
        ],
      ),
    );
  }

  Widget _jobImage(DateTime boxDay) {
    String image = "";
    for (var value in widget.itemJobList) {
      DateTime dateTime = DateTime.parse(value.when).toLocal();
      if (boxDay == DateTime(dateTime.year, dateTime.month, dateTime.day)) {
        image = "$BASE_URL_CATEGORY${value.imageUrl}";
      }
    }
    return SvgPicture.network(
      "$image",
      width: 40,
      height: 40,
      color: accentColor,
      fit: BoxFit.contain,
    );
  }
}

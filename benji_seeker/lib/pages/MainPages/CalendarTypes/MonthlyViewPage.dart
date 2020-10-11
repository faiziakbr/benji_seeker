import 'package:benji_seeker/My_Widgets/MyToast.dart';
import 'package:benji_seeker/constants/MyColors.dart';
import 'package:benji_seeker/constants/Urls.dart';
import 'package:benji_seeker/custom_texts/MontserratText.dart';
import 'package:benji_seeker/models/CreateJobModel.dart';
import 'package:benji_seeker/models/UpcomingJobModel.dart';
import 'package:benji_seeker/pages/JobDetailPage/JobDetailPage.dart';
import 'package:benji_seeker/pages/JobDetailPage/NewJobDetailPage.dart';
import 'package:benji_seeker/pages/MainPages/OrderSequence/OrderPage1.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class MonthlyViewPage extends StatefulWidget {

  final List<String> weekdaysName;
  final int daysInMonth;
  final DateTime selectedMonth;
  final List<DateTime> events;
  final List<ItemJobModel> itemJobModelList;


  MonthlyViewPage(this.weekdaysName, this.daysInMonth, this.selectedMonth,
      this.events, this.itemJobModelList);

  @override
  _MonthlyViewPageState createState() => _MonthlyViewPageState();
}

class _MonthlyViewPageState extends State<MonthlyViewPage> {
  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    var date = DateTime(widget.selectedMonth.year, widget.selectedMonth.month);
    int startDay = 0;
//    return Container();
  return _monthlyViewWidget(mediaQueryData, date, startDay);
  }

  Widget _monthlyViewWidget(
      MediaQueryData mediaQueryData, DateTime date, int startDay) {
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: widget.weekdaysName
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
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7, childAspectRatio: 0.7,crossAxisSpacing: 0.0, mainAxisSpacing: 0.0),
              itemCount: widget.daysInMonth + (date.weekday - 1),
              itemBuilder: (context, index) {
                if (index < (date.weekday - 1)) {
                  return Container(
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.black.withOpacity(0.2), width: 1)),
                  );
                } else {
                  startDay++;
                  bool isToday = false;

                  var boxDay = DateTime(
                      widget.selectedMonth.year, widget.selectedMonth.month, startDay);

                  if (boxDay ==
                      DateTime(DateTime.now().year, DateTime.now().month,
                          DateTime.now().day)) {
                    isToday = true;
                  }

                  if (widget.events.contains(boxDay)) {
                    return GestureDetector(
                      onTap: () {
                        print("EVENT CLICKED: $boxDay ");
                        widget.itemJobModelList.forEach((element) {
                          DateTime dateTime =
                          DateTime.parse(element.when).toLocal();
                          if (boxDay ==
                              DateTime(dateTime.year, dateTime.month,
                                  dateTime.day)) {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                                  if (element.isWhenDeterminedLocally)
                                    return NewJobDetailPage(element.jobId,
                                        generatedRecurringTime: element.when);
                                  else {
                                    return NewJobDetailPage(element.jobId);
                                  }
                                }));
                          }
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.black.withOpacity(0.2), width: 1),
                            color: isToday
                                ? Colors.green.withOpacity(0.6)
                                : Colors.white),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            MontserratText(
                              "$startDay",
                              16,
                              isToday ? Colors.white : separatorColor,
                              FontWeight.bold,
                              textAlign: TextAlign.center,
                            ),
                            _jobImage(boxDay)
                          ],
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

//                        print(
//                            "${DateFormat("E MMM d y HH:mm:ss", Locale(Intl.getCurrentLocale()).languageCode).format(DateTime.now())} GMT${DateTime.now().timeZoneOffset.inHours}00 ${_gmtFormatter(DateTime.now())}");
                        if (today.isBefore(clickedBoxDate) ||
                            today == clickedBoxDate) {
                          if (DateTime(boxDay.year, boxDay.month,
                              boxDay.day + 1, 0, 0)
                              .difference(DateTime.now())
                              .inMinutes >
                              45) {
                            var createJobModel = CreateJobModel();
                            createJobModel.jobTime =
                                DateTime(boxDay.year, boxDay.month, boxDay.day);
//                                        createJobModel.isJobTimeSet = true;
                            createJobModel.createFromCalendar = true;
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        OrderPage1(createJobModel)));
                          } else {
                            MyToast("Can't set time under 45 minutes", context,
                                position: 1);
                          }
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.black.withOpacity(0.2), width: 1),
                            color: isToday
                                ? Colors.green.withOpacity(0.6)
                                : Colors.white),
                        child: MontserratText(
                          "$startDay",
                          16,
                          isToday ? Colors.white : separatorColor,
                          FontWeight.bold,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                }
              }),
        ),
      ],
    );
  }

  Widget _jobImage(DateTime boxDay) {
    String image = "";
    for (var value in widget.itemJobModelList) {
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

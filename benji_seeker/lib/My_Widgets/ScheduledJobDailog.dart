import 'package:benji_seeker/constants/MyColors.dart';
import 'package:benji_seeker/constants/Urls.dart';
import 'package:benji_seeker/custom_texts/MontserratText.dart';
import 'package:benji_seeker/models/CreateJobModel.dart';
import 'package:benji_seeker/models/UpcomingJobModel.dart';
import 'package:benji_seeker/pages/JobDetailPage/NewJobDetailPage.dart';
import 'package:benji_seeker/pages/MainPages/OrderSequence/OrderPage1.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'MyToast.dart';

class ScheduledJobDialog extends StatelessWidget {
  final List<ItemJobModel> _scheduledJobs;
  final DateTime date;
  final List<ItemJobModel> itemJobList;

  ScheduledJobDialog(this._scheduledJobs, this.date, this.itemJobList);

  final DateTime today =
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

  @override
  Widget build(BuildContext context) {
    // MediaQueryData mediaQueryData = MediaQuery.of(context);
    return Wrap(
      alignment: WrapAlignment.center,
      runAlignment: WrapAlignment.center,
      children: [
        Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
          margin: const EdgeInsets.only(
              top: 16.0, bottom: 16.0, left: 8.0, right: 8.0),
          child: Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    MontserratText(
                        today.isBefore(date) || today == date
                            ? "Scheduled Services"
                            : "Completed Services",
                        18,
                        accentColor,
                        FontWeight.bold),
                    GestureDetector(
                      onTap: () {
                        Get.back();
                      },
                      child: Align(
                        alignment: Alignment.topRight,
                        child: Icon(Icons.close),
                      ),
                    ),
                  ],
                ),
                Flexible(
                  child: Container(
                    margin: const EdgeInsets.only(top: 4.0),
                    child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: _scheduledJobs.length,
                        itemBuilder: (context, index) {
                          return Container(
                            margin: const EdgeInsets.only(top: 8.0),
                            padding: const EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12.0),
                                shape: BoxShape.rectangle,
                                border: Border.all(
                                    color:
                                        _scheduledJobs[index].status == "active"
                                            ? accentColor
                                            : Colors.grey,
                                    width: 1)),
                            child: InkWell(
                                onTap: () {
                                  Get.back();
                                  // List<ItemJobModel> _recurrenceJobList =
                                  //     List();
                                  // Navigator.push(context, MaterialPageRoute(builder: (context) => JobDetailPage(itemCompletedModel.processId)));
                                  // if (_scheduledJobs[index].recurrence !=
                                  //         null &&
                                  //     _scheduledJobs[index].recurrence != 0) {
                                  //   itemJobList.forEach((element) {
                                  //     if (element.jobId ==
                                  //         _scheduledJobs[index].jobId) {
                                  //       _recurrenceJobList.add(element);
                                  //     }
                                  //   });
                                  // }
                                  Navigator.push(context,
                                      MaterialPageRoute(builder: (context) {
                                    if (_scheduledJobs[index]
                                        .isWhenDeterminedLocally)
                                      return NewJobDetailPage(
                                        _scheduledJobs[index].jobId,
                                        generatedRecurringTime:
                                            _scheduledJobs[index].when,
                                        // recurrenceJobList: _recurrenceJobList,
                                      );
                                    else {
                                      return NewJobDetailPage(
                                          _scheduledJobs[index].jobId,
                                          // recurrenceJobList:
                                          //     _recurrenceJobList
                                      );
                                    }
                                  }));
                                },
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(4.0),
                                      width: 60,
                                      height: 60,
                                      child: SvgPicture.network(
                                        "$BASE_URL_CATEGORY${_scheduledJobs[index].imageUrl}",
                                        color: accentColor,
                                        fit: BoxFit.fill,
                                      ),
                                    ),
                                    Flexible(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          MontserratText(
                                            "${_scheduledJobs[index].title}",
                                            16,
                                            Colors.black,
                                            FontWeight.bold,
                                            maxLines: 1,
                                            left: 4.0,
                                          ),
                                          MontserratText(
                                            "${DateFormat.yMMMd().add_jm().format(DateTime.parse(_scheduledJobs[index].when).toLocal())}",
                                            10,
                                            lightTextColor,
                                            FontWeight.normal,
                                            top: 4.0,
                                            left: 4.0,
                                          ),
                                          MontserratText(
                                            "${_scheduledJobs[index].package}",
                                            10,
                                            lightTextColor,
                                            FontWeight.normal,
                                            top: 4.0,
                                            left: 4.0,
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                )
                                // child: ListTile(
                                //   leading: Container(
                                //     width: 40,
                                //     height: 40,
                                //     child: SvgPicture.network(
                                //       "$BASE_URL_CATEGORY${_scheduledJobs[index].imageUrl}",
                                //       color: accentColor,
                                //       fit: BoxFit.fill,
                                //     ),
                                //   ),
                                //   title: MontserratText(
                                //     "${_scheduledJobs[index].title}",
                                //     16,
                                //     Colors.black,
                                //     FontWeight.bold,
                                //     maxLines: 1,
                                //   ),
                                //   subtitle: Column(
                                //     mainAxisSize: MainAxisSize.min,
                                //     crossAxisAlignment: CrossAxisAlignment.start,
                                //     children: [
                                //       // Container(
                                //       //     child: Text(
                                //       //   "${DateFormat.yMMMd().add_jm().format(DateTime.parse(_scheduledJobs[index].when).toLocal())}",
                                //       //   style: _textStyle(),
                                //       // ),),
                                //       MontserratText(
                                //         "${DateFormat.yMMMd().add_jm().format(DateTime.parse(_scheduledJobs[index].when).toLocal())}",
                                //         10,
                                //         lightTextColor,
                                //         FontWeight.normal,
                                //         top: 4.0,
                                //       ),
                                //       // Text(
                                //       //   "${_scheduledJobs[index].package}",
                                //       //   style: _textStyle(),
                                //       // )
                                //       MontserratText(
                                //           "${_scheduledJobs[index].package}",
                                //           10,
                                //           lightTextColor,
                                //           FontWeight.normal,
                                //           top: 4.0,
                                //         ),
                                //     ],
                                //   ),
                                // ),
                                ),
                          );
                        }),
                  ),
                ),
                SizedBox(
                  height: 16.0,
                ),
                today.isBefore(date) || today == date
                    ? RichText(
                        text: TextSpan(
                            text: "Click Here",
                            style: TextStyle(
                                color: accentColor,
                                decoration: TextDecoration.underline),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                DateTime today = DateTime(DateTime.now().year,
                                    DateTime.now().month, DateTime.now().day);

                                if (today.isBefore(date) || today == date) {
                                  if (DateTime(date.year, date.month,
                                              date.day + 1, 0, 0)
                                          .difference(DateTime.now())
                                          .inMinutes >
                                      45) {
                                    var createJobModel = CreateJobModel();
                                    createJobModel.jobTime = DateTime(
                                        date.year, date.month, date.day);
//                                        createJobModel.isJobTimeSet = true;
                                    createJobModel.createFromCalendar = true;
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                OrderPage1(createJobModel)));
                                  } else {
                                    MyToast("Can't set time under 45 minutes",
                                        context,
                                        position: 1);
                                  }
                                } else {
                                  MyToast(
                                      "Can't create job in the past.", context,
                                      position: 1);
                                }
                              },
                            children: [
                              TextSpan(
                                  text:
                                      " to add job on ${DateFormat.yMMMd().format(date)}",
                                  style: TextStyle(
                                      color: separatorColor,
                                      decoration: TextDecoration.none))
                            ]),
                      )
                    : Container(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  TextStyle _textStyle() {
    return TextStyle(
        color: separatorColor,
        fontSize: 10,
        fontWeight: FontWeight.normal,
        fontFamily: "Montserrat");
  }
}

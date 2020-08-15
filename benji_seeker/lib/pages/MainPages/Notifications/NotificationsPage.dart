import 'dart:convert';

import 'package:benji_seeker/My_Widgets/MyToast.dart';
import 'package:benji_seeker/constants/MyColors.dart';
import 'package:benji_seeker/constants/Urls.dart';
import 'package:benji_seeker/custom_texts/MontserratText.dart';
import 'package:benji_seeker/custom_texts/QuicksandText.dart';
import 'package:benji_seeker/models/JobDetailModel.dart';
import 'package:benji_seeker/models/NotificationModel.dart';
import 'package:benji_seeker/pages/JobDetailPage/JobDetailPage.dart';
import 'package:benji_seeker/utils/DioHelper.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'itemNotification.dart';

class NotificationsPage extends StatefulWidget {
  final GlobalKey key;
  final Function goToLeads;
  final Function updateNotificationCount;

  NotificationsPage(this.key, this.goToLeads, {this.updateNotificationCount});

  @override
  NotificationsPageState createState() => NotificationsPageState();
}

class NotificationsPageState extends State<NotificationsPage> {
  DioHelper _dioHelper;
  bool _isLoading = true;
  bool _isError = false;
  List<ItemNotificationModel> notifications = [];

  @override
  void initState() {
    _dioHelper = DioHelper.instance;

//    FlutterAppBadger.isAppBadgeSupported().then((value) {
//      if (value) {
//        FlutterAppBadger.removeBadge();
//        SavedData savedData = SavedData();
//        savedData.setIntValue(BADGE, 0);
//      }
//    });

    getNotifications();
//    WidgetsBinding.instance
//        .addPostFrameCallback((_) => widget.updateNotificationCount());
    super.initState();
  }

  Future<NotificationModel> getNotifications() {
    return _dioHelper.getRequest(
        BASE_URL + URL_ALL_NOTIFICATIONS, {"token": ""}).then((result) {
      NotificationModel notificationModel =
          responseFromJson(json.encode(result.data));
      if (notificationModel.status) {
        notifications = notificationModel.notifications;
      } else {
        setState(() {
          _isError = true;
        });
      }
      setState(() {
        _isLoading = false;
      });
    }).catchError((error) {
      var err = error as DioError;
      if (err.type == DioErrorType.RESPONSE) {
        var errorResponse = responseFromJson(json.encode(err.response.data));
        MyToast("${errorResponse.errors[0]}", context);
      } else
        MyToast("${err.message}", context);
      setState(() {
        _isError = true;
        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    return Scaffold(
      appBar: AppBar(
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
        centerTitle: false,
        title: QuicksandText("Notifications", 22, accentColor, FontWeight.bold),
      ),
      body: SafeArea(
        child: Container(
            child: _isLoading && !_isError
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : _isError
                    ? Center(
                        child: MontserratText("An error occured.", 16,
                            Colors.black.withOpacity(0.4), FontWeight.normal))
                    : notifications.length <= 0
                        ? Center(
                            child: Opacity(
                              opacity: 0.8,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  SvgPicture.asset(
                                      "assets/notification_icon1.svg",
                                      height: 70,
                                      width: 70),
                                  MontserratText(
                                      "There is no notification!",
                                      18,
                                      Colors.black.withOpacity(0.4),
                                      FontWeight.normal,
                                      left: 16,
                                      right: 16),
                                ],
                              ),
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: getNotifications,
                            child: ListView.builder(
                                itemCount: notifications.length,
                                itemBuilder: (context, index) {
                                  var data = notifications[index];
                                  return GestureDetector(
                                    onTap: () async {
                                      print("NOTI CLICK: ${data.url}");
                                      Uri uri = Uri.parse(data.url);
                                      if (uri.pathSegments.first == "job") {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    JobDetailPage(uri
                                                        .pathSegments.last)));
                                      }

//                        print("TYPE: ${data.url}");
//                        if (splitted.length == 4) {
//                          if (splitted[2] == "job") {
//                            var result = await Navigator.push(
//                                context,
//                                MaterialPageRoute(
//                                    builder: (context) =>
//                                        JobDetailPage(
//                                            splitted[3])));
//                            if (result == null) {
//                              getNotifications();
//                              widget.updateNotificationCount();
//                            }
//                          } else if (splitted[2] ==
//                              "job-summary") {
//                            var result = await Navigator.push(
//                                context,
//                                MaterialPageRoute(
//                                    builder: (context) =>
//                                        JobEarningPage(
//                                            "JOB EARNING",
//                                            splitted[3])));
//                            if (result == null) {
//                              getNotifications();
//                              widget.updateNotificationCount();
//                            }
//                          }
//                        } else if (data.url.contains("leads")) {
//                          widget.goToLeads();
//                        }
                                    },
                                    child: Container(
                                        color: data.seen
                                            ? Colors.transparent
                                            : Colors.green[100],
                                        child: ItemNotification(
                                            data.sender_name,
                                            data.message,
                                            data.created_at,
                                            data.image)),
                                  );
                                }),
                          )),
      ),
    );
  }

  void _readNotification() {
    _dioHelper.postRequest(BASE_URL + URL_READ_NOTIFICATION, {"token": ""},
        {"": ""}).then((value) {
      print("NOTIFICATION READ: $value");
    });
  }

  @override
  void dispose() {
//    widget.updateNotificationCount();
    _readNotification();
    super.dispose();
  }
}

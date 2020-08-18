import 'dart:convert';
import 'dart:io';

import 'package:benji_seeker/My_Widgets/bot_nav_widget.dart';
import 'package:benji_seeker/SharedPref/SavedData.dart';
import 'package:benji_seeker/constants/Constants.dart';
import 'package:benji_seeker/constants/MyColors.dart';
import 'package:benji_seeker/constants/Urls.dart';
import 'package:benji_seeker/custom_texts/MontserratText.dart';
import 'package:benji_seeker/custom_texts/QuicksandText.dart';
import 'package:benji_seeker/models/CreateJobModel.dart';
import 'package:benji_seeker/models/JustStatusModel.dart';
import 'package:benji_seeker/models/NotificationsModel.dart';
import 'package:benji_seeker/pages/MainPages/Chat/IndividualChatPage.dart';
import 'package:benji_seeker/pages/MainPages/MoreOptions/MoreOptionsPage.dart';
import 'package:benji_seeker/pages/MainPages/NewDashboadPage.dart';
import 'package:benji_seeker/utils/DioHelper.dart';
import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:overlay_support/overlay_support.dart';

import 'Chat/ChatPage.dart';
import 'JobDetailPage/JobDetailPage.dart';
import 'MainPages/Notifications/NotificationsPage.dart';
import 'MainPages/OrderSequence/OrderPage1.dart';

class BotNavPage extends StatefulWidget {
  @override
  _BotNavPageState createState() => _BotNavPageState();
}

class _BotNavPageState extends State<BotNavPage> with WidgetsBindingObserver {
  DioHelper _dioHelper;
  int _currentPage = 0;
  int _chatCount = 0;
  int _notificationCount = 0;
  CreateJobModel _createJobModel;
  GlobalKey<NotificationsPageState> _notificationChildKey = GlobalKey();
  GlobalKey<IndividualChatPageState> _chatChildKey = GlobalKey();

  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

//  {title: BENJI Update, body: made a bid on your job.}, data: {job_id: JE29706YR, type: make_bid, click_action: FLUTTER_NOTIFICATION_CLICK}}
//      {title: BENJI Update, body: withdrew the bid.}, data: {job_id: JE29706YR, type: withdraw_bid, click_action: FLUTTER_NOTIFICATION_CLICK}}
  @override
  void initState() {
    _dioHelper = DioHelper.instance;
    WidgetsBinding.instance.addObserver(this);

//    _getUnReadCount();
    _firebaseCloudMessagingListeners();

    SavedData savedData = SavedData();
    savedData.getIntValue(BADGE).then((value) {
      if (value != null && value > 0) FlutterAppBadger.updateBadgeCount(value);
    });

    super.initState();
  }

  void _firebaseCloudMessagingListeners() {
    if (Platform.isIOS) _iOSPermission();

    _firebaseMessaging.getToken().then((token) {
      print("FCM TOKEN: $token");
      _postSendDeviceToken(token);
    });

    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print('on message $message');

        if (Platform.isIOS) {
          IOSNotification iosNotification = IOSNotification.fromJson(message);

          SavedData savedData = SavedData();

          if (iosNotification.badge != -1 &&
              await FlutterAppBadger.isAppBadgeSupported()) {
            FlutterAppBadger.updateBadgeCount(iosNotification.badge);
            savedData.setIntValue(BADGE, iosNotification.badge);
          }
          showSimpleNotification(
              QuicksandText("${iosNotification.title}", 18, Colors.white,
                  FontWeight.w600),
              subtitle: MontserratText("${iosNotification.body}", 16,
                  Colors.white, FontWeight.normal),
              leading: Icon(Icons.notifications_active),
              slideDismiss: true,
              background: accentColor);

//          String type = iosNotification.type;
//          if (type.contains("withdraw_bid") || type.contains("make_bid") || type.contains("mark_as_arrived") || type.contains("start_job") || type.contains("transaction_issue") || type.contains("complete_job") || type.contains("expired_job")) {
//            while (Navigator.canPop(context)) {
//              Navigator.pop(context);
//            }
//            Navigator.pushReplacement(context,
//                MaterialPageRoute(builder: (context) => JobDetailPage(iosNotification.jobId)));
//          }
          if (iosNotification.body.contains("leads")) {
            try {
              _getUnReadCount();
              _notificationChildKey.currentState.getNotifications();
            } catch (e) {
              print("ERROR FCM new lead: $e"); //No Need to handle
            }
          }
          if (iosNotification.body.contains("received a new message")) {
            try {
              _getUnReadCount();
              _chatChildKey.currentState.getMessages();
            } catch (e) {
              print("ERROR FCM new message: $e"); //No Need to handle
            }
          }
          if (iosNotification.body.contains("accepted your bid")) {
            try {
              _getUnReadCount();
              _notificationChildKey.currentState.getNotifications();
            } catch (e) {
              print("ERROR FCM accepted bid: $e"); //No Need to handle
            }
          }
          if (iosNotification.type.contains("rescheduled_job")) {
            try {
              _getUnReadCount();
              _notificationChildKey.currentState.getNotifications();
            } catch (e) {
              print("ERROR FCM accepted bid: $e"); //No Need to handle
            }
          }
          if (iosNotification.type.contains("transaction_issue")) {
            try {
              _getUnReadCount();
              _notificationChildKey.currentState.getNotifications();
            } catch (e) {
              print("ERROR FCM accepted bid: $e"); //No Need to handle
            }
          }
        } else {
          MyNotification myNotification = MyNotification.fromJson(message);

          showSimpleNotification(
              QuicksandText("${myNotification.header.title}", 18, Colors.white,
                  FontWeight.w600),
              subtitle: MontserratText("${myNotification.header.body}", 16,
                  Colors.white, FontWeight.normal),
              leading: Icon(Icons.notifications_active),
              slideDismiss: true,
              background: accentColor);

//          String type = myNotification.payload.type;
//          if (type.contains("withdraw_bid") || type.contains("make_bid") || type.contains("mark_as_arrived") || type.contains("start_job") || type.contains("transaction_issue") || type.contains("complete_job") || type.contains("expired_job")) {
//              while (Navigator.canPop(context)) {
//                Navigator.pop(context);
//              }
//              Navigator.pushReplacement(context,
//                  MaterialPageRoute(builder: (context) => JobDetailPage(myNotification.payload.jobId)));
//          }
          if (myNotification.header.body.contains("leads")) {
            try {
              _getUnReadCount();
              _notificationChildKey.currentState.getNotifications();
            } catch (e) {
              print("ERROR FCM new lead: $e"); //No Need to handle
            }
          }
          if (myNotification.header.body.contains("received a new message")) {
            try {
              _getUnReadCount();
              _chatChildKey.currentState.getMessages();
            } catch (e) {
              print("ERROR FCM new message: $e"); //No Need to handle
            }
          }
          if (myNotification.header.body.contains("accepted your bid")) {
            try {
              _getUnReadCount();
              _notificationChildKey.currentState.getNotifications();
            } catch (e) {
              print("ERROR FCM accepted bid: $e"); //No Need to handle
            }
          }
          if (myNotification.payload.type.contains("rescheduled_job")) {
            try {
              _getUnReadCount();
              _notificationChildKey.currentState.getNotifications();
            } catch (e) {
              print("ERROR FCM accepted bid: $e"); //No Need to handle
            }
          }
          if (myNotification.payload.type.contains("transaction_issue")) {
            try {
              _getUnReadCount();
              _notificationChildKey.currentState.getNotifications();
            } catch (e) {
              print("ERROR FCM accepted bid: $e"); //No Need to handle
            }
          }
        }
      },
      onResume: (Map<String, dynamic> message) async {
        print('************** on resume $message');
        _parseNotificationData(message, true);
//        _setNotificationCount();
      },
      onLaunch: (Map<String, dynamic> message) async {
        print('************* on launch $message');
        _parseNotificationData(message, false);
      },
    );
//    }
//    _isConfigured = true;
  }

  void _parseNotificationData(Map<String, dynamic> message, bool isResuming) {
    try {
      if (Platform.isIOS) {
        IOSNotification iosNotification = IOSNotification.fromJson(message);

        SavedData savedData = SavedData();
        FlutterAppBadger.isAppBadgeSupported().then((value) {
          if (iosNotification.badge != -1 && value) {
            FlutterAppBadger.updateBadgeCount(iosNotification.badge);
            savedData.setIntValue(BADGE, iosNotification.badge);
          }
        });

        String type = iosNotification.type;
        if (type.contains("withdraw_bid") || type.contains("make_bid") || type.contains("mark_as_arrived") || type.contains("start_job") || type.contains("transaction_issue") || type.contains("complete_job") || type.contains("expired_job")) {
          while (Navigator.canPop(context)) {
            Navigator.pop(context);
          }
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => JobDetailPage(iosNotification.jobId)));
        }
        if (iosNotification.type == "accept_bid") {
          if (iosNotification.jobId != null) {
            while (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        JobDetailPage(iosNotification.jobId)));
          }
        }  else if (iosNotification.type == "new_message") {
          while (Navigator.canPop(context)) {
            Navigator.pop(context);
          }
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ChatPage(
                    iosNotification.jobId,
                    null,
                    fromJobPage: true,
                  )));
        }
      } else {
        MyNotification myNotification = MyNotification.fromJson(message);

        Payload data = myNotification.payload;
        //adding referral data in referrals
        if (data != null) {
          String type = myNotification.payload.type;
          if (type.contains("withdraw_bid") || type.contains("make_bid") || type.contains("mark_as_arrived") || type.contains("start_job") || type.contains("transaction_issue") || type.contains("complete_job") || type.contains("expired_job")) {
            while (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => JobDetailPage(myNotification.payload.jobId)));
          }

          if (data.type == "accept_bid") {
            if (data.jobId != null) {
              while (Navigator.canPop(context)) {
                Navigator.pop(context);
              }
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => JobDetailPage(data.jobId)));
            }
          } else if (data.type == "start_job") {
            if (data.jobId != null) {
              while (Navigator.canPop(context)) {
                Navigator.pop(context);
              }
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => JobDetailPage(data.jobId)));
            }
          } else if (data.type == "new_leads") {
            while (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
            setState(() {
              _currentPage = 1;
            });
          } else if (data.type == "new_message") {
            while (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ChatPage(
                      data.jobId,
                      null,
                      fromJobPage: true,
                    )));
          } else if (data.type == "transaction_issue") {
            while (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => JobDetailPage(data.jobId)));
          }
        }
      }
    } catch (e) {
      print("ERROR: $e");
    }
  }

  void _getUnReadCount() {
    _dioHelper
        .getRequest(BASE_URL + URL_UNREAD_COUNTS, {'token': ''}).then((result) {
          print("UNREAD COUNT: $result");
      Map<String, dynamic> object = json.decode(json.encode(result.data));
      var status = object['status'];
      if (status) {
        setState(() {
          _chatCount = object['response']['message_data']['unread_count'];
          _notificationCount = object['response']['notification_data']
          ['total_unread_notifications'];
        });
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      SavedData savedData = new SavedData();

      savedData.getIntValue(BADGE).then((value) {
        if (value != null && value > 0)
          FlutterAppBadger.updateBadgeCount(value);
      });

//      savedData.getValue(TOKEN).then((value) {
//        _verifyUserStatus(value);
//      });
    } else if (state == AppLifecycleState.paused) {
      SavedData savedData = new SavedData();

      savedData.getIntValue(BADGE).then((value) {
        if (value != null && value > 0)
          FlutterAppBadger.updateBadgeCount(value);
      });
    }
    super.didChangeAppLifecycleState(state);
  }

  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    return Scaffold(
      body: _showInBody(),
      bottomNavigationBar: Container(
        height: MediaQuery.of(context).size.height * 0.1,
        decoration: BoxDecoration(
            color: navBarColor,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10.0),
                topRight: Radius.circular(10.0))),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Expanded(
              flex: 1,
              child: BotNavWidget(
                "assets/task_icon.png",
                "Dashboard",
                _currentPage,
                navBarItemClickListener,
                0,
                count: 0,
              ),
            ),
            separator(mediaQueryData),
            Expanded(
              flex: 1,
              child: BotNavWidget(
                "assets/schedule_task_icon.png",
                "Order Now",
                _currentPage,
                navBarItemClickListener,
                1,
                count: 0,
              ),
            ),
            separator(mediaQueryData),
            Expanded(
              flex: 1,
              child: BotNavWidget(
                "assets/chat_icon.png",
                "Messages",
                _currentPage,
                navBarItemClickListener,
                2,
                count: 0,
              ),
            ),
            separator(mediaQueryData),
            Expanded(
              flex: 1,
              child: BotNavWidget(
                "assets/notification_icon.png",
                "Notification",
                _currentPage,
                navBarItemClickListener,
                3,
                count: 0,
              ),
            ),
            separator(mediaQueryData),
            Expanded(
              flex: 1,
              child: BotNavWidget("assets/more_icon.png", "More", _currentPage,
                  navBarItemClickListener, 4),
            ),
          ],
        ),
      ),
    );
  }

  Widget separator(MediaQueryData mediaQueryData) {
    return SizedBox(
      height: mediaQueryData.size.height * 0.05,
      width: 2.0,
      child: Container(
        color: separatorColor,
      ),
    );
  }

  void navBarItemClickListener(int index) {
    if (index == 0) {
      setState(() {
        _currentPage = 0;
      });
    } else if (index == 1) {
      setState(() {
        _currentPage = 1;
      });
    } else if (index == 2) {
      setState(() {
        _currentPage = 2;
      });
    } else if (index == 3) {
      setState(() {
        _currentPage = 3;
      });
    } else {
      setState(() {
        _currentPage = 4;
      });
    }
  }

  void positiveButton() {}

  void negativeButton(BuildContext context) {
    Navigator.pop(context);
  }

  _goToLeads() {
//    setState(() {
//      _currentPage = 1;
//    });
  }

  _updateChatCount() {
    try {
//      _getUnReadCount();
    } catch (e) {
      print("ERROR *************: $e");
    }
  }

  Widget _showInBody() {
    if (_currentPage == 0)
      return NewDashboardPage();
    else if (_currentPage == 1) {
      _createJobModel = CreateJobModel();
      return OrderPage1(_createJobModel);
    } else if (_currentPage == 2) {
      return IndividualChatPage(
        _chatChildKey,
        updateChatCount: _updateChatCount,
      );
    } else if (_currentPage == 3) {
      return NotificationsPage(_notificationChildKey, _goToLeads());
    } else {
      return MoreOptionsPage();
    }
  }

  Future<JustStatusModel> _postSendDeviceToken(String fcmToken) async {
    try {
      Dio dio = new Dio();

      SavedData savedData = new SavedData();
      String token = await savedData.getValue(TOKEN);

//      String oldFCM = await savedData.getValue(FCM_TOKEN);
//      print("OLD FCM: $oldFCM");
//      if (oldFCM != fcmToken) {
//        savedData.setValue(FCM_TOKEN, fcmToken);

      Map<String, dynamic> map = {"device_token": '$fcmToken'};
      Options options = new Options(headers: {"token": token});

      final response = await dio.post(BASE_URL + URL_DEVICE_TOKEN,
          options: options, data: json.encode(map));

      print("FCM RESPONSE: $response");
      if (response.statusCode == HttpStatus.ok) {
        return justStatusResponseFromJson(json.encode(response.data));
      } else {
        return JustStatusModel(status: false);
      }
    } on DioError catch (e) {
      print("FCM RESPONSE: ${e.response}");

      if (e.response != null) {
        return justStatusResponseFromJson(json.encode(e.response.data));
      } else {
        return JustStatusModel(status: false);
      }
    }
  }

  void _iOSPermission() {
    _firebaseMessaging.requestNotificationPermissions(
        IosNotificationSettings(sound: true, badge: true, alert: true));
    _firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {
      print("Settings registered: $settings");
    });
  }
}

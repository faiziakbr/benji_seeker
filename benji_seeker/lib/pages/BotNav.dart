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
import 'package:benji_seeker/models/UnreadCountModel.dart';
import 'package:benji_seeker/pages/MainPages/Chat/IndividualChatPage.dart';
import 'package:benji_seeker/pages/MainPages/MoreOptions/MoreOptionsPage.dart';
import 'package:benji_seeker/pages/MainPages/NewDashboadPage.dart';
import 'package:benji_seeker/utils/DioHelper.dart';
import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:uni_links/uni_links.dart';

import 'Chat/ChatPage.dart';
import 'JobDetailPage/JobDetailPage.dart';
import 'MainPages/Notifications/NotificationsPage.dart';
import 'MainPages/OrderSequence/OrderPage1.dart';

class BotNavPage extends StatefulWidget {
  bool fromNotifications;

  BotNavPage({this.fromNotifications = false});

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
  GlobalKey<NewDashboardPageState> _newDashboardKey = GlobalKey();

  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

//  {title: BENJI Update, body: made a bid on your job.}, data: {job_id: JE29706YR, type: make_bid, click_action: FLUTTER_NOTIFICATION_CLICK}}
//      {title: BENJI Update, body: withdrew the bid.}, data: {job_id: JE29706YR, type: withdraw_bid, click_action: FLUTTER_NOTIFICATION_CLICK}}
  @override
  void initState() {
    _dioHelper = DioHelper.instance;
    WidgetsBinding.instance.addObserver(this);

    if (widget.fromNotifications) {
      setState(() {
        _currentPage = 3;
      });
    }

    _getUnReadCount();
    _firebaseCloudMessagingListeners();
    _initUniLinks();

    SavedData savedData = SavedData();
    savedData.getIntValue(BADGE).then((value) {
      if (value != null && value > 0) FlutterAppBadger.updateBadgeCount(value);
    });

    super.initState();
  }

  Future<Null> _initUniLinks() async {
    try {
      String initialLink = await getInitialLink();
      if (initialLink != null) _openURLfromColdStart(initialLink);

      getLinksStream().listen((event) {
        if (event != null) _openURLNormally(event);
      });
    } on PlatformException catch (e) {
      print("DEEP LINKING ERROR: $e");
    }
  }

  void _openURLfromColdStart(String url) {
    if (url.contains("https://development.benjilawn.com")) {
      if (url.contains("dashboard")) {
        try {
          while (Navigator.canPop(context)) {
            Navigator.pop(context);
          }
          setState(() {
            _currentPage = 0;
          });
        } catch (e) {
          print("ERROR all jobs: $e"); //No Need to handle
        }
      } else if (url.contains("job")) {
        Uri uri = Uri.parse(url);
        while (Navigator.canPop(context)) {
          Navigator.pop(context);
        }
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => JobDetailPage(uri.pathSegments.last)));
      }
    }
  }

  void _openURLNormally(String url) {
    if (url.contains("https://development.benjilawn.com")) {
      if (url.contains("dashboard")) {
        try {
          _getUnReadCount();
          while (Navigator.canPop(context)) {
            Navigator.pop(context);
          }
          setState(() {
            _currentPage = 0;
          });
        } catch (e) {
          print("ERROR all jobs: $e"); //No Need to handle
        }
      } else if (url.contains("job")) {
        Uri uri = Uri.parse(url);
        while (Navigator.canPop(context)) {
          Navigator.pop(context);
        }
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => JobDetailPage(uri.pathSegments.last)));
      }
    }
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

          String type = iosNotification.type;
          if (type.contains("withdraw_bid") ||
              type.contains("make_bid") ||
              type.contains("mark_as_arrived") ||
              type.contains("start_job") ||
              type.contains("transaction_issue") ||
              type.contains("complete_job") ||
              type.contains("expired_job")) {
            try {
              _getUnReadCount();
              _notificationChildKey.currentState.getNotifications();
              _newDashboardKey.currentState.fetchUpcomingJobs();
            } catch (e) {
              print("Error FCM $e");
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

          String type = myNotification.payload.type;
          if (type.contains("withdraw_bid") ||
              type.contains("make_bid") ||
              type.contains("mark_as_arrived") ||
              type.contains("start_job") ||
              type.contains("transaction_issue") ||
              type.contains("complete_job") ||
              type.contains("expired_job")) {
            try {
              _getUnReadCount();
              _notificationChildKey.currentState.getNotifications();
              _newDashboardKey.currentState.fetchUpcomingJobs();
            } catch (e) {
              print("Error FCM $e");
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
        if (type.contains("withdraw_bid") ||
            type.contains("make_bid") ||
            type.contains("mark_as_arrived") ||
            type.contains("start_job") ||
            type.contains("transaction_issue") ||
            type.contains("complete_job") ||
            type.contains("expired_job")) {
          while (Navigator.canPop(context)) {
            Navigator.pop(context);
          }
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => JobDetailPage(iosNotification.jobId)));
        }
        if (iosNotification.type == "new_message") {
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
        } else if (iosNotification.type == "transaction_issue") {
          while (Navigator.canPop(context)) {
            Navigator.pop(context);
          }
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => JobDetailPage(iosNotification.jobId)));
        }
      } else {
        MyNotification myNotification = MyNotification.fromJson(message);

        Payload data = myNotification.payload;
        //adding referral data in referrals
        if (data != null) {
          String type = myNotification.payload.type;
          if (type.contains("withdraw_bid") ||
              type.contains("make_bid") ||
              type.contains("mark_as_arrived") ||
              type.contains("start_job") ||
              type.contains("transaction_issue") ||
              type.contains("complete_job") ||
              type.contains("expired_job")) {
            while (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        JobDetailPage(myNotification.payload.jobId)));
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
      UnreadCountModel unreadCountModel =
          unreadCountModelResponseFromJson(json.encode(result.data));
      if (unreadCountModel.status) {
        if (mounted) {
          setState(() {
            _chatCount = unreadCountModel.unreadMessages;
            _notificationCount = unreadCountModel.unreadNotifications;
          });
        }
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
                "Task Calendar",
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
                count: _chatCount,
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
                count: _notificationCount,
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

  _goToLeads() {
//    setState(() {
//      _currentPage = 1;
//    });
  }

  _updateChatCount() {
    try {
      _getUnReadCount();
    } catch (e) {
      print("ERROR *************: $e");
    }
  }

  _updateNotificationCount() {
    try {
      _getUnReadCount();
      _notificationChildKey.currentState.getNotifications();
    } catch (e) {
      print("ERROR *************: $e");
    }
  }

  Widget _showInBody() {
    if (_currentPage == 0)
      return NewDashboardPage(_newDashboardKey);
    else if (_currentPage == 1) {
      _createJobModel = CreateJobModel();
      return OrderPage1(_createJobModel);
    } else if (_currentPage == 2) {
      return IndividualChatPage(
        _chatChildKey,
        updateChatCount: _updateChatCount,
      );
    } else if (_currentPage == 3) {
      return NotificationsPage(
        _notificationChildKey,
        updateNotificationCount: _updateNotificationCount,
      );
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

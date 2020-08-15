import 'package:benji_seeker/My_Widgets/bot_nav_widget.dart';
import 'package:benji_seeker/constants/MyColors.dart';
import 'package:benji_seeker/models/CreateJobModel.dart';
import 'package:benji_seeker/pages/MainPages/Chat/IndividualChatPage.dart';
import 'package:benji_seeker/pages/MainPages/MoreOptions/MoreOptionsPage.dart';
import 'package:benji_seeker/pages/MainPages/NewDashboadPage.dart';
import 'package:flutter/material.dart';

import 'MainPages/Notifications/NotificationsPage.dart';
import 'MainPages/OrderSequence/OrderPage1.dart';

class BotNavPage extends StatefulWidget {
  @override
  _BotNavPageState createState() => _BotNavPageState();
}

class _BotNavPageState extends State<BotNavPage> {
  int _currentPage = 0;
  CreateJobModel _createJobModel;
  GlobalKey<NotificationsPageState> _notificationChildKey = GlobalKey();
  GlobalKey<IndividualChatPageState> _chatChildKey = GlobalKey();

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
                count: 1,
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
//      Navigator.push(context, MaterialPageRoute(builder: (context) => BrowserServiceProviders()));
//      Navigator.push(context, MaterialPageRoute(builder: (context) => SummaryPage()));
//      Navigator.push(context, MaterialPageRoute(builder: (context) => SignUpPage()));
//      Navigator.push(context, MaterialPageRoute(builder: (context) => PhoneNumberPage()));
//      Navigator.push(context, MaterialPageRoute(builder: (context) => TaskHistoryPage()));
//      Navigator.push(context, MaterialPageRoute(builder: (context) => MoreOptionsPage()));
//      Navigator.push(context, MaterialPageRoute(builder: (context) => NotificationsPage()));
//      Navigator.push(context, MaterialPageRoute(builder: (context) => GetHelpPage()));
//      Navigator.push(context, MaterialPageRoute(builder: (context) => MenuPage()));
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
    setState(() {
      _currentPage = 1;
    });
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
      return IndividualChatPage(_chatChildKey, updateChatCount: _updateChatCount,);
    } else if (_currentPage == 3) {
      return NotificationsPage(_notificationChildKey, _goToLeads());
    } else {
      return MoreOptionsPage();
    }
  }
}

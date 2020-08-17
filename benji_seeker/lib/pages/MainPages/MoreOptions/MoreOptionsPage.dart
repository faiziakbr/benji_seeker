import 'package:benji_seeker/SharedPref/SavedData.dart';
import 'package:benji_seeker/constants/Constants.dart';
import 'package:benji_seeker/constants/MyColors.dart';
import 'package:benji_seeker/constants/Urls.dart';
import 'package:benji_seeker/custom_texts/MontserratText.dart';
import 'package:benji_seeker/custom_texts/QuicksandText.dart';
import 'package:benji_seeker/pages/EditProfile/EditProfilePage.dart';
import 'package:benji_seeker/pages/GetHelp/GetHelpPage.dart';
import 'package:benji_seeker/pages/GettingStarted/PhoneNumberPage.dart';
import 'package:benji_seeker/pages/TaskHistory/WorkHistoryPage.dart';
import 'package:benji_seeker/pages/bank/EditBankPage.dart';
import 'package:benji_seeker/pages/invite/InvitePage.dart';
import 'package:flutter/material.dart';

import '../../FeedbackPage.dart';
import 'itemMoreOptions.dart';

class MoreOptionsPage extends StatefulWidget {
  @override
  _MoreOptionsPageState createState() => _MoreOptionsPageState();
}

class _MoreOptionsPageState extends State<MoreOptionsPage> {
  String _name;
  String _phone;
  String _image;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getSavedUserData();
    });

    super.initState();
  }

  void _getSavedUserData() async {
    SavedData savedData = SavedData();

    savedData.getValue(FIRST_NAME).then((name) {
//      setState(() {
      _name = name;
//      });
    }).whenComplete(() {
      savedData.getValue(LAST_NAME).then((value) {
        _name += " " + value;
      });
    });
    savedData.getValue(PHONE).then((phone) {
      setState(() {
        _phone = phone;
      });
    });

    savedData.getValue(IMAGE_URL).then((image) {
      setState(() {
        _image = BASE_PROFILE_URL + image;
//      _image = "";
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
        title: QuicksandText("More Options", 22, accentColor, FontWeight.bold),
//        actions: <Widget>[
//          IconButton(
//            icon: Icon(
//              Icons.settings,
//              color: Colors.black,
//            ),
//            onPressed: () {},
//          )
//        ],
      ),
      body: Container(
        margin: EdgeInsets.only(
            top: 16.0,
            left: mediaQueryData.size.width * 0.05,
            right: mediaQueryData.size.width * 0.05),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              GestureDetector(
                onTap: goToEditPage,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Expanded(
                        child: Row(
                          children: <Widget>[
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: FadeInImage(
                                fit: BoxFit.cover,
                                width: 70,
                                height: 70,
                                placeholder:
                                    AssetImage("assets/placeholder.png"),
                                image: NetworkImage("$_image"),
                              ),
//                            child: Image.network(
//                              "$BASE_IMAGE_URL$_image",
//                              width: 70,
//                              height: 70,
//                              fit: BoxFit.cover,
//                            ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Container(
                                  child: Text(
                                    "$_name",
                                    maxLines: 1,
                                    style: labelTextStyle(
                                        textSize: 22,
                                        fontWeight: FontWeight.bold),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  width: mediaQueryData.size.width * 0.5,
                                  margin: const EdgeInsets.only(
                                      left: 8.0, right: 8.0, bottom: 8.0),
                                ),
                                Container(
                                  margin: const EdgeInsets.only(left: 8.0),
                                  child: Row(
                                    children: <Widget>[
                                      Image.asset(
                                        "assets/phone_icon.png",
                                        width: 12,
                                        height: 12,
                                      ),
                                      MontserratText(
                                        "$_phone",
                                        14,
                                        lightTextColor,
                                        FontWeight.normal,
                                        left: 8.0,
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                      MontserratText(
                        "Edit",
                        16,
                        orangeColor,
                        FontWeight.bold,
                        underline: true,
                      )
                    ],
                  ),
                ),
              ),
              ItemMoreOptions(
                "assets/task_history.png",
                "Task History",
                _goToWorkHistory,
              ),
              ItemMoreOptions("assets/payment_method.png", "Payment Options",
                  _goToBankDetails),
              ItemMoreOptions(
                  "assets/get_help.png", "Get Help", goToGetHelpPage),
//              ItemMoreOptions(
//                  "assets/saved_addresses.png", "My Rating", goToMyRatingPage),
              ItemMoreOptions("assets/invite_friends.png", "Invite friends",
                  _goToInvitePage),
              ItemMoreOptions(
                  "assets/feedback.png", "Give us feedback", _goToFeedbackPage),
//              ItemMoreOptions("assets/settings.png", "Skills", goToSkillsPage),
//              ItemMoreOptions("assets/offers_and_promotions.png",
//                  "Offers and Promotions", goToOffersAndPromotionsPage),
//              ItemMoreOptions(
//                "assets/bank.png",
//                "Bank Details",
//                goToBankDetails,
//              ),

              ItemMoreOptions(null, "LOGOUT", _logout),
              Container(
                height: 16.0,
              )
            ],
          ),
        ),
      ),
    );
  }

  TextStyle labelTextStyle(
      {FontWeight fontWeight = FontWeight.normal,
      double textSize = 14,
      double,
      letterSpacing = 0.0}) {
    return TextStyle(
        color: lightTextColor,
        fontSize: textSize,
        fontWeight: fontWeight,
        letterSpacing: letterSpacing,
        fontFamily: "Quicksand");
  }

  void goToEditPage() async {
    var profileUpdated = await Navigator.push(
        context, MaterialPageRoute(builder: (context) => EditProfilePage()));
    if (profileUpdated != null && profileUpdated) _getSavedUserData();
  }

  void _goToWorkHistory() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => WorkHistoryPage()));
  }

  void _goToBankDetails() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => EditBankDetails()));
  }

  void goToGetHelpPage() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => GetHelpPage()));
  }

  void goToMyRatingPage() {
//    Navigator.push(
//        context, MaterialPageRoute(builder: (context) => MyRatingPage()));
  }

  void goToMyEarningsPage() {
//    Navigator.push(
//        context, MaterialPageRoute(builder: (context) => MyEarningsPage()));
  }

  void goToSkillsPage() {
//    Navigator.push(
//        context, MaterialPageRoute(builder: (context) => MainSkillsPage()));
  }

//  void goToOffersAndPromotionsPage() {
//    Navigator.push(context,
//        MaterialPageRoute(builder: (context) => OffersAndPromotionPage()));
//  }

  void _goToInvitePage() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => InvitePage()));
  }

  void _goToFeedbackPage() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => FeedbackPage()));
  }

  void _logout() async {
    SavedData savedData = SavedData();
    await savedData.logOut();
    await savedData.setBoolValue(SHOW_INTRO, false);
    while (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => PhoneNumberPage()));
  }
}

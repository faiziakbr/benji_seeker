import 'dart:async';
import 'dart:convert';

import 'package:benji_seeker/My_Widgets/MyLoadingDialog.dart';
import 'package:benji_seeker/My_Widgets/MyToast.dart';
import 'package:benji_seeker/SharedPref/SavedData.dart';
import 'package:benji_seeker/constants/Constants.dart';
import 'package:benji_seeker/constants/Urls.dart';
import 'package:benji_seeker/models/LoginModel.dart';
import 'package:benji_seeker/models/UserModel.dart';
import 'package:benji_seeker/models/VerifyTokenModel.dart';
import 'package:benji_seeker/pages/AuthPages/ForgotPasswordPage.dart';
import 'package:benji_seeker/pages/BotNav.dart';
import 'package:benji_seeker/pages/MainPages/DashboardPage.dart';
import 'package:benji_seeker/utils/DioHelper.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../constants/MyColors.dart';
import '../../custom_texts/MontserratText.dart';
import 'PhoneNumberPage.dart';

class PasswordPage extends StatefulWidget {
  final String phoneNumber;

  PasswordPage(this.phoneNumber);

  @override
  _PasswordPageState createState() => _PasswordPageState();
}

class _PasswordPageState extends State<PasswordPage> {
  DioHelper _dioHelper;
  TextEditingController _controller = TextEditingController();
  SavedData _savedData;

  @override
  void initState() {
    _dioHelper = DioHelper.instance;
    _savedData = SavedData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          color: Colors.black,
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        margin: EdgeInsets.only(
            top: 8.0,
            left: mediaQueryData.size.width * 0.05,
            right: mediaQueryData.size.width * 0.05),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              MontserratText(
                "Welcome back, sign in to continue",
                16,
                Colors.black,
                FontWeight.bold,
                top: 8.0,
                bottom: 16.0,
              ),
              Row(
                children: <Widget>[
                  Expanded(
                    flex: 12,
                    child: TextField(
                      controller: _controller,
                      cursorColor: accentColor,
                      obscureText: true,
                      style: labelTextStyle(
                          fontWeight: FontWeight.w600, textSize: 20),
                      decoration: InputDecoration(
                          labelText: "Enter your password",
                          labelStyle: labelTextStyle(),
                          contentPadding: const EdgeInsets.only(top: -8.0)),
                    ),
                  ),
                  Flexible(
                    flex: 2,
                    child: GestureDetector(
                      onTap: _processLogin,
                      child: CircleAvatar(
                        backgroundColor: accentColor,
                        child: Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.white,
                          size: 15,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ForgotPasswordPage()));
                },
                child: MontserratText(
                  "I forgot my password",
                  16,
                  accentColor,
                  FontWeight.bold,
                  top: 16.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  TextStyle labelTextStyle(
      {FontWeight fontWeight = FontWeight.normal, double textSize = 14}) {
    return TextStyle(
        color: lightTextColor,
        fontSize: textSize,
        fontWeight: fontWeight,
        fontFamily: "Montserrat");
  }

  void _processLogin() {

    if (_controller.text.isNotEmpty) {
      MyLoadingDialog(context, "Logging in...");
      Map<String, dynamic> map = {
        'phone': '${widget.phoneNumber}',
        "password": "${_controller.text.trim()}"
      };

      _dioHelper.postRequest(BASE_URL + URL_LOGIN, null, map).then((result) {
        print("LOGIN DATA: ${result.data}");
        LoginModel responseData = loginModelResponseFromJson(json.encode(result.data));

        if (responseData.status) {
          SavedData savedData = new SavedData();
          savedData.setValue(TOKEN, responseData.token);
          _dioHelper.getRequest(BASE_URL + URL_USER_BASIC_INFO, {"token": ""}).then(
              (result) {
            print("USER INFO ${result.data} statusCode: ${result.statusCode}");
            UserModel userInfoModel =
                userModelResponseFromJson(json.encode(result.data));
            savedData.setValue(FIRST_NAME, userInfoModel.firstName);
            savedData.setValue(LAST_NAME, userInfoModel.lastName);
            savedData.setValue(EMAIL, userInfoModel.email);
            savedData.setValue(PHONE, userInfoModel.phone);
            savedData.setValue(IMAGE_URL, userInfoModel.profilePicture);

            _verifyToken(responseData.token);
          }).catchError((error) {
            Navigator.pop(context);
            var err = error as DioError;
            if (err.type == DioErrorType.RESPONSE) {
              var errorResponse =
                  userModelResponseFromJson(json.encode(err.response.data));
              MyToast("${errorResponse.errors[0]}", context);
            } else
              MyToast("${err.message}", context);
          });
        } else {
          Navigator.pop(context);
          MyToast("${responseData.errors[0]}", context);
        }
      }).catchError((error) {
        try {
          Navigator.pop(context);
          var err = error as DioError;
          if (err.type == DioErrorType.RESPONSE) {
            var errorResponse = loginModelResponseFromJson(
                json.encode(err.response.data));
            MyToast("${errorResponse.errors[0]}", context);
          } else
            MyToast("${err.message}", context);
        }catch (e) {
          Navigator.pop(context);
          MyToast("Unexpected error!", context);
        }
      });

    } else {
      Navigator.pop(context);
      MyToast("Please enter password.", context);
    }
  }

  void _verifyToken(String token) {
    Map<String, dynamic> map = {
      'token': '$token',
    };

    _dioHelper
        .postRequest(BASE_URL + URL_VERIFY_TOKEN, null, map)
        .then((result) {
      var verifyToken = verifyTokenResponseFromJson(json.encode(result.data));
      if (verifyToken.status) {
        if (verifyToken.verifyTokenUserModel.role == "seeker") {
          var userStatus = verifyToken.verifyTokenUserModel.status;
          if (userStatus == "active" ||
              userStatus == "inactive" ||
              userStatus == "blocked") {
            print("VERIFY TOKEN RESPONSE: ${result.data}");
            bool isProfileActive = false;
            bool isAccountBlocked = false;
            if (userStatus == "active")
              isProfileActive = true;
            else if (userStatus == "inactive")
              isProfileActive = false;
            else {
              isProfileActive = false;
              isAccountBlocked = true;
            }

            while (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => BotNavPage()));
          }
//          else {
//            MyToast("You are blocked by admin", context);
//
//            Timer(const Duration(seconds: 2), () {
//              SavedData savedData = SavedData();
//              savedData.logOut();
//              savedData.setBoolValue(SHOW_INTRO, false);
//              Navigator.pushReplacement(context,
//                  MaterialPageRoute(builder: (context) => PhoneNumberPage()));
//            });
//          }
        } else {
          MyToast("This app is for seekers only.", context);
          SavedData savedData = new SavedData();
          savedData.logOut();
          Timer(const Duration(seconds: 1), () {
            Navigator.pop(context);
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => PhoneNumberPage()));
          });
        }
      } else {
        Navigator.pop(context);
        MyToast("Unexpected error, check your internet connection", context);
      }
    }).catchError((error) {
      try {
        Navigator.pop(context);
        var err = error as DioError;
        if (err.type == DioErrorType.RESPONSE) {
          var errorResponse = verifyTokenResponseFromJson(
              json.encode(err.response.data));
          MyToast("${errorResponse.errors[0]}", context);
        } else
          MyToast("${err.message}", context);
      }catch (e){
        MyToast("Unexpected Error!", context);
      }
    });
  }
}

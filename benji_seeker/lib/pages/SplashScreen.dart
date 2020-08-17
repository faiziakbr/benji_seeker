import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:benji_seeker/My_Widgets/MyToast.dart';
import 'package:benji_seeker/SharedPref/SavedData.dart';
import 'package:benji_seeker/constants/Constants.dart';
import 'package:benji_seeker/constants/Urls.dart';
import 'package:benji_seeker/models/UserModel.dart';
import 'package:benji_seeker/models/VerifyTokenModel.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../constants/MyColors.dart';
import '../custom_texts/QuicksandText.dart';
import 'BotNav.dart';
import 'GettingStarted/PhoneNumberPage.dart';
import 'Intro/IntroPage.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

//TODO this splash is temporary
class _SplashScreenState extends State<SplashScreen> {
  SavedData savedData;

  @override
  void initState() {
    savedData = SavedData();
    Timer(const Duration(milliseconds: 2500), () {
      _isUserAlreadyLoggedIn();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    return Image.asset(
      "assets/splash_screen.gif",
      width: mediaQueryData.size.width,
      height: mediaQueryData.size.height,
      fit: BoxFit.cover,
    );
  }

//  void _isUserAlreadyLoggedIn() {
//    savedData.getValue(TOKEN).then((token) {
//      print("TOKEN: $token");
//      if (token == null || token.isEmpty) {
//        Navigator.pushReplacement(context,
//            MaterialPageRoute(builder: (context) => PhoneNumberPage()));
//        return;
//      }
//      _postVerifyToken(token).then((verifyToken) {
//        if (verifyToken.status) {
//          while (Navigator.canPop(context)) {
//            Navigator.pop(context);
//          }
//          Navigator.pushReplacement(
//              context, MaterialPageRoute(builder: (context) => BotNavPage()));
//        } else {
////          Navigator.pop(context);
//          Navigator.pushReplacement(context,
//              MaterialPageRoute(builder: (context) => PhoneNumberPage()));
////          MyToast("Unexpected error, check your internet connection", context);
//        }
//      });
////      if (token != null && token != "")
////        Navigator.pushReplacement(
////            context, MaterialPageRoute(builder: (context) => BotNavPage()));
////      else
////        Navigator.pushReplacement(context,
////            MaterialPageRoute(builder: (context) => PhoneNumberPage()));
//    });
//  }

  void _isUserAlreadyLoggedIn() async {
    SavedData savedData = SavedData();
    savedData.getBoolValue(SHOW_INTRO).then((value) {
      print("SAVED DATA VALUE NULL $value");
      if (value == null) {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => IntroPage()));
        return;
      }
    });
    savedData.getValue(TOKEN).then((token) {
      if (token == null || token.isEmpty) {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => PhoneNumberPage()));
        return;
      }
      _postVerifyToken(token).then((verifyToken) {
        try {
          if (verifyToken.status) {
            if (verifyToken.verifyTokenUserModel.role == "seeker") {
              var userStatus = verifyToken.verifyTokenUserModel.status;
              print("STATUS: $userStatus");
              if (userStatus == "active" ||
                  userStatus == "inactive" ||
                  userStatus == "blocked") {

                  _getBasicInfoResponse().then((userInfo) {
                    if (userInfo.status) {
                      SavedData savedData = SavedData();
                      savedData.setValue(FIRST_NAME, userInfo.firstName);
                      savedData.setValue(LAST_NAME, userInfo.lastName);
                      savedData.setValue(EMAIL, userInfo.email);
                      savedData.setValue(PHONE, userInfo.phone);
                      savedData.setValue(IMAGE_URL, userInfo.profilePicture);

                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => PhoneNumberPage()));
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => BotNavPage(
                              )));
                    }
                  });
              }
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
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => PhoneNumberPage()));
          }
        } catch (e) {
          exit(0);
        }
      });
    });
  }

  Future<VerifyTokenModel> _postVerifyToken(String token) async {
    try {
      BaseOptions baseOptions = new BaseOptions(
        connectTimeout: 15000,
        receiveTimeout: 15000,
      );

      Dio dio = new Dio(baseOptions);

      Map<String, dynamic> map = {
        'token': '$token',
      };
      var body = json.encode(map);

      Options options =
          new Options(headers: {'content-type': 'application/json'});

      final response = await dio.post(BASE_URL + URL_VERIFY_TOKEN,
          options: options, data: body);

      print("RESPONSE: ${response.data}");

      if (response.statusCode == HttpStatus.ok)
        return verifyTokenResponseFromJson(json.encode(response.data));
      else
        return VerifyTokenModel(status: false);
    } on DioError catch (e) {
      if (e.response != null)
        return verifyTokenResponseFromJson(json.encode(e.response.data));
      else
        return VerifyTokenModel(status: false);
    }
  }

  Future<UserModel> _getBasicInfoResponse() async {
    try {
      BaseOptions baseOptions = new BaseOptions(
        connectTimeout: 15000,
        receiveTimeout: 15000,
      );
      Dio dio = new Dio(baseOptions);
      SavedData savedData = new SavedData();
      String token = await savedData.getValue(TOKEN);

      Options options = new Options(headers: {"token": token});

      final response =
      await dio.get(BASE_URL + URL_USER_BASIC_INFO, options: options);

      print("USER BASIC INFO RESPONSE: ${response.data}");
      if (response.statusCode == HttpStatus.ok)
        return userModelResponseFromJson(json.encode(response.data));
      else
        return UserModel(status: false);
    } on DioError catch (e) {
      if (e.response != null) {
        return userModelResponseFromJson(json.encode(e.response.data));
      } else {
        return UserModel(status: false);
      }
    }
  }
}

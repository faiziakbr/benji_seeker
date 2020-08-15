import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:benji_seeker/My_Widgets/MyToast.dart';
import 'package:benji_seeker/SharedPref/SavedData.dart';
import 'package:benji_seeker/constants/Constants.dart';
import 'package:benji_seeker/constants/Urls.dart';
import 'package:benji_seeker/models/VerifyTokenModel.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../constants/MyColors.dart';
import '../custom_texts/QuicksandText.dart';
import 'BotNav.dart';
import 'GettingStarted/PhoneNumberPage.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

//TODO this splash is temporary
class _SplashScreenState extends State<SplashScreen> {
  Timer _timer;

  SavedData savedData = SavedData();

  _SplashScreenState() {
    _timer = new Timer(const Duration(milliseconds: 1000), () {
      _isUserAlreadyLoggedIn();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: accentColor,
      body: SafeArea(
        child: Center(
          child: QuicksandText("benji", 56, Colors.white, FontWeight.bold),
        ),
      ),
    );
  }

  void _isUserAlreadyLoggedIn() {
    savedData.getValue(TOKEN).then((token) {
      print("TOKEN: $token");
      if (token == null || token.isEmpty) {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => PhoneNumberPage()));
        return;
      }
      _postVerifyToken(token).then((verifyToken) {
        if (verifyToken.status) {
          while (Navigator.canPop(context)) {
            Navigator.pop(context);
          }
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => BotNavPage()));
        } else {
//          Navigator.pop(context);
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => PhoneNumberPage()));
//          MyToast("Unexpected error, check your internet connection", context);
        }
      });
//      if (token != null && token != "")
//        Navigator.pushReplacement(
//            context, MaterialPageRoute(builder: (context) => BotNavPage()));
//      else
//        Navigator.pushReplacement(context,
//            MaterialPageRoute(builder: (context) => PhoneNumberPage()));
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
}

import 'dart:convert';
import 'dart:io';

import 'package:benji_seeker/My_Widgets/MyDarkButton.dart';
import 'package:benji_seeker/My_Widgets/MyToast.dart';
import 'package:benji_seeker/constants/MyColors.dart';
import 'package:benji_seeker/constants/Urls.dart';
import 'package:benji_seeker/custom_texts/QuicksandText.dart';
import 'package:benji_seeker/models/PhoneNumberModel.dart';
import 'package:benji_seeker/pages/GettingStarted/PasswordPage.dart';
import 'package:benji_seeker/pages/GettingStarted/VerifyPINPage.dart';
import 'package:benji_seeker/utils/DioHelper.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class PhoneNumberPage extends StatefulWidget {
  @override
  _PhoneNumberPageState createState() => _PhoneNumberPageState();
}

class _PhoneNumberPageState extends State<PhoneNumberPage> {
  DioHelper _dioHelper;
  bool _isClicked = false;
  TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    _dioHelper = DioHelper.instance;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
//        leading: IconButton(
//          color: Colors.black,
//          icon: Icon(Icons.arrow_back),
//          onPressed: () {
//            Navigator.pop(context);
//          },
//        ),
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
              Image.asset(
                "assets/phoneNumber.png",
                width: mediaQueryData.size.width * 0.9,
                height: mediaQueryData.size.height * 0.4,
                fit: BoxFit.contain,
              ),
              QuicksandText(
                "Get things done with benji",
                22,
                Colors.black,
                FontWeight.bold,
                top: 8.0,
              ),
              SizedBox(
                height: mediaQueryData.size.height * 0.035,
              ),
              TextField(
                controller: _controller,
                cursorColor: accentColor,
                keyboardType: TextInputType.phone,
                style:
                    labelTextStyle(fontWeight: FontWeight.w500, textSize: 20),
                decoration: InputDecoration(
                    labelText: "Enter your phone number",
                    labelStyle: labelTextStyle(letterSpacing: 0.06),
                    contentPadding: const EdgeInsets.only(top: -8.0),
                    prefixText: "+1",
                    prefixStyle: labelTextStyle(
                        fontWeight: FontWeight.w500, textSize: 20)),
              ),
              !_isClicked
                  ? Container(
                      height: 50.0,
                      width: mediaQueryData.size.width,
                      margin: const EdgeInsets.only(top: 32.0, bottom: 16.0),
                      child: MyDarkButton("CONTINUE", _btnContinueClick),
                    )
                  : Container(
                      alignment: Alignment.center,
                      margin: const EdgeInsets.only(top: 32.0, bottom: 16.0),
                      child: CircularProgressIndicator(),
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
      double letterSpacing = 0.0}) {
    return TextStyle(
        color: lightTextColor,
        fontSize: textSize,
        letterSpacing: letterSpacing,
        fontWeight: fontWeight,
        fontFamily: "Montserrat");
  }

  void _btnContinueClick() {
    String phoneNumber = "+1"+_controller.text.toString().trim();
    FocusScope.of(context).requestFocus(FocusNode());
    if (phoneNumber.isNotEmpty) {
      setState(() {
        _isClicked = !_isClicked;
      });

      print("PH: $phoneNumber");

      _dioHelper.postRequest(BASE_URL + URL_PHONENUMBER_CHECK, null,
          {"phone": phoneNumber}).then((value) {
            print("RESPONSE: ${value.data}");
        PhoneNumberModel responseData = phoneNumberResponseFromJson(json.encode(value.data));
        if (responseData.action.toLowerCase() == "signup") {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      VerifyPINPage(phoneNumber)));
        } else if (responseData.action.toLowerCase() == "login") {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      PasswordPage(phoneNumber)));
        }
      }).catchError((error) {
        try {
          var err = error as DioError;
          if (err.type == DioErrorType.RESPONSE) {
            PhoneNumberModel response = phoneNumberResponseFromJson(json.encode(err.response.data));
            MyToast("${response.errors[0]}", context, position: 1);
          } else {
            MyToast("${err.message}", context, position: 1);
          }
        } catch (e) {
          MyToast("Unexpected Error!", context, position: 1);
        }
      }).whenComplete(() {
        setState(() {
          _isClicked = !_isClicked;
        });
      });

//      var check = getPhoneNumberResponse(_controller.text.toString().trim());
//      check.then((PhoneNumberModel responseData) {
//        if (responseData.status != null && responseData.status) {
//          if (responseData.action.toLowerCase() == "signup") {
//            Navigator.push(
//                context,
//                MaterialPageRoute(
//                    builder: (context) =>
//                        VerifyPINPage(_controller.text.toString())));
//          } else if (responseData.action.toLowerCase() == "login") {
//            Navigator.push(
//                context,
//                MaterialPageRoute(
//                    builder: (context) =>
//                        PasswordPage(_controller.text.toString())));
//          }
//          setState(() {
//            _isClicked = !_isClicked;
//          });
//        } else {
//          setState(() {
//            _isClicked = !_isClicked;
//          });
//        }
//      }).catchError((_) {
//        MyToast("Please enter valid phone number", context);
//        setState(() {
//          _isClicked = !_isClicked;
//        });
//      });
//    } else {
//      MyToast("Please enter phone number.", context);
//    }
    }

//    Future<PhoneNumberModel> getPhoneNumberResponse(String phoneNumber) async {
//      try {
//        Dio dio = new Dio();
//
//        Map<String, dynamic> map = {'phone': '$phoneNumber'};
//        var body = json.encode(map);
//
//        final response =
//            await dio.post(BASE_URL + URL_PHONENUMBER_CHECK, data: body);
//
//        print("RESPONSE: $response");
//        if (response.statusCode == HttpStatus.ok)
//          return responseFromJson(json.encode(response.data));
//        else
//          return PhoneNumberModel(status: false);
//      } on DioError catch (e) {
//        if (e.response != null) {
//          return responseFromJson(json.encode(e.response.data));
//        } else {
//          return PhoneNumberModel(status: false);
//        }
//      }
//    }
  }
}

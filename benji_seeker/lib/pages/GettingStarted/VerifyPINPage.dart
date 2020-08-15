import 'dart:convert';

import 'package:benji_seeker/My_Widgets/MyLoadingDialog.dart';
import 'package:benji_seeker/My_Widgets/MyToast.dart';
import 'package:benji_seeker/SharedPref/SavedData.dart';
import 'package:benji_seeker/constants/Constants.dart';
import 'package:benji_seeker/constants/MyColors.dart';
import 'package:benji_seeker/constants/Urls.dart';
import 'package:benji_seeker/custom_texts/MontserratText.dart';
import 'package:benji_seeker/models/JustStatusModel.dart';
import 'package:benji_seeker/models/VerifyPINModel.dart';
import 'package:benji_seeker/pages/CreateProfile/SignUpPage.dart';
import 'package:benji_seeker/utils/DioHelper.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:pin_input_text_field/pin_input_text_field.dart';

class VerifyPINPage extends StatefulWidget {
  final String phoneNumber;
  final bool updateProfileNumber;

  VerifyPINPage(this.phoneNumber, {this.updateProfileNumber = false});

  @override
  _VerifyPINPageState createState() => _VerifyPINPageState();
}

class _VerifyPINPageState extends State<VerifyPINPage> {
  var _pinController = TextEditingController();
  String _otpState = "Resend Code";
  DioHelper _dioHelper;

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
        backgroundColor: Colors.transparent,
        leading: IconButton(
          color: Colors.black,
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: GestureDetector(
              onTap: () {
                MyLoadingDialog(context, "Verifying PIN...");
                Map<String, dynamic> map = {
                  'otp': '${_pinController.text.toString()}',
                  'phone': '${widget.phoneNumber}'
                };
                _dioHelper
                    .postRequest(widget.updateProfileNumber
                    ? (BASE_URL + URL_UPDATE_PHONE_NUMBER)
                    : (BASE_URL + URL_PHONE_VERIFY), widget.updateProfileNumber ? {"token": ""} : null, map)
                    .then((result) {
                  Navigator.pop(context);
                  print("VERIFY PIN RESPONSE: ${result.data}");
                  var verifyPinModel =
                      verifyPinResponseFromJson(json.encode(result.data));
                  if (verifyPinModel.status) {
                    print("ACCESS CODE: ${verifyPinModel.accessCode}");
                    if (widget.updateProfileNumber) {
                      MyToast("Phone number updated!", context);
                      SavedData savedData = SavedData();
                      savedData.setValue(PHONE, widget.phoneNumber);
                      Navigator.pop(context);
                      Navigator.pop(context);
                    } else {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SignUpPage(
                                  widget.phoneNumber,
                                  verifyPinModel.accessCode)));
                    }
                  } else {
                    MyToast("${verifyPinModel.errors[0]}", context);
                  }
                }).catchError((error) {
                  try {
                    Navigator.pop(context);
                    var err = error as DioError;
                    if (err.type == DioErrorType.RESPONSE) {
                      var errorResponse = verifyPinResponseFromJson(
                          json.encode(err.response.data));
                      MyToast("${errorResponse.errors[0]}", context);
                    } else
                      MyToast("${err.message}", context);
                  } catch (e) {
                    MyToast("Unexpected error!", context);
                  }
                });
              },
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
                "Enter 4-digit code sent to you at",
                16,
                Colors.black,
                FontWeight.bold,
                top: 8.0,
              ),
              MontserratText(
                "${widget.phoneNumber}",
                16,
                accentColor,
                FontWeight.bold,
                top: 8.0,
              ),
              PinInputTextField(
                pinLength: 4,
                autoFocus: false,
                decoration: UnderlineDecoration(color: accentColor),
                controller: _pinController,
              ),
//              PinView(
//                autoFocusFirstField: false,
//                submit: (String value) {
//                  _pin = value;
//                },
//                count: 4,
//              ),
              Align(
                alignment: Alignment.bottomRight,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _otpState = "Sending...";
                    });
                    DioHelper dioHelper = DioHelper.instance;
                    dioHelper.postRequest(BASE_URL + URL_RESEND_OTP, null,
                        {"phone": "${widget.phoneNumber}"}).then((value) {
                      JustStatusModel justStatusModel =
                          justStatusResponseFromJson(json.encode(value.data));
                      if (justStatusModel.status) {
                        setState(() {
                          _otpState = "Sent";
                        });
                      } else {
                        setState(() {
                          _otpState = "Failed";
                        });
                      }
                    }).catchError((error) {
                      try {
                        setState(() {
                          _otpState = "Failed";
                        });
                        var err = error as DioError;
                        if (err.type == DioErrorType.RESPONSE) {
                          JustStatusModel justModel =
                              justStatusResponseFromJson(
                                  json.encode(err.response.data));
                          MyToast("${justModel.errors[0]}", context,
                              position: 1);
                        } else {
                          MyToast("${err.message}", context, position: 1);
                        }
                      } catch (e) {
                        MyToast("Unexpected Error!", context, position: 1);
                      }
                    });
                  },
                  child: MontserratText(
                    "$_otpState",
                    16,
                    accentColor,
                    FontWeight.bold,
                    top: 24.0,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

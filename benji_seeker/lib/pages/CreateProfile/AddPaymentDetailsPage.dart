import 'dart:async';
import 'dart:convert';

import 'package:benji_seeker/My_Widgets/DialogInfo.dart';
import 'package:benji_seeker/My_Widgets/MaskedTextInputFormatter.dart';
import 'package:benji_seeker/My_Widgets/MyDarkButton.dart';
import 'package:benji_seeker/My_Widgets/MyLoadingDialog.dart';
import 'package:benji_seeker/My_Widgets/MyToast.dart';
import 'package:benji_seeker/SharedPref/SavedData.dart';
import 'package:benji_seeker/constants/Constants.dart';
import 'package:benji_seeker/constants/MyColors.dart';
import 'package:benji_seeker/constants/Urls.dart';
import 'package:benji_seeker/custom_texts/MontserratText.dart';
import 'package:benji_seeker/models/JustStatusModel.dart';
import 'package:benji_seeker/models/SignUpModel.dart';
import 'package:benji_seeker/utils/DioHelper.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:keyboard_visibility/keyboard_visibility.dart';
import 'package:string_validator/string_validator.dart';
import 'package:url_launcher/url_launcher.dart';

import '../BotNav.dart';

class AddPaymentDetailsPage extends StatefulWidget {
  final Map<String, dynamic> userData;

  AddPaymentDetailsPage(this.userData);

  @override
  _AddPaymentDetailsPageState createState() => _AddPaymentDetailsPageState();
}

class _AddPaymentDetailsPageState extends State<AddPaymentDetailsPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> _formData = {
    "card_number": null,
    "card_holder_name": null,
    "expiry_date": null,
    "cvv": null
  };
  bool _isKeyBoardVisible = false;
  bool _termsAndConditions = false;

  @override
  void initState() {
    SavedData savedData = SavedData();
    savedData.getBoolValue(FIRST_TIME_DASHBOARD).then((value) {
      if(value == null){
        savedData.setBoolValue(FIRST_TIME_DASHBOARD, true);
      }
    });
    KeyboardVisibilityNotification().addNewListener(
      onChange: (bool visible) {
        setState(() {
          _isKeyBoardVisible = visible;
        });
      },
    );
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
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.arrow_back,
            color: Colors.black,
            size: 18,
          ),
        ),
        centerTitle: true,
        title: MontserratText(
            "Payment Details", 16, Colors.black, FontWeight.bold),
//        trailing: MyDarkButton("SUBMIT", submitBtnClick,fontWeight: FontWeight.w600,),
      ),
      body: Container(
        height: mediaQueryData.size.height,
        margin: EdgeInsets.only(
            left: mediaQueryData.size.width * 0.05,
            right: mediaQueryData.size.width * 0.05),
        child: Stack(
          children: <Widget>[
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  MontserratText("Please add a payment detail", 16,
                      lightTextColor, FontWeight.normal),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: <Widget>[
                        SizedBox(
                          height: mediaQueryData.size.height * 0.035,
                        ),
                        TextFormField(
                          style: labelTextStyle(
                              fontWeight: FontWeight.w500, textSize: 20),
                          cursorColor: accentColor,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            MaskedTextInputFormatter(
                                mask: "####-####-####-####", separator: "-")
                          ],
                          decoration: InputDecoration(
                              labelText: "Card Number",
                              labelStyle: labelTextStyle(letterSpacing: 0.06),
                              contentPadding: const EdgeInsets.only(top: -8.0)),
                          validator: (String value) {
                            if (value.isEmpty) return "Card number is required";
                            if (value.length != 19)
                              return "Please enter a valid credit card number.";
                            return null;
                          },
                          onSaved: (value) {
                            _formData['card_number'] = value;
                          },
                        ),
                        SizedBox(
                          height: mediaQueryData.size.height * 0.035,
                        ),
                        TextFormField(
                          style: labelTextStyle(
                              fontWeight: FontWeight.w500, textSize: 20),
                          cursorColor: accentColor,
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                              labelText: "Card Holder Name",
                              labelStyle: labelTextStyle(letterSpacing: 0.06),
                              contentPadding: const EdgeInsets.only(top: -8.0)),
                          validator: (String value) {
                            if (value.isEmpty)
                              return "Card holder name is required";
                            value = value.replaceAll(' ', '');
                            if (!isAlpha(value)) {
                              return "Name should contain only alphabets.";
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _formData['card_holder_name'] = value;
                          },
                        ),
                        SizedBox(
                          height: mediaQueryData.size.height * 0.035,
                        ),
                        TextFormField(
                          style: labelTextStyle(
                              fontWeight: FontWeight.w500, textSize: 20),
                          cursorColor: accentColor,
                          keyboardType: TextInputType.datetime,
                          inputFormatters: [
                            MaskedTextInputFormatter(
                                mask: "##/##", separator: "/")
                          ],
                          decoration: InputDecoration(
                              labelText: "Expiry Date",
                              labelStyle: labelTextStyle(letterSpacing: 0.06),
                              contentPadding: const EdgeInsets.only(top: -8.0)),
                          validator: (String value) {
                            if (value.isEmpty) return "Expiry date is required";
                            List<String> dateSplit = value.split("/");
                            if (isNumeric(dateSplit[0]) &&
                                isNumeric(dateSplit[1])) {
                              int month = int.parse(dateSplit[0]);
                              int year = int.parse(dateSplit[1]);
                              year = 2000 + year;
                              if (month < 1 || month > 12) {
                                return "Month should be 1 to 12";
                              }

                              if (DateTime.now().year > year) {
                                return "Invalid year entered";
                              }
                            } else {
                              return "Expiry date is wrong";
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _formData['expiry_date'] = value;
                          },
                        ),
                        SizedBox(
                          height: mediaQueryData.size.height * 0.035,
                        ),
                        TextFormField(
                          style: labelTextStyle(
                              fontWeight: FontWeight.w500, textSize: 20),
                          cursorColor: accentColor,
                          keyboardType: TextInputType.number,
                          obscureText: true,
                          decoration: InputDecoration(
                              labelText: "CVV",
                              labelStyle: labelTextStyle(letterSpacing: 0.06),
                              contentPadding: const EdgeInsets.only(top: -8.0)),
                          validator: (String value) {
                            if (value.isEmpty) return "CVV is required";
                            if (value.length != 3) return "CVV is 3 digits";
                            return null;
                          },
                          onSaved: (value) {
                            _formData['cvv'] = value;
                          },
                        ),
                        CheckboxListTile(
                          value: _termsAndConditions,
                          onChanged: (bool value) {
                            setState(() {
                              _termsAndConditions = value;
                            });
                          },
                          title: RichText(
                            text: TextSpan(
                                text: "By signing up I agree to BENJI's ",
                                style: _termsAndConditionStyle(),
                                children: <TextSpan>[
                                  TextSpan(
                                      text: "Terms & Conditions",
                                      style: _termsAndConditionStyle(
                                          isHyperLink: true),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () {
                                          _launchURL(context,
                                              "https://benjilawn.com/terms-and-conditions/");
                                        })
                                ]),
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
            _isKeyBoardVisible
                ? Container()
                : Positioned(
                    bottom: mediaQueryData.size.height * 0.02,
                    child: Container(
                        height: 50,
                        width: mediaQueryData.size.width * 0.9,
                        child: MyDarkButton("SUBMIT", _submitBtnClick)),
                  )
          ],
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
        fontFamily: "Montserrat");
  }

  _launchURL(BuildContext context, String skillUrl) async {
    var url = '$skillUrl';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      MyToast("Could not launch $url", context);
    }
  }

  TextStyle _termsAndConditionStyle({bool isHyperLink = false}) {
    return TextStyle(
        fontWeight: FontWeight.normal,
        color: isHyperLink ? Colors.blueAccent : Colors.black,
        fontFamily: "Montserrat",
        fontSize: 14.0,
        decoration:
            isHyperLink ? TextDecoration.underline : TextDecoration.none);
  }

  void _submitBtnClick() {
    if (!_termsAndConditions) {
      MyToast("You must read and agree to the Terms & Conditions", context,
          position: 0);
      return;
    }
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      String cardNumber = _formData["card_number"];
      _formData["card_number"] = cardNumber.replaceAll("-", "");

      Map<String, dynamic> data = {
        "access_code": "${widget.userData["access_code"]}",
        "first_name": "${widget.userData["first_name"]}",
        "last_name": "${widget.userData["last_name"]}",
        "email": "${widget.userData["email"]}",
        "password": "${widget.userData["password"]}",
        "payment_details": "${json.encode(_formData)}"
      };
      _postSignUp(data, "${widget.userData["phone"]}");
    }
  }

  _postSignUp(Map<String, dynamic> data, String phoneNumber) {
    print("SIGN UP DATA: $data");
    MyLoadingDialog(context, "Creating account...");

    DioHelper dioHelper = DioHelper.instance;

//    {status: true, token: 2973d6e28ea6fe698dfbbecb1fe0f6d0b527ca7cce5cd15ea8d80cb211faecaf517cbbd1e992372f, seeker_id: 5f3455ce07009326f25fa965}
    dioHelper.postRequest(BASE_URL + URL_SIGN_UP, null, data).then((value) {
      print("RESPONSE: ${value.data}");
      SignUpModel signUpModel = signUpResponseFromJson(json.encode(value.data));
      if (signUpModel.status) {
        SavedData savedData = new SavedData();
        savedData.setValue(TOKEN, signUpModel.token);
        savedData.setValue(FIRST_NAME, "${data["first_name"]}");
        savedData.setValue(LAST_NAME, "${data["last_name"]}");
        savedData.setValue(EMAIL, "${data["email"]}");
        savedData.setValue(PHONE, "$phoneNumber");

        showDialog(
          context: context,
          builder: (_) => DialogInfo(
            "assets/profile_submitted.png",
            "Welcome! ${data["first_name"]}",
            "We are excited to help you plan and complete your year's chores for you.",
          ),
        );

        Timer(const Duration(seconds: 3), () {
          while (Navigator.canPop(context)) {
            Navigator.pop(context);
          }
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => BotNavPage()));
        });
      } else {
        Navigator.pop(context);
        MyToast("${signUpModel.errors[0]}", context);
      }
    }).catchError((error) {
      try {
        Navigator.pop(context);
        var err = error as DioError;
        if (err.type == DioErrorType.RESPONSE) {
          SignUpModel signUpModel =
              signUpResponseFromJson(json.encode(err.response.data));
          MyToast("${signUpModel.errors[0]}", context, position: 1);
        } else {
          MyToast("${err.message}", context, position: 1);
        }
      } catch (e) {
        MyToast("Unexpected Error!", context, position: 1);
      }
    });
  }
}

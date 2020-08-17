import 'dart:convert';

import 'package:basic_utils/basic_utils.dart';
import 'package:benji_seeker/My_Widgets/MyLoadingDialog.dart';
import 'package:benji_seeker/My_Widgets/MyToast.dart';
import 'package:benji_seeker/constants/MyColors.dart';
import 'package:benji_seeker/constants/Urls.dart';
import 'package:benji_seeker/custom_texts/MontserratText.dart';
import 'package:benji_seeker/models/JustStatusModel.dart';
import 'package:benji_seeker/utils/DioHelper.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class ForgotPasswordPage extends StatefulWidget {
  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  TextEditingController _controller = TextEditingController();
  DioHelper _dioHelper;
  bool _validEmail = true;

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
                "Enter your registered email address",
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
                      keyboardType: TextInputType.emailAddress,
                      style: labelTextStyle(
                          fontWeight: FontWeight.normal, textSize: 20),
                      decoration: InputDecoration(
                          labelText: "Enter your email",
                          labelStyle: labelTextStyle(),
                          errorText: _validEmail ? null : "Invalid Email",
                          contentPadding: const EdgeInsets.only(top: -8.0)),
                    ),
                  ),
                  Flexible(
                    flex: 2,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _validEmail =
                              EmailUtils.isEmail(_controller.text.toString());
                        });
                        if (_validEmail) {
                          MyLoadingDialog(context,"Sending recovery email...");
                          _process(_controller.text.toString());
                        }
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

  void _process(String email) {
    _dioHelper.postRequest(
        BASE_URL + URL_FORGOT_PASSWORD, null, {"email": email}).then((value) {
      Navigator.pop(context);
      JustStatusModel model = justStatusResponseFromJson(json.encode(value.data));
      if(model.status){
        MyToast("${model.errors[0]}", context, position: 1);
      }else{
        MyToast("${model.errors[0]}", context, position: 1);
      }
    }).catchError((error) {
      try {
        Navigator.pop(context);
        var err = error as DioError;
        if (err.type == DioErrorType.RESPONSE) {
          var errorResponse = justStatusResponseFromJson(
              json.encode(err.response.data));
          MyToast("${errorResponse.errors[0]}", context, position: 1);
        } else
          MyToast("${err.message}", context, position: 1);
      }catch (e){
        MyToast("Unexpected Error!", context, position: 1);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:benji_seeker/My_Widgets/CustomProgressDialog.dart';
import 'package:benji_seeker/My_Widgets/DialogInfo.dart';
import 'package:benji_seeker/My_Widgets/MyDarkButton.dart';
import 'package:benji_seeker/My_Widgets/MyToast.dart';
import 'package:benji_seeker/SharedPref/SavedData.dart';
import 'package:benji_seeker/constants/Constants.dart';
import 'package:benji_seeker/constants/MyColors.dart';
import 'package:benji_seeker/constants/Urls.dart';
import 'package:benji_seeker/custom_texts/QuicksandText.dart';
import 'package:benji_seeker/models/JustStatusModel.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class FeedbackPage extends StatefulWidget {
  @override
  _FeedbackPageState createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  var _subjectController = TextEditingController();
  var _messageController = TextEditingController();

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
        centerTitle: false,
        leading: IconButton(
          color: Colors.black,
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: QuicksandText(
            "Give us feedback", 22, Colors.black, FontWeight.bold),
      ),
      body: SafeArea(
        child: Container(
          height: mediaQueryData.size.height,
          width: mediaQueryData.size.width,
          margin: EdgeInsets.only(
              top: 16.0,
              bottom: 16.0,
              left: mediaQueryData.size.width * 0.05,
              right: mediaQueryData.size.width * 0.05),
          child: Column(
            children: <Widget>[
              _textField(mediaQueryData, "Subject", _subjectController),
              _textField(mediaQueryData, "Message", _messageController, maxLines: 5),
              Expanded(
                child: Align(
                  alignment: FractionalOffset.bottomCenter,
                  child: Container(
                      width: mediaQueryData.size.width,
                      height: 50,
                      margin: const EdgeInsets.only(top: 16.0),
                      child: MyDarkButton("SUBMIT", _btnClick)),
                ),
              )
            ],
          ),
//          child: Stack(
//            children: <Widget>[
//              Column(
//                children: <Widget>[
//                  _textField("Subject", null),
//                  _textField("Message", null),
//                ],
//              ),
//              Positioned(
//                bottom: 16.0,
//                child: Container(
//                    width: mediaQueryData.size.width,
//                    height: 50,
//                    margin: const EdgeInsets.only(top: 16.0),
//                    child: MyDarkButton("SAVE & UPDATE", _btnClick)),
//              )
//            ],
//          ),
        ),
      ),
    );
  }

  void _btnClick(){
    var subject = _subjectController.text.toString();
    var message = _messageController.text.toString();

    if (subject.isNotEmpty && message.isNotEmpty) {
      _showProgressDialog("Submitting...");
      _postFeedbackResponse(subject, message).then((value){
        Navigator.pop(context);
        if(value.status){
          _showDialog("assets/start_job.png", "Thank You!!", "We greatly appreciate your feedback and it will help us serve you better.");
          Timer(const Duration(seconds: 3), (){
            Navigator.pop(context);//Pop info dialog
            Navigator.pop(context);//Pop Screen
          });

        }else{
          MyToast("Error occured!", context);
        }
      });
    }else{
      MyToast("Fill the form complete!", context);
    }
  }

  Widget _textField(MediaQueryData mediaQueryData, String label, TextEditingController controller,
      {int maxLines = 1}) {
    return Container(
      margin: EdgeInsets.only(top: mediaQueryData.size.height * 0.03),
      child: TextFormField(
        controller: controller,
        cursorColor: accentColor,
        style: _labelTextStyle(fontWeight: FontWeight.w500, textSize: 20),
        decoration:
        InputDecoration(labelText: "$label", labelStyle: _labelTextStyle(), contentPadding: const EdgeInsets.only(top: -8.0)),
        maxLines: maxLines,
        minLines: 1,
      ),
    );
  }

  TextStyle _labelTextStyle(
      {FontWeight fontWeight = FontWeight.normal, double textSize = 16}) {
    return TextStyle(
        color: Colors.black,
        fontSize: textSize,
        fontWeight: fontWeight,
        fontFamily: "Montserrat");
  }

  void _showProgressDialog(String message) {
    showDialog(
        context: context,
        barrierDismissible: bool.fromEnvironment("dismiss dialog"),
        builder: (BuildContext context) {
          return CustomProgressDialog("$message");
        });
  }

  void _showDialog(String image, String title, String description) {
    showDialog(
        context: context,
        barrierDismissible: bool.fromEnvironment("dismiss dialog"),
        builder: (BuildContext context) {
          return DialogInfo("$image", "$title", "$description");
        });
  }

  Future<JustStatusModel> _postFeedbackResponse(
      String subject, String message) async {
    try {
      Dio dio = new Dio();

      SavedData savedData = new SavedData();
      String token = await savedData.getValue(TOKEN);

      Map<String, dynamic> map = {"subject": '$subject', "message": '$message'};
      Options options = new Options(headers: {"token": token});

      final response = await dio.post(BASE_URL + URL_FEEDBACK,
          options: options, data: json.encode(map));

      print("RESPONSE: $response");
      if (response.statusCode == HttpStatus.ok) {
        return justStatusResponseFromJson(json.encode(response.data));
      } else {
        return JustStatusModel(status: false);
      }
    } on DioError catch (e) {
      print("RESPONSE: ${e.response}");

      if (e.response != null) {
        return justStatusResponseFromJson(json.encode(e.response.data));
      } else {
        return JustStatusModel(status: false);
      }
    }
  }
}

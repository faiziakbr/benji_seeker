import 'dart:convert';
import 'dart:io';

import 'package:benji_seeker/My_Widgets/CustomProgressDialog.dart';
import 'package:benji_seeker/My_Widgets/MyDarkButton.dart';
import 'package:benji_seeker/My_Widgets/MyToast.dart';
import 'package:benji_seeker/SharedPref/SavedData.dart';
import 'package:benji_seeker/constants/Constants.dart';
import 'package:benji_seeker/constants/MyColors.dart';
import 'package:benji_seeker/constants/Urls.dart';
import 'package:benji_seeker/custom_texts/MontserratText.dart';
import 'package:benji_seeker/custom_texts/QuicksandText.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class InvitePage extends StatefulWidget {
  @override
  _InvitePageState createState() => _InvitePageState();
}

class _InvitePageState extends State<InvitePage> {
  var _controller = TextEditingController();

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
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title:
        QuicksandText("Invite Friends", 22, Colors.black, FontWeight.bold),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Container(
          height: mediaQueryData.size.height * 0.9,
          margin: EdgeInsets.only(
              top: 16.0,
              left: mediaQueryData.size.width * 0.05,
              right: mediaQueryData.size.width * 0.05),
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Image.asset("assets/invite_pic.png"),
                MontserratText(
                  "Invite Your Friends and Create a GRASSroots movement!",
                  20,
                  Colors.black,
                  FontWeight.bold,
                  top: 24.0,
                  textAlign: TextAlign.center,
                  bottom: 16,
                ),
                MontserratText(
                  "(pun intended)",
                  14,
                  Colors.black,
                  FontWeight.normal,
                  textAlign: TextAlign.center,
                  bottom: 24.0,
                ),
                TextField(
                  controller: _controller,
                  cursorColor: accentColor,
                  keyboardType: TextInputType.emailAddress,
                  style:
                  labelTextStyle(fontWeight: FontWeight.w500, textSize: 20),
                  decoration: InputDecoration(
                      labelText: "Enter email",
                      labelStyle: labelTextStyle(letterSpacing: 0.06),
                      contentPadding: const EdgeInsets.only(top: -8.0)),
                ),
                Container(
                    height: 50,
                    width: mediaQueryData.size.width,
                    margin: const EdgeInsets.only(top: 24.0),
                    child: MyDarkButton(
                      "INVITE FRIENDS",
                          () {
                        if(_controller.text.isNotEmpty){
                          _showProgressDialog("Sending invite...");
                          _postInviteUser(_controller.text).then((result){
                            Navigator.pop(context); //pop progress dialog
                            if(result.status){
                              MyToast("Invite successfully sent.", context);
                              Navigator.pop(context);//pop screen
                            }else{
                              MyToast("Unable to send invite.", context);
                            }
                          });
                        }else{
                          MyToast("Please provide email.", context);
                        }
                      },
                      fontWeight: FontWeight.w600,
                    ))
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showProgressDialog(String message) {
    showDialog(
        context: context,
        barrierDismissible: bool.fromEnvironment("dismiss dialog"),
        builder: (BuildContext context) {
          return CustomProgressDialog("$message");
        });
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

  Future<InviteModel> _postInviteUser(String email) async {
    try {
      BaseOptions baseOptions = new BaseOptions(
        connectTimeout: 15000,
        receiveTimeout: 15000,
      );
      Dio dio = new Dio(baseOptions);

      Map<String, dynamic> map = {'email': '$email'};
      var body = json.encode(map);

      SavedData savedData = new SavedData();
      String token = await savedData.getValue(TOKEN);

      Options options = new Options(headers: {"token": token});
      final response =
      await dio.post(BASE_URL + URL_INVITE, options: options, data: body);

      print("STATUS CODE: ${response.statusCode}");
      print("RESPONSE: $response");
      if (response.statusCode == HttpStatus.ok ||
          response.statusCode == HttpStatus.created)
        return _responseFromJson(json.encode(response.data));
      else
        return InviteModel(status: false);
    } on DioError catch (e) {
      print("DIO ERROR: ${e.toString()}");
      if (e.response != null) {
        return _responseFromJson(json.encode(e.response.data));
      } else {
        return InviteModel(status: false);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}


InviteModel _responseFromJson(String jsonString) {
  final jsonData = json.decode(jsonString);
  return InviteModel.fromJson(jsonData);
}

class InviteModel {
  bool status;
  List<dynamic> errors = [""];

  InviteModel({this.status,this.errors});

  InviteModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    errors = json['errors'];
  }
}

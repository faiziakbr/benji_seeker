import 'dart:convert';

import 'package:benji_seeker/My_Widgets/CustomProgressDialog.dart';
import 'package:benji_seeker/My_Widgets/MyDarkButton.dart';
import 'package:benji_seeker/My_Widgets/MyToast.dart';
import 'package:benji_seeker/constants/MyColors.dart';
import 'package:benji_seeker/constants/Urls.dart';
import 'package:benji_seeker/custom_texts/MontserratText.dart';
import 'package:benji_seeker/utils/DioHelper.dart';
import 'package:dio/dio.dart';
import "package:flutter/material.dart";
import 'package:keyboard_visibility/keyboard_visibility.dart';
import 'package:string_validator/string_validator.dart';

class EditBankDetails extends StatefulWidget {
  @override
  _EditBankDetailsState createState() => _EditBankDetailsState();
}

class _EditBankDetailsState extends State<EditBankDetails> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  DioHelper _dioHelper;
  BankDetailModel _bankDetailModel;
  final Map<String, dynamic> _formData = {
    "name": null,
    "card_number": null,
    "cvv": null,
    "expiry_date": null
  };

  bool _isLoading = true;
  bool _isError = false;
  bool _isKeyBoardVisible = false;
  var _accountNumber = "";

//  {"status":true,"bank_details":{"account_holder_name":"Danish umair","account_number":"**** 6789","routing_number":"110000000"}}
  @override
  void initState() {
    _dioHelper = DioHelper.instance;
    KeyboardVisibilityNotification().addNewListener(
      onChange: (bool visible) {
        setState(() {
          _isKeyBoardVisible = visible;
        });
      },
    );

    _getAccountDetails();
    super.initState();
  }

  void _getAccountDetails() {
    _dioHelper.getRequest(BASE_URL + URL_GET_BANK_DETAILS, {"token": ""}).then(
        (value) {
      print("BANK VALUE: $value");
      _bankDetailModel =
          _bankDetailModelResponseFromJson(json.encode(value.data));

      if (_bankDetailModel.status) {
        _formData['name'] = _bankDetailModel.detailModel.accountHolderName;
        _formData['card_number'] = _bankDetailModel.detailModel.cardNumber;
        _formData['cvv'] = _bankDetailModel.detailModel.cvv;
        _formData['expiry_date'] = _bankDetailModel.detailModel.expiryDate;
      } else {
        setState(() {
          _isError = true;
        });
        List<dynamic> errors = ["Unable to get your account details!"];
        _bankDetailModel = BankDetailModel(status: false, errors: errors);
      }
    }).catchError((error) {
      try {
        print("BANK VALUE: $error");
        var err = error as DioError;
        if (err.type == DioErrorType.RESPONSE) {
          var errorResponse =
              _bankDetailModelResponseFromJson(json.encode(err.response.data));
          MyToast("${errorResponse.errors[0]}", context, position: 1);
        } else
          MyToast("${err.message}", context, position: 1);

        setState(() {
          _isError = true;
        });
      } catch (e) {
        setState(() {
          _isError = true;
        });
        List<dynamic> errors = ["Unable to get your account details!"];
        _bankDetailModel = BankDetailModel(status: false, errors: errors);
      }
    }).whenComplete(() {
      setState(() {
        _isLoading = false;
      });
      if (_bankDetailModel == null) {
        List<dynamic> errors = ["No Internet!"];
        _bankDetailModel = BankDetailModel(status: false, errors: errors);
      }
    });
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
        title:
            MontserratText("Bank Details", 16, Colors.black, FontWeight.bold),
//        trailing: MyDarkButton("SUBMIT", submitBtnClick,fontWeight: FontWeight.w600,),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : _isError
              ? Center(
                  child: MontserratText("${_bankDetailModel.errors[0]}", 18,
                      Colors.black, FontWeight.normal),
                )
              : Container(
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
                            MontserratText("Edit payment detail", 16,
                                lightTextColor, FontWeight.normal),
                            Form(
                              key: _formKey,
                              child: Column(
                                children: <Widget>[
                                  _textField(mediaQueryData, "Card Number",
                                      "card_number", _formData['card_number']),
                                  _textField(mediaQueryData, "Card Holder Name",
                                      "name", _formData['name'], textInputType: TextInputType.text),
                                  _textField(mediaQueryData, "CVV", "cvv",
                                      _formData['cvv'],
                                      textInputType: TextInputType.number,
                                      obscure: true),
                                  _textField(mediaQueryData, "Expiry Date",
                                      "expiry_date", _formData['expiry_date'],
                                      textInputType: TextInputType.datetime),
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
                                  child:
                                      MyDarkButton("UPDATE", _submitBtnClick)),
                            )
                    ],
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

  Widget _textField(MediaQueryData mediaQueryData, String text, String key,
      String initialValue,
      {TextInputType textInputType = TextInputType.number,
      bool obscure = false}) {
    return Container(
      margin: EdgeInsets.only(top: mediaQueryData.size.height * 0.04),
      child: TextFormField(
        style: _labelTextStyle(fontWeight: FontWeight.w500, textSize: 20),
        cursorColor: accentColor,
        obscureText: obscure,
        initialValue: initialValue,
        keyboardType: textInputType,
        decoration: InputDecoration(
            labelText: "$text",
            labelStyle: _labelTextStyle(),
            contentPadding: const EdgeInsets.only(top: -8.0)),
        validator: (value) {
          if (value.isEmpty) return "Field is required!";
//          if (textInputType == TextInputType.text) {
//            value = value.replaceAll(' ', '');
//            if (!isAlpha(value)) {
//              return "Name should contain only alphabets.";
//            }
//          }
          return null;
        },
        onSaved: (value) {
          if (key == "name") {
            _formData["name"] = value;
          } else if (key == "card_number") {
            _formData["card_number"] = value;
          } else if (key == "cvv") {
            _formData["cvv"] = value;
          } else if (key == "expiry_date") {
            _formData["expiry_date"] = value;
          }
        },
      ),
    );
  }

  TextStyle _labelTextStyle(
      {FontWeight fontWeight = FontWeight.normal, double textSize = 14}) {
    return TextStyle(
        color: lightTextColor,
        fontSize: textSize,
        fontWeight: fontWeight,
        fontFamily: "Montserrat");
  }

  void _submitBtnClick() {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();

      _showProgressDialog("Updating Bank Details...");

      String accountNumber = _formData["card_number"];
      String name = _formData["name"];
      String cvv = _formData["cvv"];
      String expiryDate = _formData["expiry_date"];

      _postUpdateBankDetails(accountNumber, name, cvv, expiryDate);
    }
  }

  void _postUpdateBankDetails(
      String accountNumber, String holderName, String cvv, String expiryDate) {
    Map<String, dynamic> map = {
      'card_number': accountNumber,
      "card_holder_name": holderName,
      "expiry_date": expiryDate,
      "cvv": cvv
    };
    print("REQUEST: $map");

    _dioHelper
        .postRequest(BASE_URL + URL_UPDATE_BANK_DETAILS, {"token": {}}, map)
        .then((value) {
      print("GOT DAta: $value");
      UpdatingBankDetailModel updatingBankDetailModel =
          _updatingbankDetailModelResponseFromJson(json.encode(value.data));

      if (updatingBankDetailModel.status) {
        MyToast("Successfully Updated!", context, position: 1);
        Navigator.pop(context);
      } else {
        MyToast("${updatingBankDetailModel.errors[0]}", context, position: 1);
      }
    }).catchError((error) {
      try {
        print("GOT DAta: $error");
        var err = error as DioError;
        if (err.type == DioErrorType.RESPONSE) {
          var errorResponse = _updatingbankDetailModelResponseFromJson(
              json.encode(err.response.data));
          MyToast("${errorResponse.errors[0]}", context, position: 1);
        } else
          MyToast("${err.message}", context, position: 1);
      } catch (e) {
        MyToast("Error updating your account details.", context, position: 1);
      }
    }).whenComplete(() {
      Navigator.pop(context);
    });
  }
}

BankDetailModel _bankDetailModelResponseFromJson(String jsonString) {
  final jsonData = json.decode(jsonString);
  return BankDetailModel.fromJson(jsonData);
}

class BankDetailModel {
  bool status;
  BankDetail detailModel;
  List<dynamic> errors = ["Error!"];

  BankDetailModel({this.status, this.errors});

  BankDetailModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    if (json['card_details'] != null)
      detailModel = BankDetail.fromJson(json['card_details']);
    if (json['errors'] != null) errors = json['errors'];
  }
}

class BankDetail {
  String accountHolderName;
  String cardNumber;
  String cvv;
  String expiryDate;

  BankDetail.fromJson(Map<String, dynamic> json) {
    accountHolderName = json['name'];
    cardNumber = json['card_number'];
    cvv = json['cvv'];
    expiryDate = json['expiry_date'];
  }
}

UpdatingBankDetailModel _updatingbankDetailModelResponseFromJson(
    String jsonString) {
  final jsonData = json.decode(jsonString);
  return UpdatingBankDetailModel.fromJson(jsonData);
}

class UpdatingBankDetailModel {
  bool status;
  List<dynamic> errors = ['errors'];

  UpdatingBankDetailModel({this.status, this.errors});

  UpdatingBankDetailModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    errors = json['errors'];
  }
}

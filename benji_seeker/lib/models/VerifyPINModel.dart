import 'dart:convert';

VerifyPinModel verifyPinResponseFromJson(String jsonString) {
  final jsonData = json.decode(jsonString);
  return VerifyPinModel.fromJson(jsonData);
}

class VerifyPinModel {
  bool status;
  String accessCode;
  List<dynamic> errors = [""];

  VerifyPinModel({this.status, this.accessCode, this.errors});

  VerifyPinModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    accessCode = json['access_code'];
    errors = json['errors'];
  }
}

ResendOTPModel resendOTPResponseFromJson(String jsonString) {
  final jsonData = json.decode(jsonString);
  return ResendOTPModel.fromJson(jsonData);
}

class ResendOTPModel {
  bool status;

  ResendOTPModel({this.status});

  ResendOTPModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
  }
}
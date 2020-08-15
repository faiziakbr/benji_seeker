import 'dart:convert';

PhoneNumberModel phoneNumberResponseFromJson(String jsonString) {
  final jsonData = json.decode(jsonString);
  return PhoneNumberModel.fromJson(jsonData);
}

class PhoneNumberModel {
  bool status;
  String action;
  List<dynamic> errors = [""];

  PhoneNumberModel({this.status, this.action, this.errors});

  PhoneNumberModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    action = json['action'];
    errors = json['errors'];
  }
}
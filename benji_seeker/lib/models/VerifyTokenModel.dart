import 'dart:convert';

VerifyTokenModel verifyTokenResponseFromJson(String jsonString) {
  final jsonData = json.decode(jsonString);
  return VerifyTokenModel.fromJson(jsonData);
}

class VerifyTokenModel {
  bool status;
  VerifyTokenUserModel verifyTokenUserModel;
  List<dynamic> errors = [''];

  VerifyTokenModel({this.status, this.verifyTokenUserModel, this.errors});

  VerifyTokenModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    if (json['user'] != null)
    verifyTokenUserModel = VerifyTokenUserModel.fromJson(json['user']);
    errors = json['errors'];
  }
}

class VerifyTokenUserModel {
  String firstName;
  String lastName;
  String role;
  String status;

  VerifyTokenUserModel.fromJson(Map<String, dynamic> json) {
    firstName = json['first_name'];
    lastName = json['last_name'];
    status = json['status'];
    role = json['role'];
  }
}
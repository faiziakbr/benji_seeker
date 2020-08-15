import 'dart:convert';

import 'package:benji_seeker/models/UserModel.dart';

LoginModel loginModelResponseFromJson(String jsonString) {
  final jsonData = json.decode(jsonString);
  return LoginModel.fromJson(jsonData);
}

class LoginModel {
  bool status;
  String token;
  List<dynamic> errors = [""];

  LoginModel({this.status, this.token, this.errors});

  LoginModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    token = json['token'];
    errors = json['errors'];
  }
}

import 'dart:convert';

SignUpModel signUpResponseFromJson(String jsonString) {
  final jsonData = json.decode(jsonString);
  return SignUpModel.fromJson(jsonData);
}

class SignUpModel{
  bool status;
  String token;
  List<dynamic> errors = [""];

  SignUpModel({this.status});

  SignUpModel.fromJson(Map<String, dynamic> parsedJson) {
    status = parsedJson['status'];
    if (parsedJson["token"] != null)
      token = parsedJson['token'];
    errors = parsedJson['errors'];
  }
}
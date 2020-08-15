import 'dart:convert';

JustStatusModel justStatusResponseFromJson(String jsonString) {
  final jsonData = json.decode(jsonString);
  return JustStatusModel.fromJson(jsonData);
}

class JustStatusModel{
  bool status;
  List<dynamic> errors = [""];

  JustStatusModel({this.status});

  JustStatusModel.fromJson(Map<String, dynamic> parsedJson) {
    status = parsedJson['status'];
    errors = parsedJson['errors'];
  }
}
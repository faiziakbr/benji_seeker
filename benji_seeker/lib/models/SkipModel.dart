import 'dart:convert';

SkipModel skipResponseFromJson(String jsonString) {
  final jsonData = json.decode(jsonString);
  return SkipModel.fromJson(jsonData);
}


class SkipModel{
  bool status;
  String nextdate;
  List<dynamic> errors;

  SkipModel.fromJson(Map<String, dynamic> json){
    status = json['status'];
    if(json["next_date"] != null){
      nextdate = json["next_date"];
    }
    errors = json['errors'];
  }
}
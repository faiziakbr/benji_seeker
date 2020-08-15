import 'dart:convert';

JobDetailModel jobDetailResponseFromJson(String jsonString) {
  final jsonData = json.decode(jsonString);
  return JobDetailModel.fromJson(jsonData);
}

class JobDetailModel {
  bool status;
  Detail detail;
  List<dynamic> error = [""];

  JobDetailModel({this.status});

  JobDetailModel.fromJson(Map<String, dynamic> parsedJson) {
    status = parsedJson['status'];
    if (parsedJson['job_detail'] != null)
      detail = Detail.fromJson(parsedJson['job_detail']);
    error = parsedJson['errors'];
  }
}

class Detail {
  String id;
  String seekerId;
  String processId;
  String category;
  String subCategory;
  String when;
  bool isRecurring;
  int recurringDays;
  String endDate;
  String where;
  double estimatedIncome;
  String description;
  double estimatedDuration;
  String nextStep;
  List<dynamic> skipDates = [];
  List<String> images = [];
  String providerId;

  Detail.fromJson(Map<String, dynamic> json) {
    id = json["_id"];
    seekerId = json['seeker_id'];
    processId = json['process_id'];
    category = json['category'];
    subCategory = json['sub_category'];
    when = json['when'];
    isRecurring = json["is_recurring"];
    if (isRecurring) {
      recurringDays = int.parse(json['recurrence_data']['days'].toString()).toInt();
      endDate = json['recurrence_data']['end_date'];
    }
    where = json['where'];
    estimatedIncome =
        double.parse(json['estimated_income'].toString()).toDouble();
    description = json['description'];
    estimatedDuration =
        double.parse(json['estimated_duration'].toString()).toDouble();
    nextStep = json['job_next_step'];
    if (json["provider_id"] != null) providerId = json['provider_id'];

    List<String> _temp = [];
    var key = json['images'];
    if (key != null && key.length > 0) {
      for (int i = 0; i < key.length; i++) {
        _temp.add(key[i]);
      }
    }
    images = _temp;

    nextStep = json['job_next_step'];

    if (json['skip'] != null) {
      skipDates = json['skip'];
    }
  }
}

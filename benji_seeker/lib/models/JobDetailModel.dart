import 'dart:convert';

JobDetailModel jobDetailResponseFromJson(String jsonString) {
  final jsonData = json.decode(jsonString);
  return JobDetailModel.fromJson(jsonData);
}

class JobDetailModel {
  bool status;
  Detail detail;
  List<dynamic> errors = [""];

  JobDetailModel({this.status});

  JobDetailModel.fromJson(Map<String, dynamic> parsedJson) {
    status = parsedJson['status'];
    if (parsedJson['job_detail'] != null)
      detail = Detail.fromJson(parsedJson['job_detail']);
    errors = parsedJson['errors'];
  }
}

class Detail {
  String id;
  String seekerId;
  String processId;
  String category;
  String subCategoryId;
  String subCategory;
  String subCategoryImage;
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
  bool transactionPending = false;
  String transactionError;

  Detail.fromJson(Map<String, dynamic> json) {
    id = json["_id"];
    seekerId = json['seeker_id'];
    processId = json['process_id'];
    category = json['category'];
    subCategoryId = json['sub_category_id'];
    subCategory = json['sub_category'];
    subCategoryImage = json['sub_category_image'];
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

    if(json["transaction_pending"] != null){
      transactionPending = json["transaction_pending"];
      transactionError = json["transaction_error"];
    }

    if (json['skip'] != null) {
      skipDates = json['skip'];
    }
  }
}

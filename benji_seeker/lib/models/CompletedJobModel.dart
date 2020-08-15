import 'dart:convert';

CompletedJobModel completedJobModelResponseFromJson(String jsonString) {
  final jsonData = json.decode(jsonString);
  return CompletedJobModel.fromJson(jsonData);
}

class CompletedJobModel{

  bool status;
  int timeInMinutes;
  double estimatedWage;
  String categoryId;
  String profilePicture = "";
  String providerId;
  String amountPaid;
  String providerName;
  String providerAddress;
  bool tipGiven;
  bool rated;
  List<dynamic> errors = [""];

  CompletedJobModel.fromJson(Map<String, dynamic> json){
    status = json['status'];
    timeInMinutes = int.parse(json['completed_job_detail']['time_in_minutes'].toString()).toInt();
    estimatedWage = double.parse(json['completed_job_detail']['estimated_wage'].toString()).toDouble();
    categoryId = json['completed_job_detail']['category_id'];
    profilePicture = json['completed_job_detail']['profile_picture'];
    providerId = json['completed_job_detail']['provider_id'];
    amountPaid = json['completed_job_detail']['amount_paid'];
    providerName = json['completed_job_detail']['provider_name'];
    providerAddress = json['completed_job_detail']['provider_address'];
    tipGiven = json['completed_job_detail']['tip_given'];
    rated = json['completed_job_detail']['rated'];
    errors = json['errors'];
  }
}
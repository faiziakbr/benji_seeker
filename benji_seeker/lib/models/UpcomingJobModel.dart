import 'dart:convert';

UpcomingJobsModel upcomingJobsModelResponseFromJson(String jsonString) {
  final jsonData = json.decode(jsonString);
  return UpcomingJobsModel.fromJson(jsonData);
}

class UpcomingJobsModel {
  bool status;
  List<ItemJobModel> upcomingJobs;
  List<dynamic> errors = [""];

  UpcomingJobsModel({this.status, this.upcomingJobs});

  UpcomingJobsModel.fromJson(Map<String, dynamic> parsedJson) {
    status = parsedJson['status'];

    List<ItemJobModel> _temp = [];
    var key = parsedJson['upcoming_jobs'];
    if (key != null && key.length > 0) {
      for (int i = 0; i < key.length; i++) {
        var allJobs = ItemJobModel.fromJson(key[i]);
        _temp.add(allJobs);
      }
    }
    upcomingJobs = _temp;
    errors = parsedJson["errors"];
  }
}

class ItemJobModel {
  String title;
  String when;
  String endDate;
  int recurrence;
  List<dynamic> skipDates = [];
  String jobId;
  bool isWhenDeterminedLocally = false;

  ItemJobModel(
      this.title, this.when, this.endDate, this.recurrence, this.jobId, this.skipDates, {this.isWhenDeterminedLocally = false});

  ItemJobModel.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    when = json['when'];
    endDate = json['end_date'];
    recurrence = json['recurrence'];
    jobId = json['job_id'];
    if (json['skip'] != null) {
      skipDates = json['skip'];
    }
  }

  @override
  String toString() {
    return "JOB ID: $jobId, title: $title, when: $when, endDate: $endDate";
  }
}
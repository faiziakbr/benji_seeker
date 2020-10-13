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
  String imageUrl;
  String subCategory;
  String status;
  String package;
  double hours;
  bool isWhenDeterminedLocally = false;

  ItemJobModel(
      this.title,
      this.when,
      this.endDate,
      this.recurrence,
      this.jobId,
      this.skipDates,
      this.imageUrl,
      this.subCategory,
      this.status,
      this.package,
      this.hours,
      {this.isWhenDeterminedLocally = false});

  ItemJobModel.fromJson(Map<String, dynamic> json) {
    try {
      title = json['title'];
      when = json['when'];
      endDate = json['end_date'];
      recurrence = json['recurrence'];
      jobId = json['job_id'];
      imageUrl = json['image_url'];
      subCategory = json['sub_category'];
      status = json['status'];
      if (json["package"] != null) package = json['package'];
      if (json["hours"] != null)
        hours = double.parse(json['hours'].toString()).toDouble();

      if (json['skip'] != null) {
        skipDates = json['skip'];
      }
    } catch (e) {
      print("ERROR: $e");
    }
  }


  @override
  String toString() {
    return "JOB ID: $jobId, title: $title, when: $when, endDate: $endDate Image: $imageUrl";
  }

}

import 'dart:convert';

CompletedJobModel responseFromJson(String jsonString) {
  final jsonData = json.decode(jsonString);
  return CompletedJobModel.fromJson(jsonData);
}

class CompletedJobModel{
  bool status;

  List<ItemCompletedModel> completedJobs;

  CompletedJobModel({this.status, this.completedJobs});

  CompletedJobModel.fromJson(Map<String, dynamic> parsedJson) {
    status = parsedJson['status'];

    List<ItemCompletedModel> _temp = [];
    var key = parsedJson['completed_jobs'];
    if (key != null && key.length > 0) {
      for (int i = 0; i < key.length; i++) {
        var allLeads = ItemCompletedModel.fromJson(key[i]);
        _temp.add(allLeads);
      }
    }
    completedJobs = _temp;
  }
}

class ItemCompletedModel{
  String processId;
  String category;
  String when;
  String sub_category;
  String logo;


  ItemCompletedModel({this.processId, this.category, this.when,
    this.sub_category});

  ItemCompletedModel.fromJson(Map<String, dynamic> json){
    processId = json["process_id"];
    category = json['category'];
    sub_category = json['sub_category'];
    when = json['when'];
    logo = json['job_logo'];
  }
}
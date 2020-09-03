import 'dart:convert';

HelpModel helpModelresponseFromHelp(String jsonString) {
  final jsonData = json.decode(jsonString);
  return HelpModel.fromJson(jsonData);
}

class HelpModel {
  bool status;
  List<FAQ> faqs = [];
  List<dynamic> error = ['Unexpected Error' ];

  HelpModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    List<FAQ> _temp = [];

    var key = json['faqs'];
    if (key != null && key.length > 0) {
      for (int i = 0; i < key.length; i++) {
        var allLeads = FAQ.fromJson(key[i]);
        _temp.add(allLeads);
      }
    }
    faqs = _temp;

    error = json['errors'];
  }
}

class FAQ {
  String id;
  String question;
  String answer;

  FAQ.fromJson(Map<String, dynamic> json) {
    id = json['_id'];
    question = json['question'];
    answer = json['answer'];
  }
}
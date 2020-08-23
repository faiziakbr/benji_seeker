import 'dart:convert';

PackageModel packageResponseFromJson(String jsonString) {
  final jsonData = json.decode(jsonString);
  return PackageModel.fromJson(jsonData);
}

class PackageModel{
  bool status;
  List<ItemPackage> packages;
  List<RecurringOptions> recurringOptions;
  List<dynamic> errors = [""];
  double wage = 0.0;


  PackageModel({this.status, this.packages});

  PackageModel.fromJson(Map<String, dynamic> parsedJson) {
    status = parsedJson['status'];
    List<ItemPackage> _temp = [];

    var key = parsedJson['tasks']['tasks'];
    if (key != null && key.length > 0) {
      for (int i = 0; i < key.length; i++) {
        var allLeads = ItemPackage.fromJson(key[i]);
        _temp.add(allLeads);
      }
    }
    packages = _temp;

    List<RecurringOptions> _temp1 = [];
    var recurringOptionsKey = parsedJson['tasks']['recurring_options'];
    if (recurringOptionsKey != null && recurringOptionsKey.length > 0) {
      for (int i = 0; i < recurringOptionsKey.length; i++) {
        var options = RecurringOptions.fromJson(recurringOptionsKey[i]);
        _temp1.add(options);
      }
    }
    recurringOptions = _temp1;

    wage = double.parse(parsedJson['tasks']['wage'].toString()).toDouble();
    errors = parsedJson['errors'];
  }
}

class ItemPackage{
  String id;
  String name;
  double hours;
  String description;
  bool isOpen = false;

  ItemPackage.fromJson( Map<String, dynamic> json){
    id = json['_id'];
    name = json['name'];
    hours = double.parse(json['hours'].toString()).toDouble();
    description = json['description'];
  }
}

class RecurringOptions{

  String id;
  String name;
  int numberOfDays;

  RecurringOptions.fromJson(Map<String, dynamic> json){
    id = json['_id'];
    name = json['name'];
    numberOfDays = json['number_of_days'];
  }
}
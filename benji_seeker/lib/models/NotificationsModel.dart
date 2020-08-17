import 'dart:convert';

SendDeviceTokenModel sendDeviceTokenModelResponseFromJson(String jsonString) {
  final jsonData = json.decode(jsonString);
  return SendDeviceTokenModel.fromJson(jsonData);
}

class SendDeviceTokenModel {
  bool status;

  SendDeviceTokenModel({this.status});

  SendDeviceTokenModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
  }
}

class IOSNotification {
  String title;
  String body;
  String jobId;
  String type;
  int badge = -1;

  IOSNotification.fromJson(Map<dynamic, dynamic> json) {
    title = json['aps']['alert']['title'];
    body = json['aps']['alert']['body'];

    if (json['aps']['badge'] != null) {
      badge = json['aps']['badge'];
    }
    jobId = json['job_id'];
    type = json['type'];
  }
}

class MyNotification {
  Header header;
  Payload payload;

  MyNotification.fromJson(Map<dynamic, dynamic> parsedJson) {
    if (parsedJson['notification'] != null) {
      Map<dynamic, dynamic> dataHeader = parsedJson['notification'];
      Map<dynamic, dynamic> data = parsedJson['data'];
      header = Header.fromJson(dataHeader);
      payload = Payload.fromJson(data);
    } else {
      print("DATA IS NULL");
    }
  }
}

class Header {
  String title;
  String body;

  Header.fromJson(Map<dynamic, dynamic> parsedJson) {
    title = parsedJson['title'];
    body = parsedJson['body'];
  }
}

class Payload {
  String jobId;
  String type;

  Payload.fromJson(Map<dynamic, dynamic> parsedJson) {
    jobId = parsedJson['job_id'];
    type = parsedJson['type'];
  }
}

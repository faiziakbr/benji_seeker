import 'dart:convert';

NotificationModel responseFromJson(String jsonString) {
  final jsonData = json.decode(jsonString);
  return NotificationModel.fromJson(jsonData);
}

class NotificationModel {
  bool status;
  List<ItemNotificationModel> notifications;
  List<dynamic> errors = ['Unexpected error!'];

  NotificationModel({this.status, this.notifications});

  NotificationModel.fromJson(Map<String, dynamic> parsedJson) {
    try {
      status = parsedJson['status'];
      List<ItemNotificationModel> _temp = [];

      var key = parsedJson['notifications'];
      if (key != null && key.length > 0) {
        for (int i = 0; i < key.length; i++) {
          var allNotifications = ItemNotificationModel.fromJson(key[i]);
          _temp.add(allNotifications);
        }
      }
      notifications = _temp;

      errors = parsedJson['errors'];
    } catch (e){
      print("ERROR 1: $e");
    }
  }
}

class ItemNotificationModel {
  bool seen;
  String created_at;
  String sender_name;
  String message;
  String url;
  String image;

  ItemNotificationModel.fromJson(Map<String, dynamic> json) {
    try {
      seen = json["seen"];
      created_at = json["created_at"];
      sender_name = json['sender_name'];
      message = json['message'];
      url = json['url'];
      image = json['profile_picture'];
    }catch (e){
      print("ERROR 2: $e");
    }
  }

}
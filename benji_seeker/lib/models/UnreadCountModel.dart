import 'dart:convert';

UnreadCountModel unreadCountModelResponseFromJson(String jsonString) {
  final jsonData = json.decode(jsonString);
  return UnreadCountModel.fromJson(jsonData);
}

class UnreadCountModel{
  bool status;
  int unreadNotifications;
  int unreadMessages;

  UnreadCountModel.fromJson(Map<String, dynamic> json){
    status = json['status'];
    unreadMessages = json['response']['message_data']['unread_count'];
    unreadNotifications = json['response']['notification_data']['total_unread_notifications'];
  }
}
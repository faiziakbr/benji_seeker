import 'dart:convert';

UserModel userModelResponseFromJson(String jsonString) {
  final jsonData = json.decode(jsonString);
  return UserModel.fromJson(jsonData);
}

class UserModel {
  bool status;
  String firstName;
  String lastName;
  String email;
  String phone;
  String profilePicture;
  List<dynamic> errors = [""];

  UserModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    firstName = json["user"]['first_name'];
    lastName = json["user"]['last_name'];
    email = json["user"]['email'];
    phone = json["user"]['phone'];
    profilePicture = json['user']['profile_picture_url'];
    errors = json['errors'];
  }
}
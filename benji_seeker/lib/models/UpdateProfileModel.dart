import 'dart:convert';

UpdateUserProfileModel updateUserProfileModelResponseFromJson(
    String jsonString) {
  final jsonData = json.decode(jsonString);
  return UpdateUserProfileModel.fromJson(jsonData);
}

class UpdateUserProfileModel {
  bool status;
  bool getOTP = false;
  String imageUrl;
  List<dynamic> errors = [""];

  UpdateUserProfileModel({this.status, this.imageUrl});

  UpdateUserProfileModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    getOTP = json['get_otp'];
    imageUrl = json['profile_picture_url'];
    if (json["errors"] != null) {
      errors = json['errors'];
    }
  }
}
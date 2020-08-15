import 'dart:convert';

ProviderDetail providerDetailResponseFromJson(String jsonString) {
  final jsonData = json.decode(jsonString);
  return ProviderDetail.fromJson(jsonData);
}

//TODO REVIEWS AND SKILL STILL MISSING
class ProviderDetail {
  bool status;
  Provider provider;
  List<dynamic> errors;

  ProviderDetail.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    if (json['provider'] != null)
      provider = Provider.fromJson(json['provider']);
    errors = json['errors'];
  }
}

class Provider {
  String id;
  String nickName;
  String about;
  String address;
  double rating;
  double totalRating = 0;
  List<Reviews> reviews;
  int totalReviews;
  int totalJobs;
  String profilePic = "";
  RatingStandard ratingStandard;

  Provider.fromJson(Map<String, dynamic> json) {
    id = json['_id'];
    nickName = json['nickname'];
    about = json['about'];
    address = json['address'];
    if (json["rating"] != null) rating = double.parse(json['rating'].toString()).toDouble();
    totalRating = double.parse(json['total_ratings'].toString()).toDouble();
    totalReviews = int.parse(json['total_reviews'].toString()).toInt();
    totalJobs = int.parse(json['total_jobs'].toString()).toInt();
    profilePic = json['profile_picture'];
    ratingStandard = RatingStandard.fromJson(json['rating_standings']);

    List<Reviews> _temp = [];
    var key = json['reviews'];
    if (key != null && key.length > 0) {
      for (int i = 0; i < key.length; i++) {
        var allReviews = Reviews.fromJson(key[i]);
        _temp.add(allReviews);
      }
    }
    reviews = _temp;
  }
}

class Reviews{

  String comment;
  int rating;
  String reviewedAt;
  String seekerName;
  String jobAddress;

  Reviews.fromJson(Map<String, dynamic> json){
    comment = json['comment'];
    if (json['rating'] != null)
    rating = int.parse(json['rating'].toString()).toInt();
    reviewedAt = json['reviewed_at'];
    seekerName = json['seeker_name'];
    jobAddress = json['job_address'];
  }
}

class RatingStandard {
  double ratingStandard1 = 0;
  double ratingStandard2 = 0;
  double ratingStandard3 = 0;
  double ratingStandard4 = 0;
  double ratingStandard5 = 0;

  RatingStandard.fromJson(Map<String, dynamic> json) {
    ratingStandard1 = double.parse(json['1'].toString()).toDouble();
    ratingStandard2 = double.parse(json['2'].toString()).toDouble();
    ratingStandard3 = double.parse(json['3'].toString()).toDouble();
    ratingStandard4 = double.parse(json['4'].toString()).toDouble();
    ratingStandard5 = double.parse(json['5'].toString()).toDouble();
  }
}

import 'dart:convert';

BiddersModel bidderResponseFromJson(String jsonString) {
  final jsonData = json.decode(jsonString);
  return BiddersModel.fromJson(jsonData);
}

class BiddersModel {
  bool status;
  List<Bidder> bidders;
  List<dynamic> errors = [""];

  BiddersModel({this.status});

  BiddersModel.fromJson(Map<String, dynamic> parsedJson) {
    status = parsedJson['status'];
    List<Bidder> _temp = [];

    var key = parsedJson['bids'];
    if (key != null && key.length > 0) {
      for (int i = 0; i < key.length; i++) {
        var allLeads = Bidder.fromJson(key[i]);
        _temp.add(allLeads);
      }
    }
    bidders = _temp;
    errors = parsedJson['errors'];
  }
}

class Bidder {
  String id;
  String providerId;
  String name;
  String profilePicture;
  Address address;
  double rating = 0;
  int totalJobs = 0;

  Bidder.fromJson(Map<String, dynamic> json) {
    id = json["_id"];
    providerId = json['provider_id'];
    name = json['name'];
    if (json['address'] != null) {
      address = Address.fromJson(json['address']);
    }
    if(json["rating"] != null)
    rating = double.parse(json['rating'].toString()).toDouble();
    totalJobs = json["total_jobs"];
    profilePicture = json['profile_picture'];
  }
}

class Address {
  String country;
  String city;
  String state;
  String zip;
  double latitude;
  double longitude;
  String street;
  String fullAddress;

  Address.fromJson(Map<String, dynamic> json) {
    country = json['country'];
    city = json['city'];
    state = json['state'];
    zip = json['zip'];
    latitude = double.parse(json['latitude'].toString()).toDouble();
    longitude = double.parse(json['longitude'].toString()).toDouble();
    street = json['street'];
    fullAddress = json['full_address'];
  }
}

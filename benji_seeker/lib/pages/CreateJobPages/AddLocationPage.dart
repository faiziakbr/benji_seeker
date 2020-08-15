import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:benji_seeker/My_Widgets/CustomProgressDialog.dart';
import 'package:benji_seeker/My_Widgets/MyToast.dart';
import 'package:benji_seeker/SharedPref/SavedData.dart';
import 'package:benji_seeker/constants/Constants.dart';
import 'package:benji_seeker/constants/MyColors.dart';
import 'package:benji_seeker/constants/MyCredentials.dart';
import 'package:benji_seeker/constants/Urls.dart';
import 'package:benji_seeker/custom_texts/MontserratText.dart';
import 'package:benji_seeker/models/CreateJobModel.dart';
import 'package:dio/dio.dart';
import "package:flutter/material.dart";

class AddLocationPage extends StatefulWidget {
  final CreateJobModel createJobModel;
  final bool returnValue;

  AddLocationPage(this.createJobModel, {this.returnValue = false});

  @override
  _AddLocationPageState createState() => _AddLocationPageState();
}

class _AddLocationPageState extends State<AddLocationPage> {
  var _controller = TextEditingController();

  List<PlacesDetail> _places = [];

  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            if (widget.returnValue) {
              Navigator.pop(context, null);
            } else
              Navigator.pop(context, false);
          },
          icon: Icon(
            Icons.chevron_left,
            color: lightIconColor,
          ),
        ),
        title: TextField(
          controller: _controller,
          cursorColor: Colors.black,
          decoration: InputDecoration.collapsed(hintText: "Enter location"),
          onChanged: (value) {
            Timer(const Duration(milliseconds: 800), () {
              _getPredictionsResponse(value).then((result) {
                setState(() {
                  _places = [];
                  if (result.status) {
                    for (PlacesDetail place in result.places) {
                      if (place.description.contains("USA")) _places.add(place);
                    }
                  }
                });
              });
            });
          },
        ),
        backgroundColor: Colors.white,
      ),
      body: Container(
        margin: EdgeInsets.only(
            top: 32.0,
            left: mediaQueryData.size.width * 0.05,
            right: mediaQueryData.size.width * 0.05),
        child: ListView.builder(
            itemCount: _places.length,
            itemBuilder: (context, index) {
              var place = _places[index];
              return GestureDetector(
                  onTap: () {
                      _showProgressDialog("Adding address...");
                      _getPlaceDetailResponse(place.placeId).then((result) {
                        if (result.status) {
                          _postCheckAddressResponse(
                              result.location.lat, result.location.lng)
                              .then((checkAddress) {
                            if (checkAddress.status) {
                              widget.createJobModel.latitude = result.location.lat;
                              widget.createJobModel.longitude = result.location.lng;
                              widget.createJobModel.address = place.description;
                              widget.createJobModel.placeId = place.placeId;
                              Navigator.pop(context); //poping progress dialog
                              Navigator.pop(context, true);
                            } else {
                              MyToast("Sorry, we don't serve in this area.",
                                  context);
                              Navigator.pop(context); //poping progress dialog
                            }
                          });
                        }
                      });

                  },
                  child: _itemPlace(place));
            }),
      ),
    );
  }

  Widget _itemPlace(PlacesDetail place) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Flexible(
                child: Row(
                  children: <Widget>[
                    Image.asset("assets/location_orange_icon.png",
                        width: 20, height: 20),
                    Expanded(
                      child: Container(
                        child: MontserratText(
                          "${place.description}",
                          16,
                          separatorColor,
                          FontWeight.w500,
                          left: 16.0,
                          right: 16.0,
                        ),
                      ),
                    ),
                  ],
                  crossAxisAlignment: CrossAxisAlignment.start,
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: lightIconColor,
              )
            ],
          ),
          Divider(
            color: unfilledProgressColor,
          )
        ],
      ),
    );
  }

  _showProgressDialog(String message) {
    showDialog(
        barrierDismissible: bool.fromEnvironment("dismiss dialog"),
        context: context,
        builder: (_) => CustomProgressDialog("$message"));
  }

  Future<GooglePlacesModel> _getPredictionsResponse(String location) async {
    BaseOptions baseOptions = new BaseOptions(
      connectTimeout: 15000,
      receiveTimeout: 15000,
    );
    Dio dio = new Dio(baseOptions);

    final response = await dio.get(
        BASE_GOOGLE_AUTOCOMPLETE_URL + "?input=$location&key=$GOOGLE_API_KEY");

//    print("STATUS CODE: ${response.statusCode}");
//      print("RESPONSE: $response");
    if (response.statusCode == HttpStatus.ok)
      return _responseFromJson(json.encode(response.data));
    else
      return GooglePlacesModel(status: false);
  }

  Future<PlaceDetailModel> _getPlaceDetailResponse(String placeId) async {
    BaseOptions baseOptions = new BaseOptions(
      connectTimeout: 15000,
      receiveTimeout: 15000,
    );
    Dio dio = new Dio(baseOptions);

    final response = await dio.get(BASE_GOOGLE_PLACE_DETAIL_URL +
        "?place_id=$placeId&key=$GOOGLE_API_KEY");

    print("RESPONSE: ${response.data}");
    if (response.statusCode == HttpStatus.ok)
      return _locationResponseFromJson(json.encode(response.data));
    else
      return PlaceDetailModel(status: false);
  }

  Future<CheckAddressModel> _postCheckAddressResponse(
      double lat, double lng) async {
    try {
      BaseOptions baseOptions = new BaseOptions(
        connectTimeout: 15000,
        receiveTimeout: 15000,
      );
      Dio dio = new Dio(baseOptions);

      Map<String, double> map = {'latitude': lat, 'longitude': lng};

      SavedData savedData = new SavedData();
      String token = await savedData.getValue(TOKEN);

      Options options = new Options(headers: {"token": token});

      final response = await dio.post(BASE_URL + URL_CHECK_ADDRESS,
          options: options, data: map);

      print("CHECK ADDRESS RESPONSE STATUS: ${response.statusCode}");
      print("CHECK ADDRESS RESPONSE: ${response.data}");

      if (response.statusCode == HttpStatus.ok)
        return _checkAddressResponseFromJson(json.encode(response.data));
      else
        return CheckAddressModel(status: false);
    } on DioError catch (e) {
      if (e.response.data != null)
        return _checkAddressResponseFromJson(json.encode(e.response.data));
      else
        return CheckAddressModel(status: false);
    }
  }

//  Future<ServiceLocationModel> _postServiceLocationResponse(
//      double lat, double lng, String address) async {
//    try {
//      Dio dio = new Dio();
//
////      Map<String, String> fullAddress = {'full_address': };
//
//      Map<String, dynamic> map = {
//        'latitude': lat,
//        'longitude': lng,
//        'address': '$address'
//      };
//
//      SavedData savedData = new SavedData();
//      String token = await savedData.getValue(TOKEN);
//
//      Options options = new Options(headers: {"token": token});
//
//      final response = await dio.post(BASE_URL + URL_SERVICE_LOCATION,
//          options: options, data: json.encode(map));
//
//      print("RESPONSE LOCATION ADDED: $response");
//      if (response.statusCode == HttpStatus.ok) {
//        return _serviceLocationResponseFromJson(json.encode(response.data));
//      } else {
//        return ServiceLocationModel(status: false);
//      }
//    } on DioError catch (e) {
//      print("RESPONSE ERROR LOCATION ADDED: ${e.response}");
//
//      if (e.response != null) {
//        return _serviceLocationResponseFromJson(json.encode(e.response.data));
//      } else {
//        return ServiceLocationModel(status: false);
//      }
//    }
//  }
}

GooglePlacesModel _responseFromJson(String jsonString) {
  final jsonData = json.decode(jsonString);
  return GooglePlacesModel.fromJson(jsonData);
}

class GooglePlacesModel {
  bool status = true;
  List<PlacesDetail> places = [];

  GooglePlacesModel({this.status});

  GooglePlacesModel.fromJson(Map<dynamic, dynamic> json) {
    var key = json['predictions'];
    for (int i = 0; i < key.length; i++) {
      var place = PlacesDetail.fromJson(key[i]);
      places.add(place);
    }
  }
}

class PlacesDetail {
  String placeId;
  String description;

  PlacesDetail.fromJson(Map<dynamic, dynamic> json) {
    placeId = json['place_id'];
    description = json['description'];
  }
}

PlaceDetailModel _locationResponseFromJson(String jsonString) {
  final jsonData = json.decode(jsonString);
  return PlaceDetailModel.fromJson(jsonData);
}

class PlaceDetailModel {
  bool status = true;
  Location location;

  PlaceDetailModel({this.status});

  PlaceDetailModel.fromJson(Map<dynamic, dynamic> json) {
    try {
      if (json['result']['geometry']['location'] != null)
        location = Location.fromJson(json['result']['geometry']['location']);
    } catch (e) {
      print("GEO ERROR: ${e.toString()}");
    }
  }
}

class Location {
  double lat;
  double lng;

  Location.fromJson(Map<dynamic, dynamic> json) {
    try {
      lat = double.parse(json['lat'].toString());
      lng = double.parse(json['lng'].toString());
    } catch (e) {
      print("LAT ERROR: ${e.toString()}");
    }
  }
}

CheckAddressModel _checkAddressResponseFromJson(String jsonString) {
  final jsonData = json.decode(jsonString);
  return CheckAddressModel.fromJson(jsonData);
}

class CheckAddressModel {
  bool status;

  CheckAddressModel({this.status});

  CheckAddressModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
  }
}

ServiceLocationModel _serviceLocationResponseFromJson(String jsonString) {
  final jsonData = json.decode(jsonString);
  return ServiceLocationModel.fromJson(jsonData);
}

//TODO Complete thsi mdoel
class ServiceLocationModel {
  bool status;
  List<dynamic> errors = [""];

  ServiceLocationModel({this.status, this.errors});

  ServiceLocationModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    errors = json['errors'];
  }
}

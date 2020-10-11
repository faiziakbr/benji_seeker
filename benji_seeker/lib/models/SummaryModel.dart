import 'dart:convert';

SummaryModel summaryModelResponseFromJson(String jsonString) {
  final jsonData = json.decode(jsonString);
  return SummaryModel.fromJson(jsonData);
}

class SummaryModel {
  bool status;
  String total;
  double applicationFee;
  double amount;
  bool canGiveTip;
  bool canRateProvider;
  String name;
  int rating;
  String review;
  double tip;
  double amountRefunded;
  List<dynamic> errors;

  SummaryModel.fromJson(Map<String, dynamic> json) {
    try {
      status = json['status'];
      total = json['summary']['total'];
      applicationFee =
          double.parse(json['summary']['application_fee'].toString())
              .toDouble();
      amount = double.parse(json['summary']['amount'].toString()).toDouble();
      canGiveTip = json['summary']['can_give_tip'];
      canRateProvider = json['summary']['can_rate_provider'];
      name = json['summary']['name'];
      if (json['summary']['rating'] != null)
        rating = int.parse(json['summary']['rating'].toString()).toInt();
      review = json['summary']['review'];
      if (json['summary']['tip'] != null)
        tip = double.parse(json['summary']['tip'].toString()).toDouble();
      if (json['summary']["amount_refunded"] != null)
        amountRefunded =
            double.parse(json['summary']["amount_refunded"].toString()).toDouble();
      errors = json['errors'];
    } catch (e) {
      print("ERROR IN SUMMARY MODE: ${e.toString()}");
    }
  }
}

import 'dart:convert';

CategoryModel categoryResponseFromJson(String jsonString) {
  final jsonData = json.decode(jsonString);
  return CategoryModel.fromJson(jsonData);
}

class CategoryModel{
  bool status;
  List<ItemCategory> categories;
  List<dynamic> errors = [""];


  CategoryModel({this.status, this.categories});

  CategoryModel.fromJson(Map<String, dynamic> parsedJson) {
    status = parsedJson['status'];
    List<ItemCategory> _temp = [];

    var key = parsedJson['sub_categories'];
    if (key != null && key.length > 0) {
      for (int i = 0; i < key.length; i++) {
        var allLeads = ItemCategory.fromJson(key[i]);
        _temp.add(allLeads);
      }
    }
    categories = _temp;
    errors = parsedJson['errors'];
  }
}

class ItemCategory{
  String id;
  String name;
  String image;

  ItemCategory.fromJson( Map<String, dynamic> json){
    id = json['_id'];
    name = json['name'];
    image = json['image_url'];
  }

}
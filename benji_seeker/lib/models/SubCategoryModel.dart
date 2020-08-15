import 'dart:convert';

SubCategoryModel subCategoryResponseFromJson(String jsonString) {
  final jsonData = json.decode(jsonString);
  return SubCategoryModel.fromJson(jsonData);
}

class SubCategoryModel{
  bool status;
  List<ItemSubCategory> subCategories;
  List<dynamic> errors = [""];


  SubCategoryModel({this.status, this.subCategories});

  SubCategoryModel.fromJson(Map<String, dynamic> parsedJson) {
    status = parsedJson['status'];
    List<ItemSubCategory> _temp = [];

    var key = parsedJson['sub_categories'];
    if (key != null && key.length > 0) {
      for (int i = 0; i < key.length; i++) {
        var allLeads = ItemSubCategory.fromJson(key[i]);
        _temp.add(allLeads);
      }
    }
    subCategories = _temp;

    errors = parsedJson['errors'];
  }
}

class ItemSubCategory{
  String id;
  String name;

  ItemSubCategory({this.id, this.name});

  ItemSubCategory.fromJson( Map<String, dynamic> json){
    id = json['_id'];
    name = json['name'];
  }

}
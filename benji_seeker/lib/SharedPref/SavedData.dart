import 'package:shared_preferences/shared_preferences.dart';

class SavedData {

  SharedPreferences _sharedPreferences;

  void setValue(String key, String value) async {
    _sharedPreferences = await SharedPreferences.getInstance();
    _sharedPreferences.setString(key, value);
  }

  void setIntValue(String key, int value) async {
    _sharedPreferences = await SharedPreferences.getInstance();
    _sharedPreferences.setInt(key, value);
  }

  Future<bool> setBoolValue(String key, bool value) async {
    _sharedPreferences = await SharedPreferences.getInstance();
    return _sharedPreferences.setBool(key, value);
  }

  Future<String> getValue(String key) async{
    _sharedPreferences = await SharedPreferences.getInstance();
    return _sharedPreferences.getString(key);
  }

  Future<int> getIntValue(String key) async{
    _sharedPreferences = await SharedPreferences.getInstance();
    return _sharedPreferences.getInt(key);
  }

  Future<bool> getBoolValue(String key) async{
    _sharedPreferences = await SharedPreferences.getInstance();
    return _sharedPreferences.getBool(key);
  }

  Future<bool> logOut() async{
    _sharedPreferences = await SharedPreferences.getInstance();
    return await _sharedPreferences.clear();
  }
}

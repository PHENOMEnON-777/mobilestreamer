import 'package:shared_preferences/shared_preferences.dart';

class Storethemedata {
  Future<bool> setbool(String key, bool value) async {
    final pref = await SharedPreferences.getInstance();
    return pref.setBool(key, value);
  }

  Future<bool?> getbool(String key) async {
    final pref = await SharedPreferences.getInstance();
    final value = pref.getBool(key);
    return value;
  }
}

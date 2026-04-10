import 'package:shared_preferences/shared_preferences.dart';

class SPHelper {
  //static late SharedPreferences _prefs;

  Future<bool> setSettings(String name, String image) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      
      await prefs.setString('name', name);
      await prefs.setString('image', image);
      return true;
    } on Exception catch (_) {
      return false;
    }
  }

  Future<Map<String, String>> getSettings() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      
      String name = prefs.getString('name') ?? '';
      String image = prefs.getString('image') ?? 'Sea';
      return {'name': name, 'image': image};
    } on Exception catch (_) {
      return {'name': '', 'image': 'Sea'};
    }
}
}
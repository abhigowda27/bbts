import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferenceServices {
  factory SharedPreferenceServices() => _instance;
  SharedPreferenceServices._internal();

  static final SharedPreferenceServices _instance =
      SharedPreferenceServices._internal();

  String isLoggedIn = "is_logged_in";
  late SharedPreferences pref;

  Future<void> init() async {
    pref = await SharedPreferences.getInstance();
  }

  Future<void> saveLoggedInStatus(bool status) async {
    await pref.setBool(isLoggedIn, status);
  }

  bool? getLoggedInStatus() {
    return pref.getBool(isLoggedIn);
  }
}

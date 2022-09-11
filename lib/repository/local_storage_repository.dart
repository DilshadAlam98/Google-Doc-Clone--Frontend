import 'package:rx_shared_preferences/rx_shared_preferences.dart';

class LocalStorage {
  void setToken(String token) async {
    final _preferences = RxSharedPreferences.getInstance();
    await _preferences.setString("x-auth-token", token);
  }

  Future<String?> getToken() async {
    final _preferences = RxSharedPreferences.getInstance();
    final token = await _preferences.getString("x-auth-token");
    return token;
  }
}

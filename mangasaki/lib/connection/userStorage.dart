import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class UserStorage {
  static Future<void> saveUserData(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userData', jsonEncode(userData));
    print("Datos guardados correctamente");
  }

  static Future<Map<String, dynamic>?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    String? userData = prefs.getString('userData');

    if (userData == null) {
      print("No se encontraron datos guardados.");
      return null;
    }

    try {
      return jsonDecode(userData);
    } catch (e) {
      print("Error al decodificar JSON: $e");
      return null;
    }
  }

  static Future<void> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userData');
  }
}
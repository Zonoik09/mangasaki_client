import 'package:flutter/material.dart';

class GlobalState extends ChangeNotifier {
  String _username = "username";

  // Getter para acceder al valor de username
  String get username => _username;

  // Setter para actualizar el valor de username
  void updateUsername(String newUsername) {
    _username = newUsername;
    notifyListeners();
  }
}

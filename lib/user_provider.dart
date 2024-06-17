import 'package:flutter/material.dart';

class UserProvider with ChangeNotifier {
  String _user = '';

  String get user => _user;

  void setUser(String user) {
    _user = user;
    notifyListeners();
  }
}

class APIProvider with ChangeNotifier {
  String _api = 'http://192.168.1.3:3000/api/';

  String get apiUrl => _api;

}
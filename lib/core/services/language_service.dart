import 'package:flutter/material.dart';

class LanguageService extends ChangeNotifier {
  String _language = "en";

  String get language => _language;

  void setLanguage(String lang) {
    _language = lang;
    notifyListeners();
  }

  bool get isSinhala => _language == "si";
  bool get isTamil => _language == "ta";
  bool get isEnglish => _language == "en";
}
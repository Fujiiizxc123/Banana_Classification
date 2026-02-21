import 'package:flutter/foundation.dart';

class ApiConstants {
  static const String _ngrokUrl =
      'https://unetymologic-claud-mazily.ngrok-free.dev'; // ← exact URL

  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:8000/api';
    } else {
      return '$_ngrokUrl/api';
    }
  }

  static String get register => '$baseUrl/register';
  static String get login => '$baseUrl/login';
  static String get logout => '$baseUrl/logout';
  static String get user => '$baseUrl/user';
  static String get history => '$baseUrl/history';
}

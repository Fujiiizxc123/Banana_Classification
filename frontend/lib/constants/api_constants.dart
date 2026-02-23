import 'package:flutter/foundation.dart';
import 'dart:io';

class ApiConstants {
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:8000/api';
    } else if (Platform.isAndroid) {
      return 'http://192.168.8.196:8000/api'; // ← your Wi-Fi IP
    } else {
      return 'http://localhost:8000/api';
    }
  }

  static String get register => '$baseUrl/register';
  static String get login    => '$baseUrl/login';
  static String get logout   => '$baseUrl/logout';
  static String get user     => '$baseUrl/user';
  static String get history  => '$baseUrl/history';
}